# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class FunctionCall < Node
      sig { params(identifier: Identifier, arguments: T::Array[Expression]).void }
      def initialize(identifier:, arguments:)
        super()
        @identifier = identifier
        @arguments = arguments
      end

      sig { params(block: T.proc.params(node: Node).void).void }
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
