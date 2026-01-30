# frozen_string_literal: true

module Klee
  class Codebase
    def initialize(*patterns, ignore: [], threshold: 2)
      @patterns = patterns
      @ignore = ignore
      @threshold = threshold
    end

    def concepts
      @concepts ||= build_concept_index
    end

    def collaborators
      @collaborators ||= build_collaborator_index
    end

    private

    def files
      @patterns.flat_map { |p| Dir.glob(p) }
        .uniq
        .select { |f| File.file?(f) && f.end_with?(".rb") }
    end

    def analyzers
      @analyzers ||= files.map { |path| FileAnalyzer.new(path) }
    end

    def build_concept_index
      index = ConceptIndex.new(ignore: @ignore, threshold: @threshold)
      analyzers.each { |a| index.add(a) }
      index
    end

    def build_collaborator_index
      index = CollaboratorIndex.new(ignore: @ignore, threshold: @threshold)
      analyzers.each { |a| index.add(a) }
      index
    end
  end
end
