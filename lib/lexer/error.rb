# typed: true
# frozen_string_literal: true

module Minic
  class Lexer
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

    class InvalidTokenError < Error; end
    class InvalidIntegerError < Error; end
    class UnterminatedStringError < Error; end
  end
end
