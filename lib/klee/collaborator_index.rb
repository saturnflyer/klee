# frozen_string_literal: true

module Klee
  class CollaboratorIndex
    def initialize(ignore: [], threshold: 2)
      @ignore = Set.new(ignore.map(&:to_s))
      @threshold = threshold
      @file_pairs = Hash.new(0)
      @method_pairs = Hash.new(0)
    end

    def add(file_analyzer)
      # File-level pairs
      collabs = filter(file_analyzer.collaborators.uniq)
      each_pair(collabs) { |pair| @file_pairs[pair] += 1 }

      # Method-level pairs
      file_analyzer.method_collaborators.each_value do |method_collabs|
        filtered = filter(method_collabs.uniq)
        each_pair(filtered) { |pair| @method_pairs[pair] += 1 }
      end
    end

    def pairs(scope: :file)
      source = (scope == :method) ? @method_pairs : @file_pairs
      source.select { |_, count| count >= @threshold }
        .sort_by { |_, count| -count }.to_h
    end

    def for(collaborator)
      name = collaborator.to_s
      pairs.select { |pair, _| pair.include?(name) }
        .transform_keys { |pair| (pair - [name]).first }
    end

    def clusters
      build_clusters(pairs)
    end

    private

    def filter(names)
      names.map(&:to_s).reject { |n| @ignore.include?(n) }
    end

    def each_pair(items)
      items.combination(2).each { |pair| yield pair.sort }
    end

    def build_clusters(pair_data)
      graph = Hash.new { |h, k| h[k] = Set.new }
      pair_data.each_key do |(a, b)|
        graph[a] << b
        graph[b] << a
      end

      visited = Set.new
      clusters = []

      graph.each_key do |node|
        next if visited.include?(node)

        cluster = Set.new
        stack = [node]

        while stack.any?
          current = stack.pop
          next if visited.include?(current)

          visited << current
          cluster << current
          stack.concat(graph[current].to_a)
        end

        clusters << cluster if cluster.size > 1
      end

      clusters.sort_by { |c| -c.size }
    end
  end
end
