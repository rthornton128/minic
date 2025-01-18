# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class LexerTest < TestCase
    test "returns EOF token for empty body" do
      lexer = Lexer.new(file: FileSet::File.new(body: ""))
      token = lexer.scan

      assert_equal(:Eof, token.token)
      assert_equal("", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns skips whitespace" do
      lexer = Lexer.new(file: FileSet::File.new(body: " \t\r\n"))
      token = lexer.scan

      assert_equal(:Eof, token.token)
      assert_equal("", token.literal)
      assert_equal(4, token.offset)
    end

    test "raises Invalid token for invalid character in body" do
      lexer = Lexer.new(file: FileSet::File.new(body: "@"))

      assert_raises(Lexer::InvalidTokenError) do
        lexer.scan
      rescue Lexer::InvalidTokenError => error
        assert_equal("@", error.literal)
        assert_equal(0, error.offset)
        raise
      end
    end

    test "returns Integer token for value 0" do
      lexer = Lexer.new(file: FileSet::File.new(body: "0"))
      token = lexer.scan

      assert_equal(:Integer, token.token)
      assert_equal("0", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns Integer token for integer" do
      lexer = Lexer.new(file: FileSet::File.new(body: "42"))
      token = lexer.scan

      assert_equal(:Integer, token.token)
      assert_equal("42", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns Keyword token for valid keyword" do
      lexer = Lexer.new(file: FileSet::File.new(body: "while"))
      token = lexer.scan

      assert_equal(:Keyword, token.token)
      assert_equal("while", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns Identifier token for identifier" do
      lexer = Lexer.new(file: FileSet::File.new(body: "ident1"))
      token = lexer.scan

      assert_equal(:Identifier, token.token)
      assert_equal("ident1", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns matching symbol for single character operator" do
      lexer = Lexer.new(file: FileSet::File.new(body: "="))
      token = lexer.scan

      assert_equal(:Equal, token.token)
      assert_equal("=", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns matching symbol for - operator" do
      lexer = Lexer.new(file: FileSet::File.new(body: "-"))
      token = lexer.scan

      assert_equal(:Minus, token.token)
      assert_equal("-", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns matching symbol for double character operator" do
      lexer = Lexer.new(file: FileSet::File.new(body: "=="))
      token = lexer.scan

      assert_equal(:Equality, token.token)
      assert_equal("==", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns double for numeric starting with zero and contains a decimal" do
      lexer = Lexer.new(file: FileSet::File.new(body: "0.1"))
      token = lexer.scan

      assert_equal(:Double, token.token)
      assert_equal("0.1", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns double for numeric containing a decimal" do
      lexer = Lexer.new(file: FileSet::File.new(body: "42.01"))
      token = lexer.scan

      assert_equal(:Double, token.token)
      assert_equal("42.01", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns boolean for true literal" do
      lexer = Lexer.new(file: FileSet::File.new(body: "true"))
      token = lexer.scan

      assert_equal(:Boolean, token.token)
      assert_equal("true", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns string for string literal" do
      lexer = Lexer.new(file: FileSet::File.new(body: '"hello"'))
      token = lexer.scan

      assert_equal(:String, token.token)
      assert_equal('"hello"', token.literal)
      assert_equal(0, token.offset)
    end

    test "raises exception for unterminated string literal by end of line" do
      lexer = Lexer.new(file: FileSet::File.new(body: '"hello
      '))
      assert_raises(Minic::Lexer::UnterminatedStringError) do
        lexer.scan
      end
    end

    test "raises exception for unterminated string literal by end of file" do
      lexer = Lexer.new(file: FileSet::File.new(body: '"hello'))
      assert_raises(Minic::Lexer::UnterminatedStringError) do
        lexer.scan
      end
    end

    test "does not raise an exception for scanning after a string" do
      lexer = Lexer.new(file: FileSet::File.new(body: '"hello";'))
      lexer.scan
      token = lexer.scan

      assert_equal(:SemiColon, token.token)
    end

    test "returns comment for comment literal" do
      lexer = Lexer.new(file: FileSet::File.new(body: "// comment"))
      token = lexer.scan

      assert_equal(:Comment, token.token)
      assert_equal("// comment", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns comment for end of line comment literal" do
      lexer = Lexer.new(file: FileSet::File.new(body: "a; // comment"))
      lexer.scan
      lexer.scan
      token = lexer.scan

      assert_equal(:Comment, token.token)
      assert_equal("// comment", token.literal)
      assert_equal(3, token.offset)
    end

    test "returns all tokens for equation" do
      lexer = Lexer.new(file: FileSet::File.new(body: "1 + 2"))

      expected_tokens = [
        [:Integer, "1", 0],
        [:Plus, "+", 2],
        [:Integer, "2", 4],
      ]

      expected_tokens.each do |expected_token|
        token = lexer.scan

        assert_equal(expected_token[0], token.token)
        assert_equal(expected_token[1], token.literal)
        assert_equal(expected_token[2], token.offset)
      end

      token = lexer.scan
      assert_equal(:Eof, token.token)
    end

    test "returns all tokens for function" do
      lexer = Lexer.new(file: FileSet::File.new(body: "int add(int a, int b) {\n\treturn a + b;\n}"))

      expected_tokens = [
        [:Keyword, "int", 0],
        [:Identifier, "add", 4],
        [:LeftParen, "(", 7],
        [:Keyword, "int", 8],
        [:Identifier, "a", 12],
        [:Comma, ",", 13],
        [:Keyword, "int", 15],
        [:Identifier, "b", 19],
        [:RightParen, ")", 20],
        [:LeftBrace, "{", 22],
        [:Keyword, "return", 25],
        [:Identifier, "a", 32],
        [:Plus, "+", 34],
        [:Identifier, "b", 36],
        [:SemiColon, ";", 37],
        [:RightBrace, "}", 39],
      ]

      expected_tokens.each do |expected_token|
        token = lexer.scan

        assert_equal(expected_token[0], token.token)
        assert_equal(expected_token[1], token.literal)
        assert_equal(expected_token[2], token.offset)
      end

      token = lexer.scan
      assert_equal(:Eof, token.token)
    end

    # integration test
    test "file with newline has correct position for offset" do
      file = FileSet::File.new(body: "1\n2")
      lexer = Lexer.new(file:)

      token = lexer.scan
      token = lexer.scan until token.token == :Eof

      position = file.position(2)
      assert_equal(2, position.row)
      assert_equal(1, position.column)
    end
  end
end
