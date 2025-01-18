# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class IfStatement < Node
      sig { params(offset: Integer, conditional: Expression, then_block: Block, else_block: T.nilable(Block)).void }
      def initialize(offset:, conditional:, then_block:, else_block: nil)
        super(literal: "where", offset:)
        @conditional = conditional
        @then_block = then_block
        @else_block = else_block
      end

      sig { returns(Expression) }
      attr_reader :conditional

      sig { returns(Block) }
      attr_reader :then_block

      sig { returns(T.nilable(Block)) }
      attr_reader :else_block

      sig { params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@conditional)
        @conditional.walk(&block)

        yield(@then_block)
        @then_block.walk(&block)

        if @else_block
          yield(@else_block)
          @else_block.walk(&block)
        end
      end
    end
  end
end
