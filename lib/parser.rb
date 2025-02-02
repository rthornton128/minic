# typed: true
# frozen_string_literal: true

require_relative "ast"

module Minic
  class Parser
    class UnexpectedTokenError < Error; end

    sig { params(lexer: Lexer, ast: T.nilable(AbstractSyntaxTree)).void }
    def initialize(lexer:, ast: nil)
      @lexer = lexer
      @token = T.let(next_token, Lexer::Token)
      @ast = T.let(ast || empty_abstract_syntax_tree, AbstractSyntaxTree)
    end

    sig { returns(AbstractSyntaxTree) }
    def empty_abstract_syntax_tree
      AbstractSyntaxTree.new(program: AbstractSyntaxTree::Program.new(position: @lexer.file.position(0)))
    end

    sig { returns(AbstractSyntaxTree) }
    def parse
      @ast.program << parse_declarations until @lexer.eof?
      @ast
    end

    private

    sig { returns(Lexer::Token) }
    attr_reader :token

    sig { params(types: Symbol).returns(T::Boolean) }
    def any?(*types)
      types.any? { |type| token.token == type }
    end

    sig { params(type: Symbol, literal: String).returns(FileSet::Position) }
    def expect(type, literal = "")
      name = literal.empty? ? type.to_s.downcase : literal
      raise UnexpectedTokenError.new(
        "expected #{name}, got: '#{token.literal}'",
        position: token.position,
      ) unless token.token == type || token.literal == literal

      token.position.tap { next_token }
    end

    sig { returns(Lexer::Token) }
    def next_token
      @token = @lexer.scan
      if any?(:Comment)
        next_token
      else
        @token
      end
    end

    sig { returns(AbstractSyntaxTree::Declaration) }
    def parse_declarations
      type = parse_keyword
      identifier = parse_identifier

      return parse_function_decl(type, identifier) if any?(:LeftParen)

      parse_variable_decl(type, identifier)
    end

    sig { returns(AbstractSyntaxTree::Keyword) }
    def parse_keyword
      literal = token.literal
      position = token.position

      expect(:Keyword)

      AbstractSyntaxTree::Keyword.new(literal:, position:)
    end

    sig { returns(AbstractSyntaxTree::Identifier) }
    def parse_identifier
      literal = token.literal
      position = token.position

      expect(:Identifier)

      AbstractSyntaxTree::Identifier.new(literal:, position:)
    end

    sig { returns(T.nilable(AbstractSyntaxTree::Expression)) }
    def parse_assignment
      expect(:Equal)

      parse_expression
    end

    sig { returns(AbstractSyntaxTree::Expression) }
    def parse_expression
      expression = parse_unary if any?(:Minus, :Exclamation)
      expression = parse_sub if any?(:LeftParen)
      expression = parse_simple if expression.nil?

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
      position = token.position

      next_token

      rhs = parse_expression

      AbstractSyntaxTree::BinaryExpression.new(literal:, position:, lhs:, rhs:)
    end

    sig { returns(AbstractSyntaxTree::SimpleExpression) }
    def parse_simple
      literal = token.literal
      position = token.position
      type = token.token

      next_token

      case type
      when :Boolean
        AbstractSyntaxTree::BooleanLiteral.new(literal:, position:)
      when :Double
        AbstractSyntaxTree::DoubleLiteral.new(literal:, position:)
      when :Integer
        AbstractSyntaxTree::IntegerLiteral.new(literal:, position:)
      when :String
        AbstractSyntaxTree::StringLiteral.new(literal:, position:)
      when :Identifier
        AbstractSyntaxTree::Identifier.new(literal:, position:)
      else
        raise UnexpectedTokenError.new("expected expression", literal, position:)
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
      position = token.position
      next_token

      expression = parse_expression

      AbstractSyntaxTree::UnaryExpression.new(literal:, position:, expression:)
    end

    sig do
      params(
        type: AbstractSyntaxTree::Keyword,
        identifier: AbstractSyntaxTree::Identifier,
      ).returns(AbstractSyntaxTree::VariableDeclaration)
    end
    def parse_variable_decl(type, identifier)
      assignment = parse_assignment if any?(:Equal)
      expect(:SemiColon)

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
      statements << parse_statement until any?(:RightBrace) || @lexer.eof?

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
        return parse_function_call(identifier).tap { expect(:SemiColon) } if any?(:LeftParen)

        raise UnexpectedTokenError.new("unexpected token", token.literal, position: token.position)
      end

      raise UnexpectedTokenError.new("expected statement", token.literal, position: token.position)
    end

    sig { params(lhs: AbstractSyntaxTree::Identifier).returns(AbstractSyntaxTree::AssignmentStatement) }
    def parse_assignment_statement(lhs)
      equal_pos = expect(:Equal)

      rhs = parse_expression
      expect(:SemiColon)

      AbstractSyntaxTree::AssignmentStatement.new(equal_pos:, lhs:, rhs:)
    end

    sig { returns(AbstractSyntaxTree::IfStatement) }
    def parse_if
      if_pos = expect(:Keyword, "if")

      conditional = parse_conditional
      then_block = parse_block

      if token.literal == "else"
        next_token
        else_block = parse_block
      end

      AbstractSyntaxTree::IfStatement.new(if_pos:, conditional:, then_block:, else_block:)
    end

    sig { returns(AbstractSyntaxTree::ReturnStatement) }
    def parse_return
      return_pos = expect(:Keyword, "return")

      expression = parse_expression unless any?(:SemiColon) # rubocop:disable Style/InvertibleUnlessCondition
      expect(:SemiColon)

      AbstractSyntaxTree::ReturnStatement.new(return_pos:, expression:)
    end

    sig { returns(AbstractSyntaxTree::WhileStatement) }
    def parse_while
      while_pos = expect(:Keyword, "while")

      conditional = parse_conditional
      block = parse_block

      AbstractSyntaxTree::WhileStatement.new(while_pos:, conditional:, block:)
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
