# typed: true
# frozen_string_literal: true

require_relative "fileset/file"
require_relative "fileset/position"

module Minic
  class FileSet
    class InvalidOffsetError < StandardError; end

    sig { void }
    def initialize
      @files = T.let([], T::Array[File])
    end

    sig { params(file: File).returns(T.self_type) }
    def <<(file)
      @files << file
      self
    end

    sig { params(offset: Integer).returns(Position) }
    def position(offset)
      sum = 0
      @files.each do |file|
        return file.position(offset - sum) if file.size + sum <= offset

        sum += file.size
      end

      raise InvalidOffsetError, "Offset is invalid"
    end
  end
end
