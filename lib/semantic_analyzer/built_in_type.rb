# typed: true
# frozen_string_literal: true

module Minic
  class SemanticAnalyzer
    class BuiltInType < FunctionType
      sig { params(return_type: Type, param_types: T::Array[Type]).void }
      def initialize(return_type:, param_types:)
        super(return_type:, param_types:, built_in: true)
      end
    end
  end
end
