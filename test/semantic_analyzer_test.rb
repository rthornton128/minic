# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class SemanticAnalyzerTest < TestCase
    test "empty program is raises error" do
      file = FileSet::File.new(body: "")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      analyzer = SemanticAnalyzer.new(ast: parser.parse)

      assert_raises(Error) do
        analyzer.analyze
      end
    end
  end
end
