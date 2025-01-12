# typed: true
# frozen_string_literal: true

module Minic
  class Error < StandardError
    sig { returns(String) }
    attr_reader :literal

    sig { returns(Integer) }
    attr_reader :offset

    sig { params(message: String, literal: String, offset: Integer).void }
    def initialize(message, literal, offset)
      super(message)

      @literal = literal
      @offset = offset
    end
  end
end
