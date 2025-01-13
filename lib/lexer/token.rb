# typed: true
# frozen_string_literal: true

module Minic
  class Lexer
    class Token
      OPERATORS = [:Plus, :Minus, :Star, :FowardSlash, :Exclamation].freeze

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

      sig { returns(T::Boolean) }
      def operator?
        OPERATORS.include?(@token)
      end
    end
  end
end
