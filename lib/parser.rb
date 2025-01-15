# typed: true
# frozen_string_literal: true

require "ast"

module Minic
  class Parser
    class UnexpectedTokenError < Error; end

    sig { params(lexer: Lexer).void }
    def initialize(lexer:)
      @lexer = lexer
      @token = T.let(lexer.scan, Lexer::Token)
    end

    sig { returns(AbstractSyntaxTree) }
    def parse
      AbstractSyntaxTree.new(program: parse_program)
    end

    private

    sig { returns(Lexer::Token) }
    attr_reader :token

    sig { returns(Lexer::Token) }
    def next_token
      @token = @lexer.scan
    end

    sig { returns(AbstractSyntaxTree::Program) }
    def parse_program
      program = AbstractSyntaxTree::Program.new

      program << scan_declarations until @lexer.eof?

      program
    end

    sig { returns(AbstractSyntaxTree::Declaration) }
    def scan_declarations
      type = scan_keyword
      identifier = scan_identifier
      assignment = scan_assignment if token.token == :Equal

      return scan_function_decl(type, identifier) if token.token == :LeftParen

      raise UnexpectedTokenError.new(
        "expected semicolon",
        token.literal,
        token.offset,
      ) unless token.token == :SemiColon

      AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment:)
    end

    sig { returns(AbstractSyntaxTree::Keyword) }
    def scan_keyword
      literal = token.literal
      offset = token.offset

      raise UnexpectedTokenError.new("expected type keyword", literal, offset) unless token.token == :Keyword

      next_token
      AbstractSyntaxTree::Keyword.new(literal:, offset:)
    end

    sig { returns(AbstractSyntaxTree::Identifier) }
    def scan_identifier
      literal = token.literal
      offset = token.offset

      raise UnexpectedTokenError.new("expected identifier", literal, offset) unless token.token == :Identifier

      next_token
      AbstractSyntaxTree::Identifier.new(literal:, offset:)
    end

    sig { returns(T.nilable(AbstractSyntaxTree::Expression)) }
    def scan_assignment
      next_token

      scan_expression
    end

    sig { returns(AbstractSyntaxTree::Expression) }
    def scan_expression
      return scan_unary if token.token == :Minus || token.token == :Exclamation

      expression = scan_simple

      return scan_binary(lhs: expression) if token.operator?

      expression
    end

    sig { params(lhs: AbstractSyntaxTree::Expression).returns(AbstractSyntaxTree::BinaryExpression) }
    def scan_binary(lhs:)
      literal = token.literal
      offset = token.offset

      next_token

      rhs = scan_expression

      AbstractSyntaxTree::BinaryExpression.new(literal:, offset:, lhs:, rhs:)
    end

    sig { returns(AbstractSyntaxTree::SimpleExpression) }
    def scan_simple
      literal = token.literal
      offset = token.offset
      type = token.token

      next_token

      case type
      when :Boolean
        AbstractSyntaxTree::BooleanLiteral.new(literal:, offset:)
      when :Double
        AbstractSyntaxTree::DoubleLiteral.new(literal:, offset:)
      when :Integer
        AbstractSyntaxTree::IntegerLiteral.new(literal:, offset:)
      when :String
        AbstractSyntaxTree::StringLiteral.new(literal:, offset:)
      when :Identifier
        AbstractSyntaxTree::Identifier.new(literal:, offset:)
      else
        raise UnexpectedTokenError.new("expected expression", literal, offset)
      end
    end

    sig { returns(AbstractSyntaxTree::UnaryExpression) }
    def scan_unary
      literal = token.literal
      offset = token.offset
      next_token

      expression = scan_expression

      AbstractSyntaxTree::UnaryExpression.new(literal:, offset:, expression:)
    end

    sig do
      params(
        type: AbstractSyntaxTree::Keyword,
        identifier: AbstractSyntaxTree::Identifier,
      ).returns(AbstractSyntaxTree::FunctionDeclaration)
    end
    def scan_function_decl(type, identifier)
      parameter_list = scan_parameter_list
      block = scan_block

      AbstractSyntaxTree::FunctionDeclaration.new(type:, identifier:, parameter_list:, block:)
    end

    sig { returns(AbstractSyntaxTree::ParameterList) }
    def scan_parameter_list
      opening = token.offset
      next_token

      parameters = []
      until token.token == :RightParen || @lexer.eof?
        parameters << scan_parameter
        next_token if token.token == :Comma
      end

      raise UnexpectedTokenError.new(
        "expected closing parenthesis",
        token.literal,
        token.offset,
      ) unless token.token == :RightParen

      closing = token.offset
      next_token

      AbstractSyntaxTree::ParameterList.new(opening:, closing:, parameters:)
    end

    sig { returns(AbstractSyntaxTree::Parameter) }
    def scan_parameter
      type = scan_keyword
      identifier = scan_identifier

      AbstractSyntaxTree::Parameter.new(type:, identifier:)
    end

    sig { returns(AbstractSyntaxTree::Block) }
    def scan_block
      opening = token.offset
      next_token

      statements = []
      # statements << scan_statement until token.token == :RightBrace

      closing = token.offset
      next_token

      AbstractSyntaxTree::Block.new(opening:, closing:, statements:)
    end
  end
end
