# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class ParserTest < TestCase
    test "parse program for empty file" do
      file = FileSet::File.new
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      assert_equal("", ast.program.literal)
      assert_equal(0, ast.program.offset)
      assert_equal(0, ast.program.length)
    end
  end
end
