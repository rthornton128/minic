# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class ParameterList
      include Node

      sig { params(opening: FileSet::Position, closing: FileSet::Position, parameters: T::Array[Parameter]).void }
      def initialize(opening:, closing:, parameters:)
        @opening = opening
        @closing = closing
        @parameters = parameters
      end

      sig { returns(T::Array[Parameter]) }
      attr_reader :parameters

      sig { override.returns(FileSet::Position) }
      def position
        @opening
      end

      sig { params(parameter: Parameter).returns(T.self_type) }
      def <<(parameter)
        @parameters << parameter
        self
      end

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        @parameters.each do |parameter|
          yield(parameter)
          parameter.walk(&block)
        end
      end
    end
  end
end
