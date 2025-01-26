# typed: true
# frozen_string_literal: true

module Minic
  class SemanticAnalyzer
    class FunctionType < Type
      sig { params(return_type: Type, param_types: T::Array[Type], built_in: T::Boolean).void }
      def initialize(return_type:, param_types:, built_in: false)
        super(name: return_type.name, position: return_type.position)
        @built_in = built_in
        @param_types = param_types
      end

      sig { returns(T::Array[Type]) }
      attr_reader :param_types

      sig { returns(T::Boolean) }
      def built_in?
        @built_in
      end
    end
  end
end
