# typed: true
# frozen_string_literal: true

require_relative "semantic_analyzer/type"
require_relative "semantic_analyzer/basic_type"
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
      scope[var_decl.identifier.literal] = var_type

      unless var_decl.assignment.nil?
        expr_type = type_of(node: T.must(var_decl.assignment), scope:)
        assert_types(var_type, expr_type)
      end
    end

    sig { params(a: Type, b: Type).void }
    def assert_types(a, b)
      raise Error.new(
        "type missmatch #{a}, #{b}",
        "",
        b.offset,
      ) if a != b
    end

    sig { params(node: AbstractSyntaxTree::Node, scope: Scope).returns(Type) }
    def type_of(node:, scope:)
      case node
      when AbstractSyntaxTree::BooleanLiteral
        BasicType.new(name: "bool", offset: node.offset)
      when AbstractSyntaxTree::DoubleLiteral
        BasicType.new(name: "double", offset: node.offset)
      when AbstractSyntaxTree::StringLiteral
        BasicType.new(name: "string", offset: node.offset)
      when AbstractSyntaxTree::IntegerLiteral
        BasicType.new(name: "int", offset: node.offset)
      else
        BasicType.new(name: node.literal, offset: node.offset)
      end
    end
  end
end
