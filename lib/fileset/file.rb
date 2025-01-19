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

        # TODO: Think if this makes sense... when we're at EOF, the offset
        # will be +1, the size of the body. This is might be a bug because
        # if we've reached the EOF, the offset should be returned back to
        # the last valid position, length - 1. If true, this change should be
        # reverted and the lexer fixed.
        return @lines.size if offset <= size

        raise FileSet::InvalidOffsetError, "offset not within file"
      end

      sig { params(offset: Integer).returns(Integer) }
      def column(offset)
        row = row(offset)
        row_offset = @lines.fetch(row - 1)
        return offset + 1 if row_offset == 1

        (offset - row_offset) + 1
      end
    end
  end
end
