# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class Parameter
      include Node

      sig { params(type: Keyword, identifier: Identifier).void }
      def initialize(type:, identifier:)
        @type = type
        @identifier = identifier
      end

      sig { returns(Keyword) }
      attr_reader :type

      sig { returns(Identifier) }
      attr_reader :identifier

      sig { override.returns(FileSet::Position) }
      def position
        @type.position
      end

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@type)
        yield(@identifier)
      end
    end
  end
end
