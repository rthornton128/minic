# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class PositionTest < TestCase
    test "to_s returns string with proper format" do
      assert_equal("file.mc: 1,1", FileSet::Position.new(name: "file.mc", row: 1, column: 1).to_s)
    end
  end
end
