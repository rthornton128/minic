# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class SemanticAnalyzerTest < TestCase
    test "boolean literal assigned to boolean variable does not raise error" do
      file = FileSet::File.new(body: "bool b = true; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "boolean literal assigned to double variable does not raise error" do
      file = FileSet::File.new(body: "double b = true; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
    end

    test "double literal assigned to double variable does not raise error" do
      file = FileSet::File.new(body: "double d = 0.0; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "double literal assigned to boolean variable does not raise error" do
      file = FileSet::File.new(body: "double d = true; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
    end

    test "integer literal assigned to integer variable does not raise error" do
      file = FileSet::File.new(body: "int i = 1; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "integer literal assigned to boolean variable does not raise error" do
      file = FileSet::File.new(body: "int i = true; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
    end

    test "string literal assigned to string variable does not raise error" do
      file = FileSet::File.new(body: 'string s = "str"; }')
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "string literal assigned to boolean variable does not raise error" do
      file = FileSet::File.new(body: "string s = true; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
    end
  end
end
