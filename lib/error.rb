# typed: true
# frozen_string_literal: true

module Minic
  class Error < StandardError
    sig { params(message: String, literal: String, offset: Integer, position: FileSet::Position).void }
    def initialize(message, literal = "", offset = 0,
      position: FileSet::Position.new(name: "unknown", row: 0, column: 0))
      super(message)

      @position = position
    end

    sig { returns(String) }
    def to_s
      "#{@position}: #{super}"
    end
  end
end
