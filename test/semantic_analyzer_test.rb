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
      assert_match("type missmatch 'double' vs 'bool'", error.message)
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
      assert_match("type missmatch 'double' vs 'bool'", error.message)
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
      assert_match("type missmatch 'int' vs 'bool'", error.message)
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
      assert_match("type missmatch 'string' vs 'bool'", error.message)
    end

    test "variable declared void raises error" do
      file = FileSet::File.new(body: "void v;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("variables may not be declared void", error.message)
    end

    test "undeclared identifier in variable declaration assignment raises error" do
      file = FileSet::File.new(body: "int i = x;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("undeclared variable in assignment", error.message)
    end

    test "self-referenence in variable declaration assignment raises error" do
      file = FileSet::File.new(body: "int i = i;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("undeclared variable in assignment", error.message)
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
      assert_match("type missmatch 'int' vs 'bool'", error.message)
    end

    test "integer binary expression matching assignment passes" do
      file = FileSet::File.new(body: "int i = 1 + 2;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "integer binary expression with miss-matched types raises exception" do
      file = FileSet::File.new(body: "int i = 1 + true;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("type missmatch 'int' vs 'bool'", error.message)
    end

    test "boolean binary expression matching assignment passes" do
      file = FileSet::File.new(body: "bool b = 1 == 2;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "arithmetic binary expression with boolean operands raises exception" do
      file = FileSet::File.new(body: "bool b = true + false;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("arithmetic operators not compatible with boolean operands", error.message)
    end

    test "adding string expression matching assignment passes" do
      file = FileSet::File.new(body: 'string s = "a" + "b";')
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "arithmetic binary expression with string operands raises exception" do
      file = FileSet::File.new(body: 'bool b = "a" / "b";')
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("arithmetic operators not compatible with operands", error.message)
    end

    test "sub expression with matching type in assignment passes" do
      file = FileSet::File.new(body: "bool b = (true);")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
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
      assert_match("type missmatch 'int' vs 'bool'", error.message)
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
      assert_match("type missmatch 'bool' vs 'int'", error.message)
    end

    test "function declaration passes" do
      file = FileSet::File.new(body: "void main() { return; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "function declaration with empty block will raise error" do
      file = FileSet::File.new(body: "void main() {}")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("function block must end with a return statement", error.message)
    end

    test "function declaration with block not ending with return will raise error" do
      file = FileSet::File.new(body: "void main() { int a; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("function block must end with a return statement", error.message)
    end

    test "function declaration with block with variable declaration and return identifier passes" do
      file = FileSet::File.new(body: "int main() { int a; return a;}")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "return statement with expression that references parameters passes" do
      file = FileSet::File.new(body: "int add(int a, int b) { return a + b; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "function declaration with valid if statement passes" do
      file = FileSet::File.new(body: "void main() { if(true) {} else {} return; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "function declaration with non-boolean conditional if statement raises error" do
      file = FileSet::File.new(body: "void main() { if(1) {} else {} return; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("type missmatch 'bool' vs 'int'", error.message)
    end

    test "function declaration with valid while statement passes" do
      file = FileSet::File.new(body: "void main() { while(true) {} return; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "function declaration with non-boolean conditional while statement raises error" do
      file = FileSet::File.new(body: "void main() { while(1) {} return; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("type missmatch 'bool' vs 'int'", error.message)
    end

    test "function declaration with valid assignment statement passes" do
      file = FileSet::File.new(body: "void fn(int a) { a = 1; return; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "function declaration with invalid assignment statement raises error" do
      file = FileSet::File.new(body: "void fn(bool b) { b = 1; return; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("type missmatch 'bool' vs 'int'", error.message)
    end

    test "function declaration with matching recursive function call passes" do
      file = FileSet::File.new(body: "bool fn(bool b) { return fn(true); }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "function declaration with invalid return function statement raises error" do
      file = FileSet::File.new(body: "bool b() { return true; } int i() { return b(); }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("type missmatch 'int' vs 'bool'", error.message)
    end

    test "function declaration with valid arguments passes" do
      file = FileSet::File.new(body: "int add(int a, int b) { return add(1, 2); }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "function declaration with too few arguments count in return statement raises error" do
      file = FileSet::File.new(body: "int add(int a, int b) { return add(1); }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("expected 2 arguments but got 1", error.message)
    end

    test "function declaration with too many arguments count in return statement raises error" do
      file = FileSet::File.new(body: "int fn(int a) { return fn(1, 2); }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("expected 1 arguments but got 2", error.message)
    end

    test "function declaration with miss-matched types in function call raises error" do
      file = FileSet::File.new(body: "int fn(int a) { return fn(true); }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("type missmatch 'int' vs 'bool'", error.message)
    end

    test "function declaration with built-in call passes" do
      file = FileSet::File.new(body: "void main() { print(\"hello\"); return; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      SemanticAnalyzer.new(ast:).check
    end

    test "function declaration with bad return value fails" do
      file = FileSet::File.new(body: "int main() { return print(\"hello\"); }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)
      ast = parser.parse

      error = assert_raises(SemanticAnalyzer::Error) { SemanticAnalyzer.new(ast:).check }
      assert_match("type missmatch 'int' vs 'void'", error.message)
    end
  end
end
