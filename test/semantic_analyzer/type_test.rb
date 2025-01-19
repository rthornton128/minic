# typed: true
# frozen_string_literal: true

require "test_helper"

module Minic
  class SemanticAnalyzer
    class TypeTest < TestCase
      test "== is true when they are the same class and name" do
        assert(Type.new(name: "bool", offset: 0) == Type.new(name: "bool", offset: 1))
      end

      test "== is false when they are the same class but different names" do
        refute(Type.new(name: "bool", offset: 0) == Type.new(name: "int", offset: 0))
      end

      test "valid returns true for bool" do
        assert_predicate(Type.new(name: "bool", offset: 0), :valid?)
      end

      test "valid returns true for double" do
        assert_predicate(Type.new(name: "double", offset: 0), :valid?)
      end

      test "valid returns true for int" do
        assert_predicate(Type.new(name: "int", offset: 0), :valid?)
      end

      test "valid returns true for string" do
        assert_predicate(Type.new(name: "string", offset: 0), :valid?)
      end

      test "valid returns true for void" do
        assert_predicate(Type.new(name: "void", offset: 0), :valid?)
      end

      test "valid returns false when type is unknown" do
        refute_predicate(Type.new(name: "invalid", offset: 0), :valid?)
      end
    end
  end
end
