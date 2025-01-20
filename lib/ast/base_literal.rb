# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class BaseLiteral
      include Node

      sig { params(literal: String, position: FileSet::Position).void }
      def initialize(literal:, position:)
        @literal = literal
        @position = position
      end

      sig { returns(String) }
      attr_reader :literal

      sig { override.returns(FileSet::Position) }
      attr_reader :position

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block); end
    end
  end
end
