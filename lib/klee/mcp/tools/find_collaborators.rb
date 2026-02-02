# frozen_string_literal: true

module Klee
  module MCP
    module Tools
      class FindCollaborators < ::MCP::Tool
        description "Discover which objects conceptually belong together by analyzing co-occurrence patterns. Shows what a given object typically works with."

        input_schema(
          properties: {
            patterns: {
              type: "array",
              items: {type: "string"},
              description: "Glob patterns to match Ruby files, e.g. ['app/**/*.rb']"
            },
            object: {
              type: "string",
              description: "The object/variable name to find collaborators for, e.g. 'User', 'order', 'cart'"
            },
            threshold: {
              type: "integer",
              description: "Minimum co-occurrences to be considered a collaborator (default: 2)"
            },
            scope: {
              type: "string",
              enum: ["file", "method"],
              description: "Scope for finding collaborators: 'file' (default) or 'method' level"
            },
            ignore: {
              type: "array",
              items: {type: "string"},
              description: "Object names to ignore"
            }
          },
          required: ["patterns", "object"]
        )

        class << self
          def call(patterns:, object:, threshold: 2, scope: "file", ignore: [], server_context: nil)
            validator = Klee::MCP::PathValidator.new
            validator.validate!(patterns)

            codebase = Klee.scan(*patterns, ignore: ignore, threshold: threshold)
            pairs = codebase.collaborators.pairs(scope: scope.to_sym)

            relevant_pairs = pairs.select { |pair, _| pair.include?(object) }

            collaborators = relevant_pairs.map do |pair, count|
              other = (pair - [object]).first
              {
                name: other,
                co_occurrences: count,
                scope: scope
              }
            end.sort_by { |c| -c[:co_occurrences] }

            result = {
              object: object,
              collaborators: collaborators
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
