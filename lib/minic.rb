# typed: true
# frozen_string_literal: true

require "bundler/setup"

Bundler.require(:default)

# Allow the root namespace and all classes to have access to the `sig` method.
extend T::Sig

class Module
  include T::Sig
end

# Temporary sanity check
puts "Hello, World!"
