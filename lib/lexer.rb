# typed: true
# frozen_string_literal: true

# The Lexer needs to be able to:
# 1. Scan the next token. This returns a token and advances the offset.
# 2. Peek at the next token but not advance the offset.
# 3. Move the offset to the next token without scanning it.

require_relative "lexer/token"
require_relative "fileset"

module Minic
  class Lexer
    DIGIT_NON_ZERO = T.let(("1"..."9").to_a, T::Array[String])
    DIGIT = T.let(("0"..."9").to_a, T::Array[String])
    LETTER = T.let([*"a".."z", *"A".."Z"], T::Array[String])
    ALPHANUMERIC = T.let(LETTER + DIGIT, T::Array[String])
    KEYWORDS = ["void", "bool", "int", "double", "string", "while", "if", "else", "return"]
    BOOLEANS = ["true", "false"]
    WHITESPACE = [" ", "\t", "\r", "\n"]
    SYMBOLS = T.let(
      {
        ";" => :SemiColon,
        "=" => :Equal,
        "(" => :LeftParen,
        ")" => :RightParen,
        "{" => :LeftBrace,
        "}" => :RightBrace,
        "," => :Comma,
        "." => :Dot,
        '"' => :DoubleQuote,
        "/" => :ForwardSlash,
        "!" => :Exclamation,
        "+" => :Plus,
        "-" => :Minus,
        "*" => :Star,
        "%" => :Percent,
        "&&" => :And,
        "||" => :Or,
        "==" => :Equality,
        "<" => :LessThan,
        ">" => :GreaterThan,
      },
      T::Hash[String, Symbol],
    )

    class InvalidTokenError < Error; end
    class InvalidIntegerError < Error; end
    class UnterminatedStringError < Error; end

    sig { params(file: FileSet::File).void }
    def initialize(file:)
      @body = T.let(file.body, String)
      @file = file
      @offset = T.let(0, Integer)
      @reading_offset = T.let(0, Integer)
    end

    sig { returns(FileSet::File) }
    attr_reader :file

    sig { returns(Token) }
    def scan
      skip_whitespace
      accept

      literal = current_char

      return scan_identifier if LETTER.include?(literal)
      return scan_numeric if DIGIT.include?(literal)
      return scan_string if literal == '"'
      return scan_comment if literal == "/" && peek == "/"
      return scan_symbol(literal) if SYMBOLS.keys.include?(literal)

      raise InvalidTokenError.new("Unexpected token", literal, offset) unless eof?

      Token.new(token: :Eof, literal:, position:)
    end

    sig { returns(T::Boolean) }
    def eof?
      @body.size <= @reading_offset
    end

    private

    sig { returns(Integer) }
    attr_reader :offset

    sig { void }
    def accept
      @offset = @reading_offset
      @offset -= 1 if eof? && @offset > 0
    end

    sig { void }
    def advance
      @reading_offset += 1 unless eof?
    end

    sig { returns(String) }
    def current_char
      return "" if eof?

      T.must(@body[@reading_offset])
    end

    sig { returns(String) }
    def peek
      @reading_offset += 1
      current_char.tap { @reading_offset = @offset }
    end

    sig { returns(Token) }
    def scan_identifier
      literal = ""
      while ALPHANUMERIC.include?(current_char)
        literal += current_char
        advance
      end

      return Token.new(token: :Keyword, literal:, position:) if KEYWORDS.include?(literal)
      return Token.new(token: :Boolean, literal:, position:) if BOOLEANS.include?(literal)

      Token.new(token: :Identifier, literal:, position: @file.position(@offset))
    end

    sig { returns(Token) }
    def scan_numeric
      literal = ""
      while DIGIT.include?(current_char)
        literal += current_char
        advance
      end

      return scan_double(literal) if current_char == "."

      raise InvalidIntegerError.new(
        "Integer may not start with zero",
        literal,
        offset,
      ) if literal[0] == "0" && literal.size > 1

      Token.new(token: :Integer, literal:, position:)
    end

    sig { params(literal: String).returns(Token) }
    def scan_double(literal)
      literal += current_char
      advance

      while DIGIT.include?(current_char)
        literal += current_char
        advance
      end

      Token.new(token: :Double, literal:, position:)
    end

    sig { returns(Token) }
    def scan_string
      literal = current_char
      advance

      until current_char == '"' || current_char == "\n" || eof?
        literal += current_char
        advance
      end

      final_quote = current_char
      raise UnterminatedStringError.new(
        "string was not terminated by end of line",
        literal,
        offset,
      ) if final_quote != '"'

      literal += final_quote
      advance
      Token.new(token: :String, literal:, position:)
    end

    sig { returns(Token) }
    def scan_comment
      literal = ""
      until current_char == "\n" || eof?
        literal += current_char
        advance
      end

      Token.new(token: :Comment, literal:, position:)
    end

    sig { params(literal: String).returns(Token) }
    def scan_symbol(literal)
      next_char = peek

      if SYMBOLS.keys.include?(literal + next_char)
        literal += next_char
        advance
      end

      Token.new(token: T.must(SYMBOLS[literal]), literal:, position:).tap { advance }
    end

    sig { void }
    def skip_whitespace
      return if eof?

      while WHITESPACE.include?(current_char)
        @file << @reading_offset if current_char == "\n"
        advance
      end
    end

    sig { returns(FileSet::Position) }
    def position
      @file.position(@offset)
    end
  end
end
