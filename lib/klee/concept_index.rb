# frozen_string_literal: true

require_relative "words"

module Klee
  class ConceptIndex
    include Enumerable

    Entry = Data.define(:word, :class_count, :method_count, :class_names, :method_names, :bias)

    VERBS = %w[
      build calculate extract apply compute detect update create find get set
      add ensure render save destroy validate serialize
      parse process fetch refresh call fill infer display generate
      normalize coerce prepare predict split sanitize mark
    ].freeze

    UNIT_PATTERNS = {
      "seconds" => /_seconds\z/,
      "minutes" => /_minutes\z/,
      "kg" => /_kg\z/,
      "m" => /_m\z/,
      "reps" => /_reps\z/
    }.freeze

    def initialize(ignore: [], threshold: 2)
      @ignore = Set.new(ignore.map(&:to_s))
      @threshold = threshold
      @data = Hash.new { |h, k| h[k] = {classes: Set.new, methods: Set.new} }
    end

    def add(file_analyzer)
      file_analyzer.class_names.each do |name|
        words_from(name).each { |word| @data[word][:classes] << name }
      end

      file_analyzer.method_names.each do |name|
        words_from(name).each { |word| @data[word][:methods] << name }
      end
    end

    def [](concept)
      @data[concept.to_s]
    end

    def each(&block)
      filtered.each(&block)
    end

    def rank
      filtered.sort_by { |word, locs| -(locs[:classes].size + locs[:methods].size) }.to_h
    end

    def catalog
      rank.map do |word, locs|
        Entry.new(
          word: word,
          class_count: locs[:classes].size,
          method_count: locs[:methods].size,
          class_names: locs[:classes],
          method_names: locs[:methods],
          bias: bias_for(word, locs)
        )
      end
    end

    def gaps(min_methods: 8, max_classes: 3)
      filtered.each_with_object({}) do |(word, locs), acc|
        next if VERBS.include?(word)
        next if locs[:methods].size < min_methods
        next if locs[:classes].size > max_classes

        acc[word] = {
          classes: locs[:classes].size,
          methods: locs[:methods].size,
          names: locs[:methods]
        }
      end
    end

    def units
      names = @data.each_value.flat_map { |locs| locs[:methods].to_a }.uniq
      UNIT_PATTERNS.each_with_object({}) do |(unit, pattern), acc|
        matched = names.grep(pattern)
        acc[unit] = matched.sort if matched.size >= @threshold
      end
    end

    private

    def words_from(name)
      Words.from(name, ignore: @ignore)
    end

    def filtered
      @data.select { |_, locs| (locs[:classes].size + locs[:methods].size) >= @threshold }
    end

    def bias_for(word, locs)
      return :verb if VERBS.include?(word)

      class_count = locs[:classes].size
      method_count = locs[:methods].size
      return :type if class_count > method_count
      return :gap if method_count >= 8 && class_count <= 3

      :mixed
    end
  end
end
