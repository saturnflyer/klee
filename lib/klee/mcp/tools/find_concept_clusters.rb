# frozen_string_literal: true

module Klee
  module MCP
    module Tools
      class FindConceptClusters < ::MCP::Tool
        description "Identify groups of domain concepts that frequently appear together in code, suggesting logical module boundaries or related functionality."

        input_schema(
          properties: {
            patterns: {
              type: "array",
              items: {type: "string"},
              description: "Glob patterns to match Ruby files, e.g. ['app/**/*.rb']"
            },
            threshold: {
              type: "integer",
              description: "Minimum co-occurrences for concepts to be considered related (default: 2)"
            },
            ignore: {
              type: "array",
              items: {type: "string"},
              description: "Collaborator names to ignore"
            }
          },
          required: ["patterns"]
        )

        class << self
          def call(patterns:, threshold: 2, ignore: [], server_context: nil)
            validator = Klee::MCP::PathValidator.new
            validator.validate!(patterns)

            codebase = Klee.scan(*patterns, ignore: ignore, threshold: threshold)
            raw_clusters = codebase.collaborators.clusters

            clusters = raw_clusters.map do |cluster_set|
              {
                concepts: cluster_set.to_a.sort,
                size: cluster_set.size
              }
            end

            ::MCP::Tool::Response.new([{
              type: "text",
              text: JSON.pretty_generate({clusters: clusters})
            }])
          end
        end
      end
    end
  end
end
