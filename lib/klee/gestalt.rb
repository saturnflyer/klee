require "set"
module Klee
  class Gestalt
    def initialize(object, patterns:, ignored:)
      @object = object
      @patterns = patterns
      @ignored = Array(ignored) + Klee.public_instance_methods

      @plot = Hash.new { |h, k| h[k] = Set.new }
      @unusual = comparable.dup
    end
    attr_reader :ignored, :patterns, :plot, :unusual

    def comparable
      @comparable ||= Set.new(@object.public_methods - ignored).map(&:to_s).freeze
    end

    def trace(threshold: 6, modifiers: [], concept_threshold: 3)
      plot.clear
      patterns.each do |pattern|
        matched = comparable.select { |method_name| pattern.match?(method_name.to_s) }
        @unusual.delete_if { |strange| matched.include?(strange) }

        plot[patterns.key_for(pattern)].merge(matched)
      end

      plot["unusual"].merge(unusual_set(threshold))
      plot["concepts"].merge(concepts(modifiers: modifiers, threshold: concept_threshold))

      self
    end

    def concepts(modifiers: [], threshold: 3)
      @concepts ||= Concepts.new(*unusual, modifiers: modifiers).call(threshold)
    end

    def [](key)
      trace if plot.empty?
      plot.fetch(key)
    end

    def prefixes
      plot.select { |key, _| patterns.prefixes.include?(key) }
    end

    def infixes
      plot.select { |key, _| patterns.infixes.include?(key) }
    end

    def suffixes
      plot.select { |key, _| patterns.suffixes.include?(key) }
    end

    def unusual?(*items)
      items.to_set <= plot["unusual"].flatten
    end

    private

    def clean_key(key)
      key.to_s.delete_prefix("(?-mix:").delete_suffix(")")
    end

    def unusual_set(threshold)
      Set.new(unusual).divide { |a, b|
        DidYouMean::Levenshtein.distance(a, b) < threshold
      }
    end
  end
end
