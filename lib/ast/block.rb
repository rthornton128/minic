# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class Block
      include Node

      sig { params(opening: FileSet::Position, closing: FileSet::Position, statements: T::Array[Statement]).void }
      def initialize(opening:, closing:, statements:)
        @opening = opening
        @closing = closing
        @statements = statements
      end

      sig { override.returns(FileSet::Position) }
      def position
        @opening
      end

      sig { returns(T::Array[Statement]) }
      attr_reader :statements

      sig { params(statement: Statement).returns(T.self_type) }
      def <<(statement)
        @statements << statement
        self
      end

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        @statements.each do |statement|
          yield(statement)
          statement.walk(&block)
        end
      end
    end
  end
end
