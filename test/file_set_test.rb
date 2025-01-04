# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class FileSetTest < TestCase
    test "position raises InvalidOffsetError if there are no files" do
      assert_raises(FileSet::InvalidOffsetError) do
        FileSet.new.position(1)
      end
    end

    test "position returns matching position for offset" do
      fileset = FileSet.new
      fileset << FileSet::File.new

      assert_equal(1, fileset.position(0).row)
      assert_equal(1, fileset.position(0).column)
    end
  end
end
