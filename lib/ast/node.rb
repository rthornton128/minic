# typed: true
# frozen_string_literal: true

class Node
  extend T::Helpers

  abstract!

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

  sig { abstract.params(block: T.proc.params(node: Node).void).void }
  def walk(&block); end
end
