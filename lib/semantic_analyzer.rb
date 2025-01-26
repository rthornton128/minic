# typed: true
# frozen_string_literal: true

require_relative "semantic_analyzer/type"
require_relative "semantic_analyzer/function_type"
require_relative "semantic_analyzer/built_in_type"
require_relative "semantic_analyzer/scope"

module Minic
  class SemanticAnalyzer
    class Error < ::Minic::Error; end

    sig { params(ast: AbstractSyntaxTree).void }
    def initialize(ast:)
      @ast = ast
    end

    sig { void }
    def check
      program = @ast.program
      scope = Scope.new(parent: nil)
      insert_builtins_into_scope(scope:)

      program.declarations.each do |declaration|
        case declaration
        when AbstractSyntaxTree::FunctionDeclaration
          check_function_decl(func_decl: declaration, scope:)
        when AbstractSyntaxTree::VariableDeclaration
          check_variable_decl(var_decl: declaration, scope:)
        else
          T.absurd(declaration)
        end
      end
    end

    private

    sig { params(func_decl: AbstractSyntaxTree::FunctionDeclaration, scope: Scope).void }
    def check_function_decl(func_decl:, scope:)
      func_type = T.cast(type_of(node: func_decl, scope:), FunctionType)
      scope[func_decl.identifier.literal] = func_type

      block_scope = Scope.new(parent: scope)
      func_decl.parameter_list.parameters.each do |parameter|
        param_type = type_of(node: parameter.type, scope:)
        block_scope[parameter.identifier.literal] = param_type
      end

      block = func_decl.block
      check_block(block:, return_type: func_type, scope: block_scope)

      # for a function, a block must end in a return statement
      final_statement = func_decl.block.statements.last
      raise Error.new(
        "function block must end with a return statement",
        position: func_decl.position,
      ) if final_statement.nil? || !final_statement.is_a?(AbstractSyntaxTree::ReturnStatement)
    end

    sig { params(block: AbstractSyntaxTree::Block, return_type: Type, scope: Scope).void }
    def check_block(block:, return_type:, scope:)
      block.statements.each do |statement|
        check_statement(statement:, return_type:, scope:)
      end
    end

    sig { params(func_call: AbstractSyntaxTree::FunctionCall, scope: Scope).void }
    def check_built_in(func_call:, scope:)
      built_in_type = T.cast(type_of(node: func_call, scope:), BuiltInType)

      # built-ins can include varargs and untyped behaviour, so it's much more relaxed
      param_types = built_in_type.param_types
      args = func_call.arguments

      param_types.each_with_index do |param_type, i|
        arg_type = type_of(node: T.must(args[i]), scope:)
        assert_types(param_type, arg_type)
      end
    end

    sig { params(statement: AbstractSyntaxTree::Statement, return_type: Type, scope: Scope).void }
    def check_statement(statement:, return_type:, scope:)
      case statement
      when AbstractSyntaxTree::AssignmentStatement
        ident_type = type_of(node: statement.lhs, scope:)
        expr_type = type_of(node: statement.rhs, scope:)
        assert_types(ident_type, expr_type)
      when AbstractSyntaxTree::FunctionCall
        check_function_call(func_call: statement, scope:)
      when AbstractSyntaxTree::IfStatement
        # conditional must evaluate to a boolean
        cond_type = type_of(node: statement.conditional, scope:)
        assert_types(Type.new(name: "bool", position: statement.position), cond_type)

        check_block(block: statement.then_block, return_type:, scope:)
        check_block(block: T.must(statement.else_block), return_type:, scope:) unless statement.else_block.nil?
      when AbstractSyntaxTree::ReturnStatement
        stmt_type = type_of(node: statement, scope:)
        assert_types(return_type, stmt_type)

        check_expression(expression: T.must(statement.expression), scope:) unless statement.expression.nil?
      when AbstractSyntaxTree::VariableDeclaration
        check_variable_decl(var_decl: statement, scope:)
      when AbstractSyntaxTree::WhileStatement
        # conditional must evaluate to a boolean
        cond_type = type_of(node: statement.conditional, scope:)
        assert_types(Type.new(name: "bool", position: statement.position), cond_type)

        check_block(block: statement.block, return_type:, scope:)
      end
    end

    sig { params(func_call: AbstractSyntaxTree::FunctionCall, scope: Scope).void }
    def check_function_call(func_call:, scope:)
      func_type = T.cast(type_of(node: func_call, scope:), FunctionType)

      check_built_in(func_call:, scope:) if func_type.built_in?

      param_types = func_type.param_types
      args = func_call.arguments

      raise Error.new(
        "expected #{param_types.size} arguments but got #{args.size}",
        position: func_call.position,
      ) if param_types.size != args.size

      param_types.each_with_index do |param_type, i|
        arg_type = type_of(node: T.must(args[i]), scope:)
        assert_types(param_type, arg_type)
      end
    end

    sig { params(var_decl: AbstractSyntaxTree::VariableDeclaration, scope: Scope).void }
    def check_variable_decl(var_decl:, scope:)
      var_type = type_of(node: var_decl.type, scope:)
      raise Error.new("variables may not be declared void", "", position: var_decl.position) if var_type.void?

      unless var_decl.assignment.nil?
        check_expression(expression: T.must(var_decl.assignment), scope:)

        expr_type = type_of(node: T.must(var_decl.assignment), scope:)
        assert_types(var_type, expr_type)
      end

      # it would be an error to assign a newly declared variable to itself
      # (int i = i;) to make sure this self-referential error is caught, the
      # identifier should not be added to the current scope until types and
      # variable lookups have been resolved.
      scope[var_decl.identifier.literal] = var_type
    end

    sig { params(expression: AbstractSyntaxTree::Expression, scope: Scope).void }
    def check_expression(expression:, scope:)
      case expression
      when AbstractSyntaxTree::BinaryExpression
        check_expression(expression: expression.lhs, scope:)
        lhs_type = type_of(node: expression.lhs, scope:)

        check_expression(expression: expression.rhs, scope:)
        rhs_type = type_of(node: expression.rhs, scope:)

        assert_types(lhs_type, rhs_type)

        # this is quite messy, maybe there's a better way to express it?
        case expression.literal
        when "+"
          raise Error.new(
            "arithmetic operators not compatible with boolean operands",
            position: expression.position,
          ) if lhs_type.name == "bool" || rhs_type.name == "bool"
        when "-", "*", "/", "%"
          bad_types = ["bool", "string"].freeze
          raise Error.new(
            "arithmetic operators not compatible with operands",
            position: expression.position,
          ) if bad_types.include?(lhs_type.name) || bad_types.include?(rhs_type.name)
        end
      when AbstractSyntaxTree::FunctionCall
        check_function_call(func_call: expression, scope:)
      when AbstractSyntaxTree::SubExpression
        check_expression(expression: expression.expression, scope:)
      when AbstractSyntaxTree::UnaryExpression
        unary_type = type_of(node: expression, scope:)
        expr_type = type_of(node: expression.rhs, scope:)
        assert_types(unary_type, expr_type)
        check_expression(expression: expression.rhs, scope:)
      end
    end

    sig { params(a: Type, b: Type).void }
    def assert_types(a, b)
      raise Error.new(
        "type missmatch '#{a}' vs '#{b}'",
        position: b.position,
      ) if a != b
    end

    sig { params(scope: Scope).void }
    def insert_builtins_into_scope(scope:)
      position = FileSet::Position.new(name: "built-in functions", row: 1, column: 1)
      scope["print"] = BuiltInType.new(
        return_type: Type.new(name: "void", position:),
        param_types: [
          Type.new(name: "string", position:),
        ],
      )
    end

    sig { params(node: AbstractSyntaxTree::Node, scope: Scope).returns(Type) }
    def type_of(node:, scope:)
      case node
      when AbstractSyntaxTree::BooleanLiteral
        Type.new(name: "bool", position: node.position)
      when AbstractSyntaxTree::DoubleLiteral
        Type.new(name: "double", position: node.position)
      when AbstractSyntaxTree::StringLiteral
        Type.new(name: "string", position: node.position)
      when AbstractSyntaxTree::IntegerLiteral
        Type.new(name: "int", position: node.position)
      when AbstractSyntaxTree::Keyword
        Type.new(name: node.literal, position: node.position)
      when AbstractSyntaxTree::Identifier
        type = scope[node.literal]
        raise Error.new("undeclared variable in assignment", position: node.position) if type.nil?

        type
      when AbstractSyntaxTree::BinaryExpression
        case node.literal
        when "==", "<", ">", "&&", "||"
          Type.new(name: "bool", position: node.position)
        else
          type_of(node: node.lhs, scope:)
        end
      when AbstractSyntaxTree::Parameter
        Type.new(name: node.type.literal, position: node.position)
      when AbstractSyntaxTree::FunctionCall
        func_type = scope[node.identifier.literal]

        raise Error.new(
          "#{node.identifier.literal} not found",
          position: node.position,
        ) if func_type.nil?

        raise Error.new(
          "#{node.identifier.literal} is not function",
          position: node.position,
        ) unless func_type.is_a?(FunctionType)

        func_type
      when AbstractSyntaxTree::SubExpression
        type_of(node: node.expression, scope:)
      when AbstractSyntaxTree::UnaryExpression
        case node.literal
        when "!"
          Type.new(name: "bool", position: node.position)
        when "-"
          type_of(node: node.rhs, scope:)
        else
          raise Error.new("invalid or unknown operator '#{node.literal}'", position: node.position)
        end
      when AbstractSyntaxTree::ReturnStatement
        return Type.new(name: "void", position: node.position) if node.expression.nil?

        type_of(node: T.must(node.expression), scope:)
      when AbstractSyntaxTree::FunctionDeclaration
        return_type = type_of(node: node.type, scope:)

        param_types = []
        node.parameter_list.parameters.each do |parameter|
          param_types << type_of(node: parameter, scope:)
        end

        FunctionType.new(return_type:, param_types:)
      else
        raise Error.new("invalid or unknown expression", position: node.position)
      end
    end
  end
end
