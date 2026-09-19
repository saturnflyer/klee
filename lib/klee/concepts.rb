# frozen_string_literal: true

require_relative "words"

module Klee
  class Concepts
    include Enumerable

    def initialize(*method_names, modifiers: [])
      @method_names = method_names
      @modifiers = Array(modifiers).map(&:to_s)
    end
    attr_reader :method_names, :modifiers

    def call(threshold)
      unless samples.empty?
        warn "threshold is beyond the max count of #{max}" if threshold > max
        warn "threshold is below the min count of #{min}" if threshold < min
      end

      method_groups.select { |_, methods| methods.size >= threshold }
    end
    alias_method :[], :call

    def clear
      clearable = instance_variables - %i[@method_names @modifiers]
      clearable.each { send(:remove_instance_variable, it) }
    end

    def each(&block)
      samples.each(&block)
    end

    def samples
      @samples ||= method_names.flat_map { words(it) }.tally
    end

    def max
      return 0 if samples.empty?

      max_by { |_, v| v }.last
    end

    def min
      return 0 if samples.empty?

      min_by { |_, v| v }.last
    end

    def minmax
      [min, max]
    end

    private

    def method_groups
      groups = Hash.new { |h, k| h[k] = [] }
      method_names.each do |name|
        words(name).uniq.each { |word| groups[word.to_sym] << name.to_sym }
      end
      groups
    end

    def modifier_matcher
      @modifier_matcher ||= Regexp.new(modifiers.map { Regexp.quote(it) }.join("|"))
    end

    def words(method_name)
      string = method_name.to_s
      string = string.gsub(modifier_matcher, "") unless modifiers.empty?
      Words.from(string)
    end
  end
end
