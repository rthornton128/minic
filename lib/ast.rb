# typed: true
# frozen_string_literal: true

require_relative "ast/node"
require_relative "ast/identifier"
require_relative "ast/boolean_literal"
require_relative "ast/double_literal"
require_relative "ast/integer_literal"
require_relative "ast/string_literal"
require_relative "ast/keyword"
require_relative "ast/binary_expression"
require_relative "ast/unary_expression"
require_relative "ast/function_decl"
require_relative "ast/variable_decl"
require_relative "ast/program"

module Minic
  class AbstractSyntaxTree
    Declaration = T.type_alias { T.any(FunctionDeclaration, VariableDeclaration) }
    Literal = T.type_alias { T.any(BooleanLiteral, DoubleLiteral, IntegerLiteral, StringLiteral) }
    SimpleExpression = T.type_alias { T.any(Literal, Identifier) }
    Expression = T.type_alias { T.any(SimpleExpression, BinaryExpression, UnaryExpression) }

    sig { returns(Program) }
    attr_accessor :program

    sig { params(program: Program).void }
    def initialize(program:)
      @program = T.let(program, Program)
    end

    sig { params(block: T.proc.params(node: Node).void).void }
    def walk(&block)
      yield(program)
      program.walk(&block)
    end
  end
end
