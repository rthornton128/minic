# typed: true
# frozen_string_literal: true

module Minic
  class SemanticAnalyzer
    class BasicType < Type
      TYPES = [:bool, :double, :int, :string, :void].freeze

      sig { override.params(other: Type).returns(T::Boolean) }
      def ==(other)
        other.instance_of?(self.class) && name == other.name
      end

      sig { returns(T::Boolean) }
      def valid?
        TYPES.include?(@name.to_sym)
      end
    end
  end
end
