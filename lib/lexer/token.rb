# typed: true
# frozen_string_literal: true

module Minic
  class Lexer
    class Token
      sig { returns(Symbol) }
      attr_reader :token

      sig { returns(String) }
      attr_reader :literal

      sig { returns(Integer) }
      attr_reader :offset

      sig { params(token: Symbol, literal: String, offset: Integer).void }
      def initialize(token:, literal:, offset:)
        @token = token
        @literal = literal
        @offset = offset
      end
    end
  end
end
