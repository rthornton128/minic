# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class ReturnStatement
      include Node
      sig { params(return_pos: FileSet::Position, expression: T.nilable(Expression)).void }
      def initialize(return_pos:, expression:)
        @expression = expression
        @position = return_pos
      end

      sig { returns(T.nilable(Expression)) }
      attr_reader :expression

      sig { override.returns(FileSet::Position) }
      attr_reader :position

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        return if @expression.nil?

        yield(@expression)
        @expression.walk(&block)
      end
    end
  end
end
