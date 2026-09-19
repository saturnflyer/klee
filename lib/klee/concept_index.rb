# frozen_string_literal: true

require_relative "words"

module Klee
  class ConceptIndex
    include Enumerable

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

    private

    def words_from(name)
      Words.from(name, ignore: @ignore)
    end

    def filtered
      @data.select { |_, locs| (locs[:classes].size + locs[:methods].size) >= @threshold }
    end
  end
end
