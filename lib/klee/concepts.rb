module Klee
  class Concepts
    include Enumerable

    def initialize(*method_names, modifiers: [])
      @method_names = method_names
      @modifiers = modifiers
    end
    attr_reader :method_names, :modifiers

    def call(threshold)
      warn "threshold is beyond the max count of #{max}" if threshold > max
      warn "threshold is below the min count of #{min}" if threshold < min
      clear
      @ideas = Set.new samples
        .select { |key, value|
          if value.to_i >= threshold
            key
          end
        }
        .compact
        .transform_keys(&:to_sym)
        .keys
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
      max_by { |_, v| v }.last
    end

    def min
      min_by { |_, v| v }.last
    end

    def minmax
      [min, max]
    end

    private

    def modifier_matcher
      @modifier_matcher ||= Regexp.new modifiers.map { Regexp.quote(it) }.join("|")
    end

    def words(method_name)
      method_name.to_s
        .then do |string|
          if modifiers.empty?
            string
          else
            string.gsub(modifier_matcher, "")
          end
        end
        .gsub(/\s/, "")
        .split("_")
        .delete_if { it.empty? }
    end
  end
end
