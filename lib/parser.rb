# typed: true
# frozen_string_literal: true

require "ast"

module Minic
  class Parser
    class UnexpectedTokenError < Error; end

    sig { params(lexer: Lexer).void }
    def initialize(lexer:)
      @lexer = lexer
    end

    sig { returns(AbstractSyntaxTree) }
    def parse
      AbstractSyntaxTree.new(program: parse_program)
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

      token = @lexer.scan
      assignment = scan_assignment(token)

      token = @lexer.scan if assignment
      raise UnexpectedTokenError.new(
        "expected semicolon, got: #{token.literal}",
        token.literal,
        token.offset,
      ) unless token.token == :SemiColon

      AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment:)
    end

    sig { returns(AbstractSyntaxTree::Keyword) }
    def scan_keyword
      token = @lexer.scan
      raise UnexpectedTokenError.new(
        "expected type keyword",
        token.literal,
        token.offset,
      ) unless token.token == :Keyword

      AbstractSyntaxTree::Keyword.new(literal: token.literal, offset: token.offset)
    end

    sig { returns(AbstractSyntaxTree::Identifier) }
    def scan_identifier
      token = @lexer.scan
      raise UnexpectedTokenError.new(
        "expected identifier",
        token.literal,
        token.offset,
      ) unless token.token == :Identifier

      AbstractSyntaxTree::Identifier.new(literal: token.literal, offset: token.offset)
    end

    sig { params(token: Lexer::Token).returns(T.nilable(AbstractSyntaxTree::Expression)) }
    def scan_assignment(token)
      return unless token.token == :Equal

      scan_expression
    end

    sig { returns(AbstractSyntaxTree::Expression) }
    def scan_expression
      token = @lexer.scan
      case token.token
      when :Boolean
        AbstractSyntaxTree::BooleanLiteral.new(literal: token.literal, offset: token.offset)
      when :Double
        AbstractSyntaxTree::DoubleLiteral.new(literal: token.literal, offset: token.offset)
      when :Integer
        AbstractSyntaxTree::IntegerLiteral.new(literal: token.literal, offset: token.offset)
      when :String
        AbstractSyntaxTree::StringLiteral.new(literal: token.literal, offset: token.offset)
      when :Identifier
        AbstractSyntaxTree::Identifier.new(literal: token.literal, offset: token.offset)
      else
        raise UnexpectedTokenError.new("expected expression", token.literal, token.offset)
      end
    end
  end
end
