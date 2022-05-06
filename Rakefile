# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rake/manifest"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/test_*.rb"]
end

require "standard/rake"

task default: %i[test standard]

Rake::Manifest::Task.new do |t|
  t.patterns = ["{bin,exe,lib,sig}/**/*", "LICENSE.txt", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "README.md"]
end
