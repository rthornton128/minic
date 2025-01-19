# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class FunctionCall
      include Node
      sig { params(identifier: Identifier, arguments: T::Array[Expression]).void }
      def initialize(identifier:, arguments:)
        @identifier = identifier
        @arguments = arguments
      end

      sig { returns(Identifier) }
      attr_reader :identifier

      sig { returns(T::Array[Expression]) }
      attr_reader :arguments

      sig { override.returns(FileSet::Position) }
      def position
        @identifier.position
      end

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@identifier)
        @identifier.walk(&block)

        @arguments.each do |argument|
          yield(argument)
          argument.walk(&block)
        end
      end
    end
  end
end
