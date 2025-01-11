# typed: true
# frozen_string_literal: true

class Node
  sig { returns(String) }
  attr_reader :literal

  sig { returns(Integer) }
  attr_reader :length, :offset

  sig { params(literal: String, offset: Integer).void }
  def initialize(literal:, offset:)
    @length = T.let(literal.size, Integer)
    @literal = literal
    @offset = offset
  end
end
