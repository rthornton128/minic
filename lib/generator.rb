# typed: true
# frozen_string_literal: true

module Minic
  class Generator
    sig { params(ast: AbstractSyntaxTree, out: IO).void }
    def initialize(ast:, out:)
      @ast = ast
      @out = out
    end

    sig { void }
    def generate
      @out.puts("// Auto-generated output by Minic Compiler")
      generate_program(@ast.program)
    end

    private

    sig { params(program: AbstractSyntaxTree::Program).void }
    def generate_program(program)
      @out.puts('#include "minic.h"')
      generate_declarations

      program.declarations.each do |declaration|
        generate_implementation(declaration)
      end
    end

    sig { void }
    def generate_declarations
    end

    sig { params(func_type: SemanticAnalyzer::FunctionType).void }
    def generate_function_declaration(func_type)
    end

    sig { params(declaration: AbstractSyntaxTree::Declaration).void }
    def generate_implementation(declaration)
      case declaration
      when AbstractSyntaxTree::FunctionDeclaration
      when AbstractSyntaxTree::VariableDeclaration
        generate_variable_decl(declaration)
      end
    end

    sig { params(declaration: AbstractSyntaxTree::VariableDeclaration).void }
    def generate_variable_decl(declaration)
      type_name = declaration.type.literal
      identifier = declaration.identifier.literal

      case type_name
      when "string"
        @out.write("STRING_DECL(#{identifier})")
      else
        @out.write("#{type_name} #{identifier}")
      end

      @out.write(" = ")
      if declaration.assignment.nil?
        generate_zero_value(type_name)
      else
        generate_assignment(T.must(declaration.assignment))
      end

      @out.puts(";")
    end

    sig { params(assignment: AbstractSyntaxTree::Expression).void }
    def generate_assignment(assignment)
    end

    sig { params(type_name: String).void }
    def generate_zero_value(type_name)
      case type_name
      when "bool"
        @out.write("false")
      when "double"
        @out.write("0.0")
      when "int"
        @out.write("0")
      when "string"
        @out.write('""')
      end
    end
  end
end
