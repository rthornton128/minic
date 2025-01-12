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

    test "parse simple variable declaration" do
      file = FileSet::File.new(body: "int x;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      index = 0
      program = AbstractSyntaxTree::Program.new
      type = AbstractSyntaxTree::Keyword.new(literal: "int", offset: 0)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "x", offset: 4)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:)
      expected = [program, var_decl, type, identifier]

      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        assert_equal(expect.literal, node.literal)
        assert_equal(expect.offset, node.offset)
        assert_equal(expect.length, node.length)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse simple variable declaration with boolean assignment" do
      file = FileSet::File.new(body: "bool b = false;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      index = 0
      program = AbstractSyntaxTree::Program.new
      type = AbstractSyntaxTree::Keyword.new(literal: "bool", offset: 0)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "b", offset: 5)
      integer = AbstractSyntaxTree::BooleanLiteral.new(literal: "false", offset: 9)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: integer)
      expected = [program, var_decl, type, identifier, integer]

      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        assert_equal(expect.literal, node.literal)
        assert_equal(expect.offset, node.offset)
        assert_equal(expect.length, node.length)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse simple variable declaration with double assignment" do
      file = FileSet::File.new(body: "double d = 4.2;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      index = 0
      program = AbstractSyntaxTree::Program.new
      type = AbstractSyntaxTree::Keyword.new(literal: "double", offset: 0)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "d", offset: 7)
      integer = AbstractSyntaxTree::DoubleLiteral.new(literal: "4.2", offset: 11)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: integer)
      expected = [program, var_decl, type, identifier, integer]

      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        assert_equal(expect.literal, node.literal)
        assert_equal(expect.offset, node.offset)
        assert_equal(expect.length, node.length)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse simple variable declaration with integer assignment" do
      file = FileSet::File.new(body: "int x = 42;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      index = 0
      program = AbstractSyntaxTree::Program.new
      type = AbstractSyntaxTree::Keyword.new(literal: "int", offset: 0)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "x", offset: 4)
      integer = AbstractSyntaxTree::IntegerLiteral.new(literal: "42", offset: 8)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: integer)
      expected = [program, var_decl, type, identifier, integer]

      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        assert_equal(expect.literal, node.literal)
        assert_equal(expect.offset, node.offset)
        assert_equal(expect.length, node.length)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse simple variable declaration with string assignment" do
      file = FileSet::File.new(body: 'string s = "word";')
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      index = 0
      program = AbstractSyntaxTree::Program.new
      type = AbstractSyntaxTree::Keyword.new(literal: "string", offset: 0)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "s", offset: 7)
      integer = AbstractSyntaxTree::StringLiteral.new(literal: '"word"', offset: 11)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: integer)
      expected = [program, var_decl, type, identifier, integer]

      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        assert_equal(expect.literal, node.literal)
        assert_equal(expect.offset, node.offset)
        assert_equal(expect.length, node.length)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse simple variable declaration with identifier assignment" do
      file = FileSet::File.new(body: "int a = b;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      index = 0
      program = AbstractSyntaxTree::Program.new
      type = AbstractSyntaxTree::Keyword.new(literal: "int", offset: 0)
      lhs = AbstractSyntaxTree::Identifier.new(literal: "a", offset: 4)
      rhs = AbstractSyntaxTree::Identifier.new(literal: "b", offset: 8)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier: lhs, assignment: rhs)
      expected = [program, var_decl, type, lhs, rhs]

      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        assert_equal(expect.literal, node.literal)
        assert_equal(expect.offset, node.offset)
        assert_equal(expect.length, node.length)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end
  end
end
