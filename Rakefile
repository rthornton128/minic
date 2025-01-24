# frozen_string_literal: true

require "minitest/test_task"

require "open3"
require "pathname"
require "sorbet-runtime"

extend T::Sig # rubocop:disable Sorbet/RedundantExtendTSig

desc "Build stdlib"
task :build_lib do
  sources = Dir["src/*.c"]

  objects = sources.each_with_object([]) do |filepath, objects|
    object = filepath.pathmap("build/%n.o")
    objects << object

    command("gcc", "-c", filepath, "-o", object)
  end

  command("ar", "rcs", "build/libminic.a", *objects)

  cp Dir["src/*.h"], "build"
end

task build: :build_lib do
  command("gcc", "-o", "build/program", "-L", "build", "-lminic", "build/program.c")
end

desc "Run Minic"
task :run do
  ruby "./lib/minic.rb"
end

desc "Run linting (Rubocop)"
task :style do
  command("./bin/rubocop")
end
task st: :style
task lint: :style

desc "Run typechecking"
task :typecheck do
  command("./bin/spoom", "srb", "tc")
end
task tc: :typecheck

Minitest::TestTask.create(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.warning = false
  t.test_globs = ["test/**/*_test.rb"]
end
task t: :test

task default: :run

private

def command(*args) # rubocop:disable Sorbet/EnforceSignatures
  puts args.join(" ")
  stdout, stderr, _status = Open3.capture3(*args)
  puts stdout unless stdout == ""
  puts stderr unless stderr == ""
end
