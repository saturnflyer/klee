# frozen_string_literal: true

module Klee
  module MCP
    module Tools
      class CodebaseSummary < ::MCP::Tool
        description "Get a high-level vocabulary overview of a Ruby codebase for quick onboarding. Shows top domain concepts, concept clusters, and vocabulary metrics."

        input_schema(
          properties: {
            patterns: {
              type: "array",
              items: {type: "string"},
              description: "Glob patterns to match Ruby files, e.g. ['app/**/*.rb', 'lib/**/*.rb']"
            },
            threshold: {
              type: "integer",
              description: "Minimum occurrences for concepts (default: 2)"
            },
            ignore: {
              type: "array",
              items: {type: "string"},
              description: "Words to ignore"
            }
          },
          required: ["patterns"]
        )

        class << self
          def call(patterns:, threshold: 2, ignore: [], server_context: nil)
            validator = Klee::MCP::PathValidator.new
            validator.validate!(patterns)

            codebase = Klee.scan(*patterns, ignore: ignore, threshold: threshold)

            ranked = codebase.concepts.rank
            top_concepts = ranked.first(15).map(&:first)

            clusters = codebase.collaborators.clusters

            total_classes = Set.new
            total_methods = Set.new
            total_identifiers = 0

            codebase.concepts.each do |_, locs|
              total_classes.merge(locs[:classes])
              total_methods.merge(locs[:methods])
              total_identifiers += locs[:classes].size + locs[:methods].size
            end

            unique_concepts = ranked.keys.size
            vocabulary_richness = total_identifiers.zero? ? 0 : (unique_concepts.to_f / total_identifiers).round(2)

            result = {
              top_concepts: top_concepts,
              concept_clusters: clusters.size,
              total_classes: total_classes.size,
              total_methods: total_methods.size,
              vocabulary_richness: vocabulary_richness,
              cluster_preview: clusters.first(3).map { |c| c.to_a.sort }
            }

            ::MCP::Tool::Response.new([{
              type: "text",
              text: JSON.pretty_generate(result)
            }])
          end
        end
      end
    end
  end
end
