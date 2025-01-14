# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    class FunctionDeclaration < Node
      sig { params(type: Keyword, identifier: Identifier, parameter_list: ParameterList, block: Block).void }
      def initialize(type:, identifier:, parameter_list:, block:)
        super()
        @type = type
        @identifer = identifier
        @parameter_list = parameter_list
        @block = block
      end

      sig { params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        yield(@type)
        yield(@identifer)

        yield(@parameter_list)
        @parameter_list.walk(&block)

        yield(@block)
        @block.walk(&block)
      end
    end
  end
end
