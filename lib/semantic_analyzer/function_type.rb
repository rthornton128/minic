# typed: true
# frozen_string_literal: true

module Minic
  class SemanticAnalyzer
    class FunctionType < Type
      sig { params(return_type: Type, param_types: T::Array[Type]).void }
      def initialize(return_type:, param_types:)
        super(name: return_type.name, position: return_type.position)
        @param_types = param_types
      end

      sig { returns(T::Array[Type]) }
      attr_reader :param_types
    end
  end
end
