# typed: true
# frozen_string_literal: true

require_relative "semantic_analyzer/type"
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

      program.declarations.each do |declaration|
        case declaration
        when AbstractSyntaxTree::VariableDeclaration
          check_variable_decl(var_decl: declaration, scope:)
        when AbstractSyntaxTree::FunctionDeclaration
          check_function_decl(func_decl: declaration, scope:)
        else
          T.absurd(declaration)
        end
      end
    end

    private

    sig { params(func_decl: T.untyped, scope: T.untyped).returns(T.untyped) }
    def check_function_decl(func_decl:, scope:)
      # No op
    end

    sig { params(var_decl: AbstractSyntaxTree::VariableDeclaration, scope: Scope).void }
    def check_variable_decl(var_decl:, scope:)
      var_type = type_of(node: var_decl.type, scope:)
      raise Error.new("variables may not be declared void", "", var_decl.offset) if var_type.void?

      unless var_decl.assignment.nil?
        expr_type = type_of(node: T.must(var_decl.assignment), scope:)
        assert_types(var_type, expr_type)
        check_expression(expression: T.must(var_decl.assignment), scope:)
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
        "",
        b.offset,
      ) if a != b
    end

    sig { params(node: AbstractSyntaxTree::Node, scope: Scope).returns(Type) }
    def type_of(node:, scope:)
      case node
      when AbstractSyntaxTree::BooleanLiteral
        Type.new(name: "bool", offset: node.offset)
      when AbstractSyntaxTree::DoubleLiteral
        Type.new(name: "double", offset: node.offset)
      when AbstractSyntaxTree::StringLiteral
        Type.new(name: "string", offset: node.offset)
      when AbstractSyntaxTree::IntegerLiteral
        Type.new(name: "int", offset: node.offset)
      when AbstractSyntaxTree::Keyword
        Type.new(name: node.literal, offset: node.offset)
      when AbstractSyntaxTree::Identifier
        type = scope[node.literal]
        raise Error.new("undeclared variable in assignment", node.literal, node.offset) if type.nil?

        type
      when AbstractSyntaxTree::SubExpression
        type_of(node: node.expression, scope:)
      when AbstractSyntaxTree::UnaryExpression
        type_of_operator(node.literal, node.offset)
      else
        raise Error.new("invalid or unknown expression", node.literal, node.offset)
      end
    end

    sig { params(operator: String, offset: Integer).returns(Type) }
    def type_of_operator(operator, offset)
      case operator
      when "!"
        Type.new(name: "bool", offset:)
      when "-"
        Type.new(name: "int", offset:)
      else
        raise Error.new("invalid or unknown operator '#{operator}'", operator, offset)
      end
    end
  end
end
