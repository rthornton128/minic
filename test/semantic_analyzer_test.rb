# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class SemanticAnalyzerTest < TestCase
    test "boolean literal assigned to boolean variable does not raise error" do
      file = FileSet::File.new(body: "bool b = true;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "boolean literal assigned to double variable raises error" do
      file = FileSet::File.new(body: "double b = true;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_equal("type missmatch 'double' vs 'bool'", error.message)
    end

    test "double literal assigned to double variable does not raise error" do
      file = FileSet::File.new(body: "double d = 0.0;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "double literal assigned to boolean variable raises error" do
      file = FileSet::File.new(body: "double d = true;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_equal("type missmatch 'double' vs 'bool'", error.message)
    end

    test "integer literal assigned to integer variable does not raise error" do
      file = FileSet::File.new(body: "int i = 1;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "integer literal assigned to boolean variable raises error" do
      file = FileSet::File.new(body: "int i = true;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_equal("type missmatch 'int' vs 'bool'", error.message)
    end

    test "string literal assigned to string variable does not raise error" do
      file = FileSet::File.new(body: 'string s = "str";')
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "string literal assigned to boolean variable raises error" do
      file = FileSet::File.new(body: "string s = true;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_equal("type missmatch 'string' vs 'bool'", error.message)
    end

    test "variable declared void raises error" do
      file = FileSet::File.new(body: "void v;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_equal("variables may not be declared void", error.message)
    end

    test "undeclared identifier in variable declaration assignment raises error" do
      file = FileSet::File.new(body: "int i = x;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_equal("undeclared variable in assignment", error.message)
    end

    test "self-referenence in variable declaration assignment raises error" do
      file = FileSet::File.new(body: "int i = i;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_equal("undeclared variable in assignment", error.message)
    end

    test "variable with matching type in variable declaration assignment does not raise error" do
      file = FileSet::File.new(body: "int x; int i = x;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "variable with miss-matched type in variable declaration assignment raises error" do
      file = FileSet::File.new(body: "bool b; int i = b;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_equal("type missmatch 'int' vs 'bool'", error.message)
    end

    test "negation unary expression in variable declaration assignment passes" do
      file = FileSet::File.new(body: "int i = -1;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "negation unary expression with miss-matched types in assignment raises error" do
      file = FileSet::File.new(body: "int i = -true;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_equal("type missmatch 'int' vs 'bool'", error.message)
    end

    test "not unary expression in variable declaration assignment passes" do
      file = FileSet::File.new(body: "bool b = !true;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "not unary expression with miss-matched types in assignment raises error" do
      file = FileSet::File.new(body: "bool b = !42;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_equal("type missmatch 'bool' vs 'int'", error.message)
    end
  end
end
