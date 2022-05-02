# frozen_string_literal: true

require_relative "klee/version"
require_relative "klee/pattern_collection"
require_relative "klee/gestalt"

module Klee
  class Error < StandardError; end

  def klee_patterns(&block)
    @klee_patterns ||= Klee.patterns(&block)
  end

  def self.patterns(&block)
    PatternCollection.new(&block)
  end

  def self.[](object,
    patterns: object.respond_to?(:klee_patterns) ? object.klee_patterns : [],
    ignored: Class.instance_methods)
    Gestalt.new(object, patterns: patterns, ignored: ignored).sort
  end
end
