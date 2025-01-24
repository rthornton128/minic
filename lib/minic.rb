# typed: true
# frozen_string_literal: true

require "bundler/setup"

Bundler.require(:default)

# Allow the root namespace and all classes to have access to the `sig` method.
extend T::Sig

class Module
  include T::Sig
end

require_relative "fileset"
require_relative "error"
require_relative "lexer"
require_relative "parser"
require_relative "semantic_analyzer"
require_relative "generator"

file = Minic::FileSet::File.new(name: "program.mc", body: "double d;")
lexer = Minic::Lexer.new(file:)
parser = Minic::Parser.new(lexer:)
ast = parser.parse
Minic::SemanticAnalyzer.new(ast:).check

out = File.open("./build/program.c", "w")
Minic::Generator.new(ast:, out:).generate
