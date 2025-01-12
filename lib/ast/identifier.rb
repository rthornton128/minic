# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class Identifier < Node
      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block); end
    end
  end
end
