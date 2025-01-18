# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class Block < Node
      sig { params(opening: Integer, closing: Integer, statements: T::Array[Statement]).void }
      def initialize(opening:, closing:, statements:)
        super()
        @opening = opening
        @closing = closing
        @statements = statements
      end

      sig { returns(T::Array[Statement]) }
      attr_reader :statements

      sig { params(statement: Statement).returns(T.self_type) }
      def <<(statement)
        @statements << statement
        self
      end

      sig { params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        @statements.each do |statement|
          yield(statement)
          statement.walk(&block)
        end
      end
    end
  end
end
