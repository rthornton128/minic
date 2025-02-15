# typed: true
# frozen_string_literal: true

module Minic
  class SemanticAnalyzer
    class Type
      TYPES = [:bool, :double, :int, :string, :void].freeze

      sig { params(name: String, position: FileSet::Position).void }
      def initialize(name:, position:)
        @name = name
        @position = position
      end

      sig { returns(String) }
      attr_reader :name

      sig { returns(FileSet::Position) }
      attr_reader :position

      sig { params(other: Type).returns(T::Boolean) }
      def ==(other)
        name == other.name
      end

      sig { returns(T::Boolean) }
      def void?
        @name == "void"
      end

      sig { returns(T::Boolean) }
      def valid?
        TYPES.include?(@name.to_sym)
      end

      sig { returns(String) }
      def to_s
        @name
      end
    end
  end
end
