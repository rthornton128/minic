# typed: true
# frozen_string_literal: true

require "minic"

require "minitest"
require "minitest/reporters"

Minitest::Reporters.use!

class TestCase < Minitest::Test
  class << self
    sig { params(block: T.proc.returns(T.anything)).void }
    def setup(&block)
      define_method(:setup) { instance_eval(&block) }
    end

    sig { params(block: T.proc.returns(T.anything)).void }
    def teardown(&block)
      define_method(:teardown) { instance_eval(&block) }
    end

    sig { params(desciption: String, block: T.nilable(T.proc.void)).void }
    def test(desciption, &block)
      block ||= proc do
        T.bind(self, Minitest::Test)
        skip("(no tests defined)")
      end
      name = Kernel.format("test_%s", desciption)

      define_method(name, &block)
    end
  end
end
