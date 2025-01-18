# typed: true
# frozen_string_literal: true

module Minic
  class SemanticAnalyzer
    class Scope
      sig { params(parent: T.nilable(Scope)).void }
      def initialize(parent:)
        @parent = T.let(parent, T.nilable(Scope))
        @symbols = T.let({}, T::Hash[String, Type])
      end

      sig { params(identifier: String, type: Type).returns(Type) }
      def []=(identifier, type)
        raise Error.new("identifier redefined", identifier, type.offset) unless @symbols[identifier].nil?

        @symbols[identifier] = type
      end

      sig { params(identifier: String).returns(T.nilable(Type)) }
      def [](identifier)
        return @symbols[identifier] unless @symbols[identifier].nil?

        @parent&.[](identifier)
      end
    end
  end
end
