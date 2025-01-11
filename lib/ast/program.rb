# typed: true
# frozen_string_literal: true

module Minic
  class AbstractSyntaxTree
    Declaration = T.type_alias { T.any(FunctionDeclaration, VariableDeclaration) }

    class Program < Node
      sig { params(literal: String, offset: Integer).void }
      def initialize(literal: "", offset: 0)
        super
        @declarations = T.let([], T::Array[Declaration])
      end

      sig { params(declaration: Declaration).returns(T.self_type) }
      def <<(declaration)
        @declarations << declaration
        self
      end

      sig { override.params(block: T.proc.params(node: Node).void).void }
      def walk(&block)
        @declarations.each do |declaration|
          yield(declaration)
          declaration.walk(&block)
        end
      end
    end
  end
end
