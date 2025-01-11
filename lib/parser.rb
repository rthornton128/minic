# typed: true
# frozen_string_literal: true

require "ast"

module Minic
  class Parser
    class Error < StandardError; end
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
      raise UnexpectedTokenError, "expected semicolon, got: #{token.literal}" unless token.token == :SemiColon

      AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:)
    end

    sig { returns(AbstractSyntaxTree::Keyword) }
    def scan_keyword
      token = @lexer.scan
      raise UnexpectedTokenError, "expected type keyword, got: #{token.literal}" unless token.token == :Keyword

      AbstractSyntaxTree::Keyword.new(literal: token.literal, offset: token.offset)
    end

    sig { returns(AbstractSyntaxTree::Identifier) }
    def scan_identifier
      token = @lexer.scan
      raise UnexpectedTokenError, "expected identifier, got: #{token.literal}" unless token.token == :Identifier

      AbstractSyntaxTree::Identifier.new(literal: token.literal, offset: token.offset)
    end
  end
end
