# typed: true
# frozen_string_literal: true

require "ast"

module Minic
  class Parser
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
      AbstractSyntaxTree::Program.new(literal: "", offset: 0)
    end
  end
end
