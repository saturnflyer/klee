# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rake/manifest"
require "reissue/gem"

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

Reissue::Task.create :reissue do |task|
  task.version_file = "lib/klee/version.rb"
  task.fragment = :git
end
