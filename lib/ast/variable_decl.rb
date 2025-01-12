# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class VariableDeclaration < Node
      sig { params(type: Keyword, identifier: Identifier, assignment: T.nilable(Node)).void }
      def initialize(type:, identifier:, assignment: nil)
        super(literal: "", offset: type.offset)
        @type = type
        @identifier = identifier
        @assignment = assignment
      end

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@type)
        yield(@identifier)
        yield(@assignment) if @assignment
      end
    end
  end
end
