# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class SubExpression
      include Node

      sig { params(opening: FileSet::Position, closing: FileSet::Position, expression: Expression).void }
      def initialize(opening:, closing:, expression:)
        @position = opening
        @closing = closing
        @expression = expression
      end

      sig { returns(Expression) }
      attr_reader :expression

      sig { override.returns(FileSet::Position) }
      attr_reader :position

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@expression)
        @expression.walk(&block)
      end
    end
  end
end
