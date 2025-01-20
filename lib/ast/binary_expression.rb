# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class BinaryExpression
      include Node
      sig { params(literal: String, position: FileSet::Position, lhs: Expression, rhs: Expression).void }
      def initialize(literal:, position:, lhs:, rhs:)
        @lhs = lhs
        @literal = literal
        @position = position
        @rhs = rhs
      end

      sig { returns(Expression) }
      attr_reader :lhs, :rhs

      sig { returns(String) }
      attr_reader :literal

      sig { override.returns(FileSet::Position) }
      def position
        @lhs.position
      end

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@lhs)
        @lhs.walk(&block)

        yield(@rhs)
        @rhs.walk(&block)
      end
    end
  end
end
