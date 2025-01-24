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

    sig { params(block: AbstractSyntaxTree::Block).void }
    def generate_block(block)
      @out.puts("{")
      block.statements.each { |statement| generate_statement(statement) }
      @out.puts("}")
    end

    sig { params(expression: AbstractSyntaxTree::Expression).void }
    def generate_expression(expression)
      case expression
      when AbstractSyntaxTree::BooleanLiteral,
        AbstractSyntaxTree::DoubleLiteral,
        AbstractSyntaxTree::Identifier,
        AbstractSyntaxTree::IntegerLiteral,
        AbstractSyntaxTree::StringLiteral
        @out.write(expression.literal)
      when AbstractSyntaxTree::BinaryExpression
        generate_expression(expression.lhs)
        @out.write(expression.literal)
        generate_expression(expression.rhs)
      when AbstractSyntaxTree::FunctionCall
        generate_function_call(expression)
      when AbstractSyntaxTree::SubExpression
        @out.write("(")
        generate_expression(expression.expression)
        @out.write(")")
      when AbstractSyntaxTree::UnaryExpression
        @out.write(expression.literal)
        generate_expression(expression.rhs)
      end
    end

    sig { params(arguments: T::Array[AbstractSyntaxTree::Expression]).void }
    def generate_function_arguments(arguments)
      @out.write("(")
      arguments.each do |argument|
        generate_expression(argument)
        @out.write(",") unless argument == arguments.last
      end
      @out.write(")")
    end

    sig { params(function_call: AbstractSyntaxTree::FunctionCall).void }
    def generate_function_call(function_call)
      generate_identifier(function_call.identifier)
      generate_function_arguments(function_call.arguments)
    end

    sig { params(function_decl: AbstractSyntaxTree::FunctionDeclaration).void }
    def generate_function_declaration(function_decl)
      generate_type(function_decl.type)
      generate_space
      generate_identifier(function_decl.identifier)
      generate_parameter_list(function_decl.parameter_list)
      generate_terminal
    end

    sig { params(function_decl: AbstractSyntaxTree::FunctionDeclaration).void }
    def generate_function_implementation(function_decl)
      generate_type(function_decl.type)
      generate_space
      generate_identifier(function_decl.identifier)
      generate_parameter_list(function_decl.parameter_list)
      generate_block(function_decl.block)
    end

    sig { params(identifier: AbstractSyntaxTree::Identifier).void }
    def generate_identifier(identifier)
      @out.write(identifier.literal)
    end

    sig { params(if_statement: AbstractSyntaxTree::IfStatement).void }
    def generate_if_statement(if_statement)
      @out.write("if")
      @out.write("(")
      generate_expression(if_statement.conditional)
      @out.write(")")
      generate_block(if_statement.then_block)

      unless if_statement.else_block.nil?
        @out.write("else")
        generate_block(if_statement.then_block)
      end
    end

    sig { params(declaration: AbstractSyntaxTree::Declaration).void }
    def generate_implementation(declaration)
      case declaration
      when AbstractSyntaxTree::FunctionDeclaration
        generate_function_implementation(declaration)
      when AbstractSyntaxTree::VariableDeclaration
        generate_variable_decl(declaration)
        generate_terminal
      end
    end

    sig { params(parameter_list: AbstractSyntaxTree::ParameterList).void }
    def generate_parameter_list(parameter_list)
      @out.write("(")

      parameter_list.parameters.each do |parameter|
        generate_type(parameter.type)
        generate_space
        generate_identifier(parameter.identifier)
        @out.write(",") unless parameter == parameter_list.parameters.last
      end
      @out.write(")")
    end

    sig { params(program: AbstractSyntaxTree::Program).void }
    def generate_program(program)
      @out.puts('#include "minic.h"')
      program.declarations.each do |declaration|
        generate_function_declaration(declaration) if declaration.is_a?(AbstractSyntaxTree::FunctionDeclaration)
      end

      program.declarations.each do |declaration|
        generate_implementation(declaration)
      end
    end

    sig { void }
    def generate_space
      @out.write(" ")
    end

    sig { params(statement: AbstractSyntaxTree::Statement).void }
    def generate_statement(statement)
      case statement
      when AbstractSyntaxTree::AssignmentStatement
        generate_identifier(statement.lhs)
        @out.write("=")
        generate_expression(T.must(statement.rhs))
      when AbstractSyntaxTree::FunctionCall
        generate_function_call(statement)
      when AbstractSyntaxTree::IfStatement
        generate_if_statement(statement)
      when AbstractSyntaxTree::ReturnStatement
        @out.write("return")
        generate_space
        generate_expression(T.must(statement.expression)) unless statement.expression.nil?
      when AbstractSyntaxTree::VariableDeclaration
        generate_variable_decl(statement)
      when AbstractSyntaxTree::WhileStatement
        generate_while_statement(statement)
      else
        T.absurd(statement)
      end

      generate_terminal
    end

    sig { void }
    def generate_terminal
      @out.puts(";")
    end

    sig { params(type: AbstractSyntaxTree::Identifier).void }
    def generate_type(type)
      @out.write("char *)") if type.literal == "string"

      @out.write(type.literal)
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
        generate_expression(T.must(declaration.assignment))
      end
    end

    sig { params(while_statement: AbstractSyntaxTree::WhileStatement).void }
    def generate_while_statement(while_statement)
      @out.write("while")
      @out.write("(")
      generate_expression(while_statement.conditional)
      @out.write(")")
      generate_block(while_statement.block)
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
