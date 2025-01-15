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

      program << parse_declarations until @lexer.eof?

      program
    end

    sig { returns(AbstractSyntaxTree::Declaration) }
    def parse_declarations
      type = parse_keyword
      identifier = parse_identifier
      assignment = parse_assignment if token.token == :Equal

      return parse_function_decl(type, identifier) if token.token == :LeftParen

      raise UnexpectedTokenError.new(
        "expected semicolon",
        token.literal,
        token.offset,
      ) unless token.token == :SemiColon

      AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment:)
    end

    sig { returns(AbstractSyntaxTree::Keyword) }
    def parse_keyword
      literal = token.literal
      offset = token.offset

      raise UnexpectedTokenError.new("expected type keyword", literal, offset) unless token.token == :Keyword

      next_token
      AbstractSyntaxTree::Keyword.new(literal:, offset:)
    end

    sig { returns(AbstractSyntaxTree::Identifier) }
    def parse_identifier
      literal = token.literal
      offset = token.offset

      raise UnexpectedTokenError.new("expected identifier", literal, offset) unless token.token == :Identifier

      next_token
      AbstractSyntaxTree::Identifier.new(literal:, offset:)
    end

    sig { returns(T.nilable(AbstractSyntaxTree::Expression)) }
    def parse_assignment
      next_token

      parse_expression
    end

    sig { returns(AbstractSyntaxTree::Expression) }
    def parse_expression
      return parse_unary if token.token == :Minus || token.token == :Exclamation
      return parse_sub if token.token == :LeftParen

      expression = parse_simple

      return parse_binary(lhs: expression) if token.operator?

      return parse_function_call(T.cast(
        expression,
        AbstractSyntaxTree::Identifier,
      )) if token.token == :LeftParen && expression.is_a?(AbstractSyntaxTree::Identifier)

      expression
    end

    sig { params(lhs: AbstractSyntaxTree::Expression).returns(AbstractSyntaxTree::BinaryExpression) }
    def parse_binary(lhs:)
      literal = token.literal
      offset = token.offset

      next_token

      rhs = parse_expression

      AbstractSyntaxTree::BinaryExpression.new(literal:, offset:, lhs:, rhs:)
    end

    sig { returns(AbstractSyntaxTree::SimpleExpression) }
    def parse_simple
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

    sig { params(identifier: AbstractSyntaxTree::Identifier).returns(AbstractSyntaxTree::FunctionCall) }
    def parse_function_call(identifier)
      arguments = parse_argument_list

      AbstractSyntaxTree::FunctionCall.new(identifier:, arguments:)
    end

    sig { returns(T::Array[AbstractSyntaxTree::Expression]) }
    def parse_argument_list
      raise UnexpectedTokenError.new(
        "expected closing parenthesis",
        token.literal,
        token.offset,
      ) unless token.token == :LeftParen
      next_token

      arguments = []
      until token.token == :RightParen || @lexer.eof?
        arguments << parse_expression
        next_token if token.token == :Comma
      end

      raise UnexpectedTokenError.new(
        "expected closing parenthesis",
        token.literal,
        token.offset,
      ) unless token.token == :RightParen
      next_token

      arguments
    end

    sig { returns(AbstractSyntaxTree::SubExpression) }
    def parse_sub
      opening = token.offset
      next_token

      expression = parse_expression

      raise UnexpectedTokenError.new(
        "expected closing parenthesis",
        token.literal,
        token.offset,
      ) unless token.token == :RightParen

      closing = token.offset
      next_token

      AbstractSyntaxTree::SubExpression.new(opening:, closing:, expression:)
    end

    sig { returns(AbstractSyntaxTree::UnaryExpression) }
    def parse_unary
      literal = token.literal
      offset = token.offset
      next_token

      expression = parse_expression

      AbstractSyntaxTree::UnaryExpression.new(literal:, offset:, expression:)
    end

    sig do
      params(
        type: AbstractSyntaxTree::Keyword,
        identifier: AbstractSyntaxTree::Identifier,
      ).returns(AbstractSyntaxTree::FunctionDeclaration)
    end
    def parse_function_decl(type, identifier)
      parameter_list = parse_parameter_list
      block = parse_block

      AbstractSyntaxTree::FunctionDeclaration.new(type:, identifier:, parameter_list:, block:)
    end

    sig { returns(AbstractSyntaxTree::ParameterList) }
    def parse_parameter_list
      opening = token.offset
      next_token

      parameters = []
      until token.token == :RightParen || @lexer.eof?
        parameters << parse_parameter
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
    def parse_parameter
      type = parse_keyword
      identifier = parse_identifier

      AbstractSyntaxTree::Parameter.new(type:, identifier:)
    end

    sig { returns(AbstractSyntaxTree::Block) }
    def parse_block
      opening = token.offset
      next_token

      statements = []
      until token.token == :RightBrace || @lexer.eof?
        statements << parse_statement

        raise UnexpectedTokenError.new(
          "statement must be terminated with a semicolon",
          token.literal,
          token.offset,
        ) unless token.token == :SemiColon

        next_token
      end

      closing = token.offset
      next_token

      AbstractSyntaxTree::Block.new(opening:, closing:, statements:)
    end

    sig { returns(AbstractSyntaxTree::Statement) }
    def parse_statement
      return parse_while if token.literal == "while"
      return parse_if if token.literal == "if"

      if token.token == :Identifier
        identifier = parse_identifier
        return parse_assignment_statement(identifier) if token.token == :Equal
        return parse_function_call(identifier) if token.token == :LeftParen

        raise UnexpectedTokenError.new("unexpected token", token.literal, token.offset)
      end

      raise UnexpectedTokenError.new("expected statement", token.literal, token.offset)
    end

    sig { params(lhs: AbstractSyntaxTree::Identifier).returns(AbstractSyntaxTree::AssignmentStatement) }
    def parse_assignment_statement(lhs)
      raise UnexpectedTokenError.new(
        "statement must be terminated with a semicolon",
        token.literal,
        token.offset,
      ) unless token.token == :Equal

      literal = token.literal
      offset = token.offset
      next_token

      rhs = parse_expression

      AbstractSyntaxTree::AssignmentStatement.new(literal:, offset:, lhs:, rhs:)
    end

    sig { returns(AbstractSyntaxTree::IfStatement) }
    def parse_if
      offset = token.offset
      next_token

      conditional = parse_conditional
      then_block = parse_block

      if token.literal == "else"
        next_token
        else_block = parse_block
      end

      AbstractSyntaxTree::IfStatement.new(offset:, conditional:, then_block:, else_block:)
    end

    sig { returns(AbstractSyntaxTree::WhileStatement) }
    def parse_while
      offset = token.offset
      next_token

      conditional = parse_conditional
      block = parse_block

      AbstractSyntaxTree::WhileStatement.new(offset:, conditional:, block:)
    end

    sig { returns(AbstractSyntaxTree::Expression) }
    def parse_conditional
      raise UnexpectedTokenError.new(
        "expected opening parenthesis",
        token.literal,
        token.offset,
      ) unless token.token == :LeftParen

      next_token

      expression = parse_expression

      raise UnexpectedTokenError.new(
        "expected closing parenthesis",
        token.literal,
        token.offset,
      ) unless token.token == :RightParen

      next_token

      expression
    end
  end
end
