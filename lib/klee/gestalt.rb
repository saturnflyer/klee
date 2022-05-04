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

    def trace(threshold = 6)
      plot.clear
      patterns.each do |pattern|
        matcher = pattern.is_a?(Regexp) ? pattern : %r{#{Regexp.quote(pattern)}}

        matched = comparable.select { |method_name| matcher.match?(method_name.to_s) }
        @unusual.delete_if { |strange| matched.include?(strange) }

        key = clean_key(pattern)
        plot[key].merge(matched)
      end

      plot["unusual"].merge(unusual_set(threshold))

      self
    end

    def prefixes
      plot.select { |key, _| key.start_with?("\\A") }
    end

    def infixes
      plot.select { |key, _| key.match?(/\.\*.*\.\*/) }
    end

    def suffixes
      plot.select { |key, _| key.end_with?("\\z") }
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
