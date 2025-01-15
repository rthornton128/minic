# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class AssignmentStatement < Node
      sig { params(literal: String, offset: Integer, lhs: Identifier, rhs: Expression).void }
      def initialize(literal:, offset:, lhs:, rhs:)
        super(literal:, offset:)
        @lhs = lhs
        @rhs = rhs
      end

      sig { params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@lhs)
        @lhs.walk(&block)

        yield(@rhs)
        @rhs.walk(&block)
      end
    end
  end
end
