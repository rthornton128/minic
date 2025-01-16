# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class ReturnStatement < Node
      sig { params(literal: String, offset: Integer, expression: T.nilable(Expression)).void }
      def initialize(literal:, offset:, expression:)
        super(literal:, offset:)
        @expression = expression
      end

      sig { params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        return if @expression.nil?

        yield(@expression)
        @expression.walk(&block)
      end
    end
  end
end
