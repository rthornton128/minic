# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class LexerTest < TestCase
    test "returns EOF token for empty body" do
      lexer = Lexer.new(body: "")
      token = lexer.scan

      assert_equal(:Eof, token.token)
      assert_equal("", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns skips whitespace" do
      lexer = Lexer.new(body: " ")
      token = lexer.scan

      assert_equal(:Eof, token.token)
      assert_equal("", token.literal)
      assert_equal(1, token.offset)
    end

    test "returns Invalid token for invalid text in body" do
      lexer = Lexer.new(body: "@")
      token = lexer.scan

      assert_equal(:Invalid, token.token)
      assert_equal("@", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns Integer token for integer" do
      lexer = Lexer.new(body: "42")
      token = lexer.scan

      assert_equal(:Integer, token.token)
      assert_equal("42", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns Keyword token for valid keyword" do
      lexer = Lexer.new(body: "while")
      token = lexer.scan

      assert_equal(:Keyword, token.token)
      assert_equal("while", token.literal)
      assert_equal(0, token.offset)
    end

    test "returns Identifier token for identifier" do
      lexer = Lexer.new(body: "ident1")
      token = lexer.scan

      assert_equal(:Identifier, token.token)
      assert_equal("ident1", token.literal)
      assert_equal(0, token.offset)
    end
  end
end
