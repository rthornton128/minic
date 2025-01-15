# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class WhileStatement < Node
      sig { params(offset: Integer, conditional: Expression, block: Block).void }
      def initialize(offset:, conditional:, block:)
        super(literal: "where", offset:)
        @conditional = conditional
        @block = block
      end

      sig { params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@conditional)
        @conditional.walk(&block)

        yield(@block)
        @block.walk(&block)
      end
    end
  end
end
