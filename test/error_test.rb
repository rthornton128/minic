# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class ErrorTest < TestCase
    test "error message includes position" do
      position = FileSet::Position.new(name: "test.mc", row: 1, column: 1)
      error = Error.new("error message", position:)

      prefix = position.to_s
      assert_equal("#{prefix}: error message", error.to_s)
    end
  end
end
