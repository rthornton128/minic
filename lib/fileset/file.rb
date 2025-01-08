# typed: true
# frozen_string_literal: true

require_relative "position"

module Minic
  class FileSet
    class File
      sig { returns(String) }
      attr_reader :body

      sig { params(body: String, name: String).void }
      def initialize(body: "", name: "unknown")
        @body = body
        @name = name
        @lines = T.let([0], T::Array[Integer]) # offsets of new lines
      end

      sig { params(offset: Integer).returns(T.self_type) }
      def <<(offset)
        @lines << offset
        self
      end

      sig { params(offset: Integer).returns(Position) }
      def position(offset)
        Position.new(name: @name, row: row(offset), column: column(offset))
      end

      sig { returns(Integer) }
      def size
        @body.size
      end

      private

      sig { params(offset: Integer).returns(Integer) }
      def row(offset)
        @lines.each_with_index do |line, index|
          return index + 1 if line >= offset
        end

        return @lines.size if offset < size

        raise FileSet::InvalidOffsetError, "offset not within file"
      end

      sig { params(offset: Integer).returns(Integer) }
      def column(offset)
        row_offset = row(offset)
        return offset + 1 if row_offset == 1

        (offset - row_offset) + 1
      end
    end
  end
end
