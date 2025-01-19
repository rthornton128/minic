# typed: true
# frozen_string_literal: true

module Minic
  class Lexer
    class Token
      OPERATORS = [
        :Plus,
        :Minus,
        :Star,
        :ForwardSlash,
        :Exclamation,
        :Percent,
        :And,
        :Or,
        :Equality,
        :LessThan,
        :GreaterThan,
      ].freeze

      sig { returns(Symbol) }
      attr_reader :token

      sig { returns(String) }
      attr_reader :literal

      sig { returns(Integer) }
      attr_reader :offset

      sig { returns(FileSet::Position) }
      attr_reader :position

      sig { params(token: Symbol, literal: String, position: FileSet::Position).void }
      def initialize(token:, literal:, position:)
        @token = token
        @literal = literal
        @offset = T.let(0, Integer)
        @position = position
      end

      sig { returns(T::Boolean) }
      def operator?
        OPERATORS.include?(@token)
      end
    end
  end
end
