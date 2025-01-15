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
      boolean = AbstractSyntaxTree::BooleanLiteral.new(literal: "false", offset: 9)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: boolean)
      expected = [program, var_decl, type, identifier, boolean]

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
      double = AbstractSyntaxTree::DoubleLiteral.new(literal: "4.2", offset: 11)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: double)
      expected = [program, var_decl, type, identifier, double]

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
      string = AbstractSyntaxTree::StringLiteral.new(literal: '"word"', offset: 11)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: string)
      expected = [program, var_decl, type, identifier, string]

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

    test "parse variable declaration with unary expression assignment" do
      file = FileSet::File.new(body: "int a = !b;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      index = 0
      program = AbstractSyntaxTree::Program.new
      type = AbstractSyntaxTree::Keyword.new(literal: "int", offset: 0)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "a", offset: 4)
      expression = AbstractSyntaxTree::Identifier.new(literal: "b", offset: 9)
      unary = AbstractSyntaxTree::UnaryExpression.new(literal: "!", offset: 8, expression:)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: unary)
      expected = [program, var_decl, type, identifier, unary, expression]

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

    test "parse variable declaration with sub expression assignment" do
      file = FileSet::File.new(body: "int a = (true);")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      bool_expr = AbstractSyntaxTree::BooleanLiteral.new(literal: "true", offset: 9)
      expected = [bool_expr]

      ast = find_node(klass: AbstractSyntaxTree::SubExpression, ast:)
      refute_nil(ast)

      index = 0
      T.must(ast).walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        assert_equal(expect.literal, node.literal)
        assert_equal(expect.offset, node.offset)
        assert_equal(expect.length, node.length)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse variable declaration with binary expression assignment" do
      file = FileSet::File.new(body: "int a = 1 + 2;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      program = AbstractSyntaxTree::Program.new
      type = AbstractSyntaxTree::Keyword.new(literal: "int", offset: 0)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "a", offset: 4)
      lhs = AbstractSyntaxTree::IntegerLiteral.new(literal: "1", offset: 8)
      rhs = AbstractSyntaxTree::IntegerLiteral.new(literal: "2", offset: 12)
      binary = AbstractSyntaxTree::BinaryExpression.new(literal: "+", offset: 10, lhs:, rhs:)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: binary)
      expected = [program, var_decl, type, identifier, binary, lhs, rhs]

      index = 0
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

    test "parse function declaration with empty parameters and empty block" do
      file = FileSet::File.new(body: "int main() {}")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      program = AbstractSyntaxTree::Program.new
      type = AbstractSyntaxTree::Keyword.new(literal: "int", offset: 0)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "main", offset: 4)
      parameter_list = AbstractSyntaxTree::ParameterList.new(opening: 8, closing: 9, parameters: [])
      block = AbstractSyntaxTree::Block.new(opening: 11, closing: 12, statements: [])
      func_decl = AbstractSyntaxTree::FunctionDeclaration.new(type:, identifier:, parameter_list:, block:)
      expected = [program, func_decl, type, identifier, parameter_list, block]

      index = 0
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

    test "parse function declaration with a single parameter" do
      file = FileSet::File.new(body: "int main(bool b) {}")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      type = AbstractSyntaxTree::Keyword.new(literal: "bool", offset: 9)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "b", offset: 14)
      parameter = AbstractSyntaxTree::Parameter.new(type:, identifier:)

      expected = [parameter, type, identifier]

      list = find_node(klass: AbstractSyntaxTree::ParameterList, ast:)
      refute_nil(list)

      index = 0
      T.must(list).walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        assert_equal(expect.literal, node.literal)
        assert_equal(expect.offset, node.offset)
        assert_equal(expect.length, node.length)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with multiple parameters" do
      file = FileSet::File.new(body: "int add(int a, int b) {}")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      first_type = AbstractSyntaxTree::Keyword.new(literal: "int", offset: 8)
      first_identifier = AbstractSyntaxTree::Identifier.new(literal: "a", offset: 12)
      first_parameter = AbstractSyntaxTree::Parameter.new(type: first_type, identifier: first_identifier)

      second_type = AbstractSyntaxTree::Keyword.new(literal: "int", offset: 15)
      second_identifier = AbstractSyntaxTree::Identifier.new(literal: "b", offset: 19)
      second_parameter = AbstractSyntaxTree::Parameter.new(type: second_type, identifier: second_identifier)

      expected = [first_parameter, first_type, first_identifier, second_parameter, second_type, second_identifier]

      list = find_node(klass: AbstractSyntaxTree::ParameterList, ast:)
      refute_nil(list)

      index = 0
      T.must(list).walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        assert_equal(expect.literal, node.literal)
        assert_equal(expect.offset, node.offset)
        assert_equal(expect.length, node.length)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with if statement in block" do
      file = FileSet::File.new(body: "int main() { if(true) {}; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      conditional = AbstractSyntaxTree::BooleanLiteral.new(literal: "true", offset: 16)
      then_block = AbstractSyntaxTree::Block.new(opening: 22, closing: 23, statements: [])
      if_statement = AbstractSyntaxTree::IfStatement.new(offset: 13, conditional:, then_block:)

      expected = [if_statement, conditional, then_block]

      list = find_node(klass: AbstractSyntaxTree::Block, ast:)
      refute_nil(list)

      index = 0
      T.must(list).walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        assert_equal(expect.literal, node.literal)
        assert_equal(expect.offset, node.offset)
        assert_equal(expect.length, node.length)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with assignment statement in block" do
      file = FileSet::File.new(body: "int main() { a = b; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      lhs = AbstractSyntaxTree::Identifier.new(literal: "a", offset: 13)
      rhs = AbstractSyntaxTree::Identifier.new(literal: "b", offset: 17)
      assignment = AbstractSyntaxTree::AssignmentStatement.new(literal: "=", offset: 15, lhs:, rhs:)

      expected = [assignment, lhs, rhs]

      ast = find_node(klass: AbstractSyntaxTree::Block, ast:)
      refute_nil(ast)

      index = 0
      T.must(ast).walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        assert_equal(expect.literal, node.literal)
        assert_equal(expect.offset, node.offset)
        assert_equal(expect.length, node.length)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with if statement with else clause in block" do
      file = FileSet::File.new(body: "int main() { if(true) {} else {}; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      conditional = AbstractSyntaxTree::BooleanLiteral.new(literal: "true", offset: 16)
      then_block = AbstractSyntaxTree::Block.new(opening: 22, closing: 23, statements: [])
      else_block = AbstractSyntaxTree::Block.new(opening: 30, closing: 31, statements: [])
      if_statement = AbstractSyntaxTree::IfStatement.new(offset: 13, conditional:, then_block:, else_block:)

      expected = [if_statement, conditional, then_block, else_block]

      list = find_node(klass: AbstractSyntaxTree::Block, ast:)
      refute_nil(list)

      index = 0
      T.must(list).walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        assert_equal(expect.literal, node.literal)
        assert_equal(expect.offset, node.offset)
        assert_equal(expect.length, node.length)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with while statement in block" do
      file = FileSet::File.new(body: "int main() { while(true) {}; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      conditional = AbstractSyntaxTree::BooleanLiteral.new(literal: "true", offset: 19)
      block = AbstractSyntaxTree::Block.new(opening: 25, closing: 26, statements: [])
      where = AbstractSyntaxTree::WhileStatement.new(offset: 13, conditional:, block:)

      expected = [where, conditional, block]

      list = find_node(klass: AbstractSyntaxTree::Block, ast:)
      refute_nil(list)

      index = 0
      T.must(list).walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        assert_equal(expect.literal, node.literal)
        assert_equal(expect.offset, node.offset)
        assert_equal(expect.length, node.length)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    private

    sig do
      params(
        klass: T.class_of(AbstractSyntaxTree::Node),
        ast: AbstractSyntaxTree,
      ).returns(T.nilable(AbstractSyntaxTree::Node))
    end
    def find_node(klass:, ast:)
      node = T.let(nil, T.nilable(AbstractSyntaxTree::Node))
      ast.walk do |n|
        if n.instance_of?(klass)
          node = n
          break
        end
      end
      node
    end
  end
end
