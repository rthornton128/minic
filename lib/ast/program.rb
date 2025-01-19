# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class Program
      include Node

      sig { returns(T::Array[Declaration]) }
      attr_reader :declarations

      sig { params(position: FileSet::Position).void }
      def initialize(position:)
        @declarations = T.let([], T::Array[Declaration])
        @position = position
      end

      sig { override.returns(FileSet::Position) }
      attr_reader :position

      sig { params(declaration: Declaration).returns(T.self_type) }
      def <<(declaration)
        @declarations << declaration
        self
      end

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        @declarations.each do |declaration|
          yield(declaration)
          declaration.walk(&block)
        end
      end
    end
  end
end
