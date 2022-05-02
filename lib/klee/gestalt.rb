module Klee
  class Gestalt
    def initialize(object,
      patterns: object.respond_to?(:klee_patterns) ? object.klee_patterns : [],
      ignored: Class.instance_methods)
      @object = object
      @patterns = patterns
      @ignored = ignored

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
        key = pattern.to_s.delete_prefix("(?-mix:").delete_suffix(")")
        matched = comparable.select { |method_name| matcher.match?(method_name.to_s) }

        @unusual.delete_if { |strange| matched.include?(strange) }
        plot[key].push(*matched)
      end

      plot["unusual"].push(*unusual)

      self
    end
  end
end
