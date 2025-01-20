# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class WhileStatement
      include Node

      sig { params(while_pos: FileSet::Position, conditional: Expression, block: Block).void }
      def initialize(while_pos:, conditional:, block:)
        @position = while_pos
        @conditional = conditional
        @block = block
      end

      sig { returns(Expression) }
      attr_reader :conditional

      sig { returns(Block) }
      attr_reader :block

      sig { override.returns(FileSet::Position) }
      attr_reader :position

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@conditional)
        @conditional.walk(&block)

        yield(@block)
        @block.walk(&block)
      end
    end
  end
end
