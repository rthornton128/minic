# frozen_string_literal: true

require "minitest/test_task"

desc "Run Minic"
task :run do
  ruby "./lib/minic.rb"
end

desc "Run linting (Rubocop)"
task :style do
  system("./bin/rubocop")
end
task st: :style
task lint: :style

desc "Run typechecking"
task :typecheck do
  system("./bin/spoom srb tc")
end
task tc: :typecheck

Minitest::TestTask.create(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.warning = false
  t.test_globs = ["test/**/*_test.rb"]
end

task default: :run
