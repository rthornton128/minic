# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class SubExpression < Node
      sig { params(opening: Integer, closing: Integer, expression: Expression).void }
      def initialize(opening:, closing:, expression:)
        super()
        @opening = opening
        @closing = closing
        @expression = expression
      end

      sig { returns(Expression) }
      attr_reader :expression

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@expression)
        @expression.walk(&block)
      end
    end
  end
end
