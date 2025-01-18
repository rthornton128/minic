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
        type = BasicType.new(name: "int", offset: 0)
        scope["i"] = type

        assert_equal(type, scope["i"])
      end

      test "looking up a nested scope variable is successful" do
        parent = SemanticAnalyzer::Scope.new(parent: nil)
        type = BasicType.new(name: "int", offset: 0)
        parent["i"] = type

        scope = SemanticAnalyzer::Scope.new(parent:)

        refute_nil(scope["i"])
        assert_equal(type, scope["i"])
      end
    end
  end
end
