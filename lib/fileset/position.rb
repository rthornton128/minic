# typed: true
# frozen_string_literal: true

module Minic
  class FileSet
    class Position
      sig { returns(String) }
      attr_reader :name

      sig { returns(Integer) }
      attr_reader :row

      sig { returns(Integer) }
      attr_reader :column

      sig { params(name: String, row: Integer, column: Integer).void }
      def initialize(name:, row:, column:)
        @name = name
        @row = row
        @column = column
      end

      sig { returns(String) }
      def to_s
        "#{@name}: #{@row},#{@column}"
      end
    end
  end
end
