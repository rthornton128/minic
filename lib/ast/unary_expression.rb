# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class UnaryExpression < Node
      sig { params(literal: String, offset: Integer, expression: Expression).void }
      def initialize(literal:, offset:, expression:)
        super(literal:, offset:)
        @rhs = expression
      end

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@rhs)
        @rhs.walk(&block)
      end
    end
  end
end
