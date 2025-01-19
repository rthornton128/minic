# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class VariableDeclaration < Node
      sig { params(type: Keyword, identifier: Identifier, assignment: T.nilable(Expression)).void }
      def initialize(type:, identifier:, assignment: nil)
        super(literal: "", offset: type.offset)
        @type = type
        @identifier = identifier
        @assignment = assignment
      end

      sig { returns(T.nilable(Expression)) }
      attr_reader :assignment

      sig { returns(Identifier) }
      attr_reader :identifier

      sig { returns(Keyword) }
      attr_reader :type

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@type)
        yield(@identifier)

        if @assignment
          yield(@assignment)
          @assignment.walk(&block)
        end
      end
    end
  end
end
