# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class FileTest < TestCase
    test "name defaults to unknown" do
      file = FileSet::File.new
      assert_equal("unknown", file.position(0).name)
    end

    test "size returns the length of the body" do
      file = FileSet::File.new(body: "body")
      assert_equal(4, file.size)
    end

    test "position returns the correct row and column for an offset" do
      file = FileSet::File.new
      file << 1
      assert(2, file.position(1).row)
      assert(1, file.position(1).column)
    end

    test "position raises InvalidOffsetError if offset is out of bounds" do
      file = FileSet::File.new
      assert_raises(FileSet::InvalidOffsetError) do
        file.position(1)
      end
    end

    test "file with newline on first line" do
      file = FileSet::File.new(body: "\nint a;")
      file << 0
      position = file.position(1)
      assert(2, position.row)
      assert(1, position.column)
    end

    test "function declaration with newline at start of block and newline before end of block" do
      file = FileSet::File.new(body: "int f() {\n\treturn;\n}")
      file << 9
      file << 16
      position = file.position(10)
      assert(2, position.row)
      assert(2, position.column)

      position = file.position(17)
      assert(3, position.row)
      assert(1, position.column)
    end
  end
end
