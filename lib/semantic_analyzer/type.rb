# typed: true
# frozen_string_literal: true

module Minic
  class SemanticAnalyzer
    class Type
      extend T::Helpers

      abstract!

      sig { params(name: String, offset: Integer).void }
      def initialize(name:, offset:)
        @name = name
        @offset = offset
      end

      sig { returns(String) }
      attr_reader :name

      sig { returns(Integer) }
      attr_reader :offset

      sig { abstract.params(other: Type).returns(T::Boolean) }
      def ==(other); end
    end
  end
end
