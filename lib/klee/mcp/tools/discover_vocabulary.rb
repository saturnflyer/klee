# frozen_string_literal: true

module Klee
  module MCP
    module Tools
      class DiscoverVocabulary < ::MCP::Tool
        description "Extract the domain language vocabulary from a Ruby codebase. Returns words that appear frequently in class and method names, revealing the key domain concepts."

        input_schema(
          properties: {
            patterns: {
              type: "array",
              items: {type: "string"},
              description: "Glob patterns to match Ruby files, e.g. ['app/**/*.rb', 'lib/**/*.rb']"
            },
            threshold: {
              type: "integer",
              description: "Minimum occurrences for a word to be included (default: 3)"
            },
            limit: {
              type: "integer",
              description: "Maximum number of vocabulary terms to return (default: 30)"
            },
            ignore: {
              type: "array",
              items: {type: "string"},
              description: "Words to ignore, e.g. common terms like 'get', 'set', 'new'"
            }
          },
          required: ["patterns"]
        )

        class << self
          def call(patterns:, threshold: 3, limit: 30, ignore: [], server_context: nil)
            validator = Klee::MCP::PathValidator.new
            validator.validate!(patterns)

            codebase = Klee.scan(*patterns, ignore: ignore, threshold: threshold)
            ranked = codebase.concepts.rank

            vocabulary = ranked.first(limit).map do |word, locations|
              {
                word: word,
                frequency: locations[:classes].size + locations[:methods].size,
                in_classes: locations[:classes].to_a,
                in_methods: locations[:methods].to_a
              }
            end

            ::MCP::Tool::Response.new([{
              type: "text",
              text: JSON.pretty_generate({vocabulary: vocabulary})
            }])
          end
        end
      end
    end
  end
end
