# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class FunctionDeclaration < Node
      sig { void }
      def initialize
        super(literal: "", offset: 0)
      end

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
      end
    end
  end
end
