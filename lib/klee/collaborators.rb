# frozen_string_literal: true

module Klee
  class Collaborators
    def initialize(const)
      unless const.is_a?(Module)
        raise ArgumentError, "expected a class or module, got #{const.inspect}"
      end

      path = Object.const_source_location(const.name)&.first
      unless path && File.file?(path)
        raise Error, "cannot locate source for #{const}"
      end

      @const = const
      @analyzer = FileAnalyzer.new(path)
    end
    attr_reader :const

    def tally
      @analyzer.collaborators.tally
    end

    def rank
      tally.group_by { |_, count| count }
        .sort.reverse.to_h
        .transform_values { |value| value.map(&:first) }
        .reject { |key, _value| key < 3 }
    end
  end
end
