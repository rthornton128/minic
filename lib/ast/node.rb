# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    module Node
      extend T::Helpers

      interface!

      sig { abstract.returns(FileSet::Position) }
      def position; end

      sig { abstract.params(block: T.proc.params(node: Node).void).void }
      def walk(&block); end
    end
  end
end
