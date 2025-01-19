# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class AssignmentStatement
      include Node

      sig { params(equal_pos: FileSet::Position, lhs: Identifier, rhs: Expression).void }
      def initialize(equal_pos:, lhs:, rhs:)
        @position = equal_pos
        @lhs = lhs
        @rhs = rhs
      end

      sig { override.returns(FileSet::Position) }
      attr_reader :position

      sig { returns(Identifier) }
      attr_reader :lhs

      sig { returns(Expression) }
      attr_reader :rhs

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
