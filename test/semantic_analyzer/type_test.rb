# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class SemanticAnalyzer
    class TypeTest < TestCase
      setup do
        @position = FileSet::Position.new(name: "unknown", row: 0, column: 0)
      end

      test "== is true when they have the same name" do
        other_position = FileSet::Position.new(name: "unknown", row: 0, column: 0)
        assert(Type.new(name: "bool", position: @position) == Type.new(name: "bool", position: other_position))
      end

      test "== is false when they have different names" do
        refute(Type.new(name: "bool", position: @position) == Type.new(name: "int", position: @position))
      end

      test "valid returns true for bool" do
        assert_predicate(Type.new(name: "bool", position: @position), :valid?)
      end

      test "valid returns true for double" do
        assert_predicate(Type.new(name: "double", position: @position), :valid?)
      end

      test "valid returns true for int" do
        assert_predicate(Type.new(name: "int", position: @position), :valid?)
      end

      test "valid returns true for string" do
        assert_predicate(Type.new(name: "string", position: @position), :valid?)
      end

      test "valid returns true for void" do
        assert_predicate(Type.new(name: "void", position: @position), :valid?)
      end

      test "valid returns false when type is unknown" do
        refute_predicate(Type.new(name: "invalid", position: @position), :valid?)
      end
    end
  end
end
