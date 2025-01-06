# typed: true
# frozen_string_literal: true

# The Lexer needs to be able to:
# 1. Scan the next token. This returns a token and advances the offset.
# 2. Peek at the next token but not advance the offset.
# 3. Move the offset to the next token without scanning it.

require_relative "lexer/token"

module Minic
  class Lexer
    DIGIT_NON_ZERO = T.let(("1"..."9").to_a, T::Array[String])
    DIGIT = T.let(("0"..."9").to_a, T::Array[String])
    LETTER = T.let([*"a".."z", *"A".."Z"], T::Array[String])
    ALPHANUMERIC = T.let(LETTER + DIGIT, T::Array[String])
    OPERATORS = ["!", "-", "+", "*", "/", "%", "&&", "||", "==", "<", ">"]
    KEYWORDS = ["void", "bool", "int", "double", "string", "while", "if", "else", "return"]
    WHITESPACE = [" ", "\t", "\r", "\n"]
    TOKENS = {
      ";" => :SemiColon,
      "/" => :ForwardSlash,
    }

    sig { params(body: String).void }
    def initialize(body:)
      @body = body
      @offset = T.let(0, Integer)
      @reading_offset = T.let(0, Integer)
    end

    sig { returns(Token) }
    def scan
      skip_whitespace
      accept

      literal = current_char

      return scan_identifier if LETTER.include?(literal)
      return scan_numeric if DIGIT.include?(literal)

      case literal
      when "foo"
        Token.new(token: :Foo, literal:, offset:)
      else
        return Token.new(token: :Eof, literal:, offset:) if eof?

        Token.new(token: :Invalid, literal:, offset:)
      end
    end

    sig { void }
    def advance
      return if eof?

      @reading_offset += 1
    end

    sig { returns(Token) }
    def peek
      scan.tap { @reading_offset = @offset }
    end

    private

    sig { returns(Integer) }
    attr_reader :offset

    sig { void }
    def accept
      @offset = @reading_offset
    end

    sig { returns(String) }
    def current_char
      return "" if eof?

      T.must(@body[@reading_offset])
    end

    sig { returns(T::Boolean) }
    def eof?
      @body.size <= @reading_offset
    end

    sig { returns(Token) }
    def scan_identifier
      literal = ""
      while ALPHANUMERIC.include?(current_char)
        literal += current_char
        advance
      end

      if KEYWORDS.include?(literal)
        Token.new(token: :Keyword, literal:, offset:)
      else
        Token.new(token: :Identifier, literal:, offset:)
      end
    end

    sig { returns(Token) }
    def scan_numeric
      literal = ""
      while DIGIT.include?(current_char)
        literal += current_char
        advance
      end

      Token.new(token: :Integer, literal:, offset:)
    end

    sig { void }
    def skip_whitespace
      advance if WHITESPACE.include?(current_char)
    end
  end
end
