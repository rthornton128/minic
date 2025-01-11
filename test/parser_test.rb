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

      index = 0
      ast.walk do |node|
        assert_instance_of(AbstractSyntaxTree::Program, node)
        assert_equal("", node.literal)
        assert_equal(0, node.offset)
        assert_equal(0, node.length)
        index += 1
      end
      assert_equal(1, index, "Number of nodes must match")
    end
  end
end
