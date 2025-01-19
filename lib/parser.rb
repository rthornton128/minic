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

    sig { params(types: Symbol).returns(T::Boolean) }
    def any?(*types)
      types.any? { |type| token.token == type }
    end

    sig { params(type: Symbol, literal: String).returns(Integer) }
    def expect(type, literal = "")
      name = literal.empty? ? type.to_s.downcase : literal
      raise UnexpectedTokenError.new(
        "expected #{name}",
        token.literal,
        token.offset,
      ) unless token.token == type || token.literal == literal

      token.offset.tap { next_token }
    end

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

      return parse_function_decl(type, identifier) if any?(:LeftParen)

      parse_variable_decl(type, identifier).tap { expect(:SemiColon) }
    end

    sig { returns(AbstractSyntaxTree::Keyword) }
    def parse_keyword
      literal = token.literal
      offset = token.offset

      expect(:Keyword)

      AbstractSyntaxTree::Keyword.new(literal:, offset:)
    end

    sig { returns(AbstractSyntaxTree::Identifier) }
    def parse_identifier
      literal = token.literal
      offset = token.offset

      expect(:Identifier)

      AbstractSyntaxTree::Identifier.new(literal:, offset:)
    end

    sig { returns(T.nilable(AbstractSyntaxTree::Expression)) }
    def parse_assignment
      expect(:Equal)

      parse_expression
    end

    sig { returns(AbstractSyntaxTree::Expression) }
    def parse_expression
      return parse_unary if any?(:Minus, :Exclamation)
      return parse_sub if any?(:LeftParen)

      expression = parse_simple

      return parse_binary(lhs: expression) if token.operator?

      return parse_function_call(T.cast(
        expression,
        AbstractSyntaxTree::Identifier,
      )) if any?(:LeftParen) && expression.is_a?(AbstractSyntaxTree::Identifier)

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
      expect(:LeftParen)

      arguments = []
      until any?(:RightParen) || @lexer.eof?
        arguments << parse_expression
        next_token if any?(:Comma)
      end

      expect(:RightParen)

      arguments
    end

    sig { returns(AbstractSyntaxTree::SubExpression) }
    def parse_sub
      opening = expect(:LeftParen)

      expression = parse_expression

      closing = expect(:RightParen)

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
      ).returns(AbstractSyntaxTree::VariableDeclaration)
    end
    def parse_variable_decl(type, identifier)
      assignment = parse_assignment if any?(:Equal)

      AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment:)
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
      opening = expect(:LeftParen)

      parameters = []
      until any?(:RightParen) || @lexer.eof?
        parameters << parse_parameter
        next_token if any?(:Comma)
      end

      closing = expect(:RightParen)

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
      opening = expect(:LeftBrace)

      statements = []
      until any?(:RightBrace) || @lexer.eof?
        statements << parse_statement
        expect(:SemiColon)
      end

      closing = expect(:RightBrace)

      AbstractSyntaxTree::Block.new(opening:, closing:, statements:)
    end

    sig { returns(AbstractSyntaxTree::Statement) }
    def parse_statement
      case token.literal
      when "if"
        return parse_if
      when "return"
        return parse_return
      when "while"
        return parse_while
      end

      if token.token == :Keyword
        type = parse_keyword
        identifier = parse_identifier

        return parse_variable_decl(type, identifier)
      end

      if token.token == :Identifier
        identifier = parse_identifier
        return parse_assignment_statement(identifier) if any?(:Equal)
        return parse_function_call(identifier) if any?(:LeftParen)

        raise UnexpectedTokenError.new("unexpected token", token.literal, token.offset)
      end

      raise UnexpectedTokenError.new("expected statement", token.literal, token.offset)
    end

    sig { params(lhs: AbstractSyntaxTree::Identifier).returns(AbstractSyntaxTree::AssignmentStatement) }
    def parse_assignment_statement(lhs)
      literal = token.literal
      offset = expect(:Equal)

      rhs = parse_expression

      AbstractSyntaxTree::AssignmentStatement.new(literal:, offset:, lhs:, rhs:)
    end

    sig { returns(AbstractSyntaxTree::IfStatement) }
    def parse_if
      offset = expect(:Keyword, "if")

      conditional = parse_conditional
      then_block = parse_block

      if token.literal == "else"
        next_token
        else_block = parse_block
      end

      AbstractSyntaxTree::IfStatement.new(offset:, conditional:, then_block:, else_block:)
    end

    sig { returns(AbstractSyntaxTree::ReturnStatement) }
    def parse_return
      offset = expect(:Keyword, "return")

      expression = parse_expression unless any?(:SemiColon) # rubocop:disable Style/InvertibleUnlessCondition

      AbstractSyntaxTree::ReturnStatement.new(literal: "return", offset:, expression:)
    end

    sig { returns(AbstractSyntaxTree::WhileStatement) }
    def parse_while
      offset = expect(:Keyword, "while")

      conditional = parse_conditional
      block = parse_block

      AbstractSyntaxTree::WhileStatement.new(offset:, conditional:, block:)
    end

    sig { returns(AbstractSyntaxTree::Expression) }
    def parse_conditional
      expect(:LeftParen)

      expression = parse_expression

      expect(:RightParen)

      expression
    end
  end
end
