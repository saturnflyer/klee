# frozen_string_literal: true

module Klee
  module MCP
    module Tools
      class ExploreConcept < ::MCP::Tool
        description "Deep-dive into a specific domain concept to see everywhere it appears in the codebase, what it co-occurs with, and naming patterns used."

        input_schema(
          properties: {
            patterns: {
              type: "array",
              items: {type: "string"},
              description: "Glob patterns to match Ruby files, e.g. ['app/**/*.rb']"
            },
            concept: {
              type: "string",
              description: "The domain concept word to explore, e.g. 'subscription', 'user', 'order'"
            },
            threshold: {
              type: "integer",
              description: "Minimum occurrences threshold (default: 1)"
            },
            ignore: {
              type: "array",
              items: {type: "string"},
              description: "Words to ignore"
            }
          },
          required: ["patterns", "concept"]
        )

        class << self
          def call(patterns:, concept:, threshold: 1, ignore: [], server_context: nil)
            validator = Klee::MCP::PathValidator.new
            validator.validate!(patterns)

            codebase = Klee.scan(*patterns, ignore: ignore, threshold: threshold)
            concept_data = codebase.concepts[concept]

            collaborator_pairs = codebase.collaborators.for(concept)
            co_occurs_with = collaborator_pairs.keys.sort_by { |k| -collaborator_pairs[k] }

            methods = concept_data[:methods].to_a
            naming_patterns = methods.group_by { |m| extract_pattern(m, concept) }
              .transform_values(&:sort)

            result = {
              concept: concept,
              appears_in: {
                classes: concept_data[:classes].to_a.sort,
                methods: methods.sort
              },
              co_occurs_with: co_occurs_with,
              naming_patterns: naming_patterns
            }

            ::MCP::Tool::Response.new([{
              type: "text",
              text: JSON.pretty_generate(result)
            }])
          end

          private

          def extract_pattern(method_name, concept)
            case method_name
            when /^#{concept}_/ then "#{concept}_*"
            when /_#{concept}$/ then "*_#{concept}"
            when /_#{concept}_/ then "*_#{concept}_*"
            when /#{concept}\?$/ then "#{concept}?"
            when /#{concept}!$/ then "#{concept}!"
            else "other"
            end
          end
        end
      end
    end
  end
end
