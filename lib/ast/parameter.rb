# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class Parameter < Node
      sig { params(type: Keyword, identifier: Identifier).void }
      def initialize(type:, identifier:)
        super()
        @type = type
        @identifier = identifier
      end

      sig { returns(Keyword) }
      attr_reader :type

      sig { returns(Identifier) }
      attr_reader :identifier

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@type)
        yield(@identifier)
      end
    end
  end
end
