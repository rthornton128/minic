# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class UnaryExpression
      include Node

      # TODO: literal and position could be replaced with an Operator object.
      # This object could respond with boolean? or arithmetic? messages to
      # determine what kind of operator it is.
      sig { params(literal: String, position: FileSet::Position, expression: Expression).void }
      def initialize(literal:, position:, expression:)
        @literal = literal
        @position = position
        @rhs = expression
      end

      sig { returns(String) }
      attr_reader :literal

      sig { returns(Expression) }
      attr_reader :rhs

      sig { override.returns(FileSet::Position) }
      attr_reader :position

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@rhs)
        @rhs.walk(&block)
      end
    end
  end
end
