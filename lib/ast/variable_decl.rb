# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class VariableDeclaration < Node
      sig { params(type: Keyword, identifier: Identifier).void }
      def initialize(type:, identifier:)
        super(literal: "", offset: type.offset)
        @type = type
        @identifier = identifier
      end

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@type)
        yield(@identifier)
      end
    end
  end
end
