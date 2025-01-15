# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class ParameterList < Node
      sig { params(opening: Integer, closing: Integer, parameters: T::Array[Parameter]).void }
      def initialize(opening:, closing:, parameters:)
        super()
        @opening = opening
        @closing = closing
        @parameters = parameters
      end

      sig { params(parameter: Parameter).returns(T.self_type) }
      def <<(parameter)
        @parameters << parameter
        self
      end

      sig { params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        @parameters.each do |parameter|
          yield(parameter)
          parameter.walk(&block)
        end
      end
    end
  end
end
