# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class GeneratorTest < TestCase
    class TestIO < IO
      sig { void }
      def initialize # rubocop:disable Lint/MissingSuper
        @buffer = T.let(String.new, String)
      end

      sig { params(args: T.untyped).void }
      def puts(*args)
        @buffer << args[0]
      end

      sig { params(args: T.untyped).void }
      def write(*args)
        @buffer << args[0]
      end

      sig { returns(String) }
      def to_s
        @buffer
      end
    end

    test "generate includes minic library" do
      file = Minic::FileSet::File.new(name: "", body: "void main() { return; }")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/#include "minic.h"/, out.to_s, "output includes library header")
    end

    test "generate includes main declaration" do
      file = Minic::FileSet::File.new(name: "", body: "void main() { return; }")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/void main\(\);/, out.to_s, "output includes main declaration")
    end

    test "generate includes main implementation with return statement" do
      file = Minic::FileSet::File.new(name: "", body: "void main() { return; }")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/void main\(\)\{return ;\}/, out.to_s, "output includes main implementation")
    end

    test "generate includes assignment statement" do
      file = Minic::FileSet::File.new(name: "", body: "void main() { int i; i = i + 1; return; }")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/i=i\+1/, out.to_s, "output includes assignment statement")
    end

    test "generate includes if-else statement" do
      file = Minic::FileSet::File.new(name: "", body: "void main() { if(false) {} else {}; return; }")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/if\(false\)\{\}else\{\}/, out.to_s, "output includes if statement")
    end

    test "generate includes while statement" do
      file = Minic::FileSet::File.new(name: "", body: "void main() { while(false) {}; return; }")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/while\(false\)\{\}/, out.to_s, "output includes while statement")
    end

    test "generate includes function with function call statement" do
      file = Minic::FileSet::File.new(
        name: "",
        body: "int add(int a, int b) { return a + b; } void main() { add(1, 2); return; }",
      )
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/add\(1,2\);/, out.to_s, "output includes function call statement")
    end

    test "generate includes boolean declaration with zero value" do
      file = Minic::FileSet::File.new(name: "", body: "bool b;")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/bool b = false;/, out.to_s, "output includes boolean set to zero value")
    end

    test "generate includes double declaration with zero value" do
      file = Minic::FileSet::File.new(name: "", body: "double d;")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/double d = 0.0;/, out.to_s, "output includes double set to zero value")
    end

    test "generate includes integer declaration with zero value" do
      file = Minic::FileSet::File.new(name: "", body: "int i;")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/int i = 0;/, out.to_s, "output includes integer set to zero value")
    end

    test "generate includes string declaration with zero value" do
      file = Minic::FileSet::File.new(name: "", body: "string s;")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/STRING_DECL\(s\) = \"\";/, out.to_s, "output includes string set to zero value")
    end

    test "generate includes int declaration with value assignment" do
      file = Minic::FileSet::File.new(name: "", body: "int i = 1;")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/int i = 1;/, out.to_s, "output includes integer set to value")
    end

    test "generate includes int declaration with binary assignment" do
      file = Minic::FileSet::File.new(name: "", body: "int i = 1 + 2;")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/int i = 1\+2;/, out.to_s, "output includes integer set to value")
    end

    test "generate includes int declaration with sub expression" do
      file = Minic::FileSet::File.new(name: "", body: "int i = (2);")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/int i = \(2\);/, out.to_s, "output includes integer set to value")
    end

    test "generate includes int declaration with unary expression" do
      file = Minic::FileSet::File.new(name: "", body: "int i = -1;")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/int i = -1;/, out.to_s, "output includes integer set to value")
    end

    test "generate includes int declaration with function call" do
      file = Minic::FileSet::File.new(name: "", body: "int fn() { return 1; } int i = fn();")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/int i = fn\(\);/, out.to_s, "output includes integer set to value")
    end

    test "generate includes int declaration with identifier value" do
      file = Minic::FileSet::File.new(name: "", body: "int x; int i = x;")
      lexer = Minic::Lexer.new(file:)
      parser = Minic::Parser.new(lexer:)
      ast = parser.parse
      Minic::SemanticAnalyzer.new(ast:).check

      out = TestIO.new
      Minic::Generator.new(ast:, out:).generate

      assert_match(/int i = x;/, out.to_s, "output includes integer set to value")
    end
  end
end
