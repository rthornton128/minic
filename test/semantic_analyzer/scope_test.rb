# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class SemanticAnalyzer
    class ScopeTest < TestCase
      test "lookup is nil for an empty scope" do
        scope = SemanticAnalyzer::Scope.new(parent: nil)
        assert_nil(scope["i"])
      end

      test "inserting and looking up a new entry is successful" do
        scope = SemanticAnalyzer::Scope.new(parent: nil)
        position = FileSet::Position.new(name: "", row: 0, column: 0)
        type = Type.new(name: "int", position:)
        scope["i"] = type

        assert_equal(type, scope["i"])
      end

      test "looking up a nested scope variable is successful" do
        parent = SemanticAnalyzer::Scope.new(parent: nil)
        position = FileSet::Position.new(name: "", row: 0, column: 0)
        type = Type.new(name: "int", position:)
        parent["i"] = type

        scope = SemanticAnalyzer::Scope.new(parent:)

        refute_nil(scope["i"])
        assert_equal(type, scope["i"])
      end
    end
  end
end
