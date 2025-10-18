# frozen_string_literal: true

if ENV["CI"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/test/"
    enable_coverage :branch
  end
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "klee"
require "debug"

require "minitest/autorun"
