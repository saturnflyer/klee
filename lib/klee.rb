# frozen_string_literal: true

# require "classifier-reborn"
require_relative "klee/version"
require_relative "klee/patterns"
require_relative "klee/gestalt"
require_relative "klee/concepts"

module Klee
  class Error < StandardError; end

  def self.extended(base)
    base.define_method(:klee_patterns) { self.class.klee_patterns }
  end

  def klee_patterns(&block)
    @klee_patterns ||= Klee.patterns(&block)
  end

  def self.patterns(&block)
    Patterns.new(&block)
  end

  def self.concepts(*method_names, modifiers: [])
    Concepts.new(*method_names, modifiers: [])
  end

  # def self.classifier
  #   @classifier ||= ClassifierReborn::Bayes.new "Interesting", "Uninteresting"
  # end

  def self.object_concepts(object, modifiers: [])
    names = if object.respond_to?(:public_instance_methods)
      object.public_instance_methods(false)
    else
      object.public_methods(false)
    end
    concepts(*names, modifiers: modifiers)
  end

  def self.[](object, threshold = 6,
    patterns: object.respond_to?(:klee_patterns) ? object.klee_patterns : raise(ArgumentError, "You must include patterns to match for #{object.inspect}"),
    ignored: Class.instance_methods)
    Gestalt.new(object, patterns: patterns, ignored: ignored).trace(threshold: threshold)
  end
end
