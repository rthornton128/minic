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
        index += 1
      end
      assert_equal(1, index, "Number of nodes must match")
    end

    test "parse simple variable declaration" do
      file = FileSet::File.new(body: "int x;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      type = AbstractSyntaxTree::Keyword.new(literal: "int", position: file.position(0))
      identifier = AbstractSyntaxTree::Identifier.new(literal: "x", position: file.position(4))
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:)
      expected = [var_decl, type, identifier]

      index = 0
      ast = ast.program
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse simple variable declaration with boolean assignment" do
      file = FileSet::File.new(body: "bool b = false;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      type = AbstractSyntaxTree::Keyword.new(literal: "bool", position:)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "b", position:)
      boolean = AbstractSyntaxTree::BooleanLiteral.new(literal: "false", position:)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: boolean)
      expected = [var_decl, type, identifier, boolean]

      index = 0
      ast = ast.program
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse simple variable declaration with double assignment" do
      file = FileSet::File.new(body: "double d = 4.2;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      type = AbstractSyntaxTree::Keyword.new(literal: "double", position:)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "d", position:)
      double = AbstractSyntaxTree::DoubleLiteral.new(literal: "4.2", position:)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: double)
      expected = [var_decl, type, identifier, double]

      index = 0
      ast = ast.program
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse simple variable declaration with integer assignment" do
      file = FileSet::File.new(body: "int x = 42;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      type = AbstractSyntaxTree::Keyword.new(literal: "int", position:)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "x", position:)
      integer = AbstractSyntaxTree::IntegerLiteral.new(literal: "42", position:)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: integer)
      expected = [var_decl, type, identifier, integer]

      index = 0
      ast = ast.program
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse simple variable declaration with string assignment" do
      file = FileSet::File.new(body: 'string s = "word";')
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      type = AbstractSyntaxTree::Keyword.new(literal: "string", position:)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "s", position:)
      string = AbstractSyntaxTree::StringLiteral.new(literal: '"word"', position:)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: string)
      expected = [var_decl, type, identifier, string]

      index = 0
      ast = ast.program
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse simple variable declaration with identifier assignment" do
      file = FileSet::File.new(body: "int a = b;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      type = AbstractSyntaxTree::Keyword.new(literal: "int", position:)
      lhs = AbstractSyntaxTree::Identifier.new(literal: "a", position:)
      rhs = AbstractSyntaxTree::Identifier.new(literal: "b", position:)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier: lhs, assignment: rhs)
      expected = [var_decl, type, lhs, rhs]

      index = 0
      ast = ast.program
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse variable declaration with unary expression assignment" do
      file = FileSet::File.new(body: "int a = !b;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      type = AbstractSyntaxTree::Keyword.new(literal: "int", position:)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "a", position:)
      expression = AbstractSyntaxTree::Identifier.new(literal: "b", position:)
      unary = AbstractSyntaxTree::UnaryExpression.new(literal: "!", position:, expression:)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: unary)
      expected = [var_decl, type, identifier, unary, expression]

      index = 0
      ast = ast.program
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse variable declaration with sub expression assignment" do
      file = FileSet::File.new(body: "int a = (true);")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      bool_expr = AbstractSyntaxTree::BooleanLiteral.new(literal: "true", position:)
      expected = [bool_expr]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::VariableDeclaration).assignment
      refute_nil(ast)

      index = 0
      T.must(ast).walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse variable declaration with binary expression assignment" do
      file = FileSet::File.new(body: "int a = 1 + 2;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      type = AbstractSyntaxTree::Keyword.new(literal: "int", position:)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "a", position:)
      lhs = AbstractSyntaxTree::IntegerLiteral.new(literal: "1", position:)
      rhs = AbstractSyntaxTree::IntegerLiteral.new(literal: "2", position:)
      binary = AbstractSyntaxTree::BinaryExpression.new(literal: "+", position:, lhs:, rhs:)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:, assignment: binary)
      expected = [var_decl, type, identifier, binary, lhs, rhs]

      index = 0
      ast = ast.program
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse variable declaration with binary comparison expression assignment" do
      file = FileSet::File.new(body: "int a = 1 == 2;")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      lhs = AbstractSyntaxTree::IntegerLiteral.new(literal: "1", position:)
      rhs = AbstractSyntaxTree::IntegerLiteral.new(literal: "2", position:)
      expected = [lhs, rhs]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::VariableDeclaration).assignment
      refute_nil(ast)

      assert_instance_of(AbstractSyntaxTree::BinaryExpression, ast)
      assert_equal("==", T.cast(ast, AbstractSyntaxTree::BinaryExpression).literal)

      index = 0
      T.must(ast).walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse variable declaration with simple function call" do
      file = FileSet::File.new(body: "int a = func();")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "func", position:)

      expected = [identifier]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::VariableDeclaration).assignment
      refute_nil(ast)

      index = 0
      T.must(ast).walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse variable declaration in simple function call block" do
      file = FileSet::File.new(body: "void main() { int a; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      type = AbstractSyntaxTree::Keyword.new(literal: "int", position:)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "a", position:)
      var_decl = AbstractSyntaxTree::VariableDeclaration.new(type:, identifier:)

      expected = [var_decl, type, identifier]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::FunctionDeclaration).block
      refute_nil(ast)

      index = 0
      T.must(ast).walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with empty parameters and empty block" do
      file = FileSet::File.new(body: "int main() {}")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      opening = closing = position = file.position(0)
      type = AbstractSyntaxTree::Keyword.new(literal: "int", position:)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "main", position:)
      parameter_list = AbstractSyntaxTree::ParameterList.new(opening:, closing:, parameters: [])
      block = AbstractSyntaxTree::Block.new(opening:, closing:, statements: [])
      func_decl = AbstractSyntaxTree::FunctionDeclaration.new(type:, identifier:, parameter_list:, block:)
      expected = [func_decl, type, identifier, parameter_list, block]

      index = 0
      ast = ast.program
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with a single parameter" do
      file = FileSet::File.new(body: "int main(bool b) {}")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      type = AbstractSyntaxTree::Keyword.new(literal: "bool", position:)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "b", position:)
      parameter = AbstractSyntaxTree::Parameter.new(type:, identifier:)

      expected = [parameter, type, identifier]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::FunctionDeclaration).parameter_list
      refute_nil(ast)

      index = 0
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with multiple parameters" do
      file = FileSet::File.new(body: "int add(int a, int b) {}")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      first_type = AbstractSyntaxTree::Keyword.new(literal: "int", position:)
      first_identifier = AbstractSyntaxTree::Identifier.new(literal: "a", position:)
      first_parameter = AbstractSyntaxTree::Parameter.new(type: first_type, identifier: first_identifier)

      second_type = AbstractSyntaxTree::Keyword.new(literal: "int", position:)
      second_identifier = AbstractSyntaxTree::Identifier.new(literal: "b", position:)
      second_parameter = AbstractSyntaxTree::Parameter.new(type: second_type, identifier: second_identifier)

      expected = [first_parameter, first_type, first_identifier, second_parameter, second_type, second_identifier]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::FunctionDeclaration).parameter_list
      refute_nil(ast)

      index = 0
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with function call with no parameters in block" do
      file = FileSet::File.new(body: "int main() { add(); }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "add", position:)
      function_call = AbstractSyntaxTree::FunctionCall.new(identifier:, arguments: [])

      expected = [function_call, identifier]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::FunctionDeclaration).block
      refute_nil(ast)

      index = 0
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with function call with one parameter in block" do
      file = FileSet::File.new(body: "int main() { func(true); }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "func", position:)
      argument = AbstractSyntaxTree::BooleanLiteral.new(literal: "true", position:)
      function_call = AbstractSyntaxTree::FunctionCall.new(identifier:, arguments: [argument])

      expected = [function_call, identifier, argument]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::FunctionDeclaration).block
      refute_nil(ast)

      index = 0
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with function call with multiple parameters in block" do
      file = FileSet::File.new(body: "int main() { add(1, 2); }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      identifier = AbstractSyntaxTree::Identifier.new(literal: "add", position:)
      first_argument = AbstractSyntaxTree::IntegerLiteral.new(literal: "1", position:)
      second_argument = AbstractSyntaxTree::IntegerLiteral.new(literal: "2", position:)
      function_call = AbstractSyntaxTree::FunctionCall.new(identifier:, arguments: [first_argument, second_argument])

      expected = [function_call, identifier, first_argument, second_argument]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::FunctionDeclaration).block

      refute_nil(ast)

      index = 0
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with if statement in block" do
      file = FileSet::File.new(body: "int main() { if(true) {}; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      conditional = AbstractSyntaxTree::BooleanLiteral.new(literal: "true", position:)
      then_block = AbstractSyntaxTree::Block.new(opening: position, closing: position, statements: [])
      if_statement = AbstractSyntaxTree::IfStatement.new(if_pos: position, conditional:, then_block:)

      expected = [if_statement, conditional, then_block]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::FunctionDeclaration).block
      refute_nil(ast)

      index = 0
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with assignment statement in block" do
      file = FileSet::File.new(body: "int main() { a = b; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      lhs = AbstractSyntaxTree::Identifier.new(literal: "a", position:)
      rhs = AbstractSyntaxTree::Identifier.new(literal: "b", position:)
      assignment = AbstractSyntaxTree::AssignmentStatement.new(equal_pos: position, lhs:, rhs:)

      expected = [assignment, lhs, rhs]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::FunctionDeclaration).block
      refute_nil(ast)

      index = 0
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with if statement with else clause in block" do
      file = FileSet::File.new(body: "int main() { if(true) {} else {}; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      opening = closing = position = file.position(0)
      conditional = AbstractSyntaxTree::BooleanLiteral.new(literal: "true", position:)
      then_block = AbstractSyntaxTree::Block.new(opening:, closing:, statements: [])
      else_block = AbstractSyntaxTree::Block.new(opening:, closing:, statements: [])
      if_statement = AbstractSyntaxTree::IfStatement.new(if_pos: position, conditional:, then_block:, else_block:)

      expected = [if_statement, conditional, then_block, else_block]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::FunctionDeclaration).block
      refute_nil(ast)

      index = 0
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with naked return statement in block" do
      file = FileSet::File.new(body: "int main() { return; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      return_pos = file.position(0)
      return_statement = AbstractSyntaxTree::ReturnStatement.new(return_pos:, expression: nil)

      expected = [return_statement]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::FunctionDeclaration).block
      refute_nil(ast)

      index = 0
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with return statement in block" do
      file = FileSet::File.new(body: "int main() { return 42; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      return_pos = position = file.position(0)
      expression = AbstractSyntaxTree::IntegerLiteral.new(literal: "42", position:)
      return_statement = AbstractSyntaxTree::ReturnStatement.new(return_pos:, expression:)

      expected = [return_statement, expression]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::FunctionDeclaration).block
      refute_nil(ast)

      index = 0
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse variable declaration with multiple expressions in assignment" do
      file = FileSet::File.new(body: "int i = (1 + 2) + -3")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      first_integer = AbstractSyntaxTree::IntegerLiteral.new(literal: "1", position:)
      second_integer = AbstractSyntaxTree::IntegerLiteral.new(literal: "2", position:)
      first_binary_expr = AbstractSyntaxTree::BinaryExpression.new(
        literal: "+",
        position:,
        lhs: first_integer,
        rhs: second_integer,
      )
      sub_expr = AbstractSyntaxTree::SubExpression.new(
        opening: position,
        closing: position,
        expression: first_binary_expr,
      )
      third_integer = AbstractSyntaxTree::IntegerLiteral.new(literal: "3", position:)
      unary_expr = AbstractSyntaxTree::UnaryExpression.new(literal: "-", position:, expression: third_integer)
      second_binary_expr = AbstractSyntaxTree::BinaryExpression.new(
        literal: "+",
        position:,
        lhs: sub_expr,
        rhs: unary_expr,
      )

      expected = [
        sub_expr,
        first_binary_expr,
        first_integer,
        second_integer,
        unary_expr,
        third_integer,
      ]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::VariableDeclaration).assignment
      refute_nil(ast)
      assert_instance_of(second_binary_expr.class, ast)

      index = 0
      T.must(ast).walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end

    test "parse function declaration with while statement in block" do
      file = FileSet::File.new(body: "int main() { while(true) {}; }")
      lexer = Lexer.new(file:)
      parser = Parser.new(lexer:)

      ast = parser.parse

      position = file.position(0)
      conditional = AbstractSyntaxTree::BooleanLiteral.new(literal: "true", position:)
      block = AbstractSyntaxTree::Block.new(opening: position, closing: position, statements: [])
      where = AbstractSyntaxTree::WhileStatement.new(while_pos: position, conditional:, block:)

      expected = [where, conditional, block]

      ast = T.cast(ast.program.declarations.first, AbstractSyntaxTree::FunctionDeclaration).block
      refute_nil(ast)

      index = 0
      ast.walk do |node|
        expect = T.must(expected[index])

        assert_instance_of(expect.class, node)
        index += 1
      end

      assert_equal(expected.size, index, "Number of nodes must match")
    end
  end
end
