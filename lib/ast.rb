# typed: true
# frozen_string_literal: true

require_relative "ast/node"
require_relative "ast/program"

module Minic
  class AbstractSyntaxTree
    sig { returns(Program) }
    attr_accessor :program

    sig { params(program: Program).void }
    def initialize(program:)
      @program = T.let(program, Program)
    end
  end
end
