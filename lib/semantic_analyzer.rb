# typed: true
# frozen_string_literal: true

module Minic
  class SemanticAnalyzer
    class Error < ::Minic::Error; end

    sig { params(ast: AbstractSyntaxTree).void }
    def initialize(ast:)
      @ast = ast
    end

    sig { void }
    def analyze
      analyze_program(program: @ast.program)
    end

    sig { params(program: AbstractSyntaxTree::Program).void }
    def analyze_program(program:)
      raise Error.new(
        "no entry point; program can't be empty",
        program.literal,
        program.offset,
      ) if program.declarations.empty?
    end
  end
end
