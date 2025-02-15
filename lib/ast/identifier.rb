# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class Identifier
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

      class << self
        sig { params(token: Lexer::Token).returns(T.attached_class) }
        def from(token)
          new(literal: token.literal, position: token.position)
        end
      end
    end
  end
end
