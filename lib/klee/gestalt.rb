module Klee
  class Gestalt
    def initialize(object, patterns:, ignored:)
      @object = object
      @patterns = patterns
      @ignored = Array(ignored) + Klee.instance_methods

      @plot = Hash.new { |h, k| h[k] = [] }
      @unusual = comparable
    end
    attr_reader :ignored, :patterns, :plot, :unusual

    def comparable
      @comparable ||= (@object.methods - ignored).map(&:to_s)
    end

    def sort
      patterns.each do |pattern|
        matcher = pattern.is_a?(Regexp) ? pattern : %r{#{Regexp.quote(pattern)}}
        matched = comparable.select { |method_name| matcher.match?(method_name.to_s) }
        @unusual.delete_if { |strange| matched.include?(strange) }

        key = clean_key(pattern)
        plot[key].push(*matched)
      end

      plot["unusual"].push(*unusual)

      self
    end

    private

    def clean_key(key)
      key.to_s.delete_prefix("(?-mix:").delete_suffix(")")
    end
  end
end
