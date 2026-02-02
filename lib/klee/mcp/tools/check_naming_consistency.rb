# frozen_string_literal: true

module Klee
  module MCP
    module Tools
      class CheckNamingConsistency < ::MCP::Tool
        description "Find methods that deviate from established naming patterns. Identifies unusual names and suggests alternatives based on common conventions in the codebase."

        input_schema(
          properties: {
            patterns: {
              type: "array",
              items: {type: "string"},
              description: "Glob patterns to match Ruby files, e.g. ['app/**/*.rb']"
            },
            conventions: {
              type: "object",
              properties: {
                prefixes: {
                  type: "array",
                  items: {type: "string"},
                  description: "Expected method prefixes, e.g. ['find_', 'create_', 'update_', 'delete_']"
                },
                suffixes: {
                  type: "array",
                  items: {type: "string"},
                  description: "Expected method suffixes, e.g. ['?', '!', '_at', '_by']"
                }
              },
              description: "Naming conventions to check against"
            },
            threshold: {
              type: "integer",
              description: "Levenshtein distance threshold for similarity suggestions (default: 6)"
            },
            ignore: {
              type: "array",
              items: {type: "string"},
              description: "Method names to ignore"
            }
          },
          required: ["patterns"]
        )

        class << self
          def call(patterns:, conventions: {}, threshold: 6, ignore: [], server_context: nil)
            validator = Klee::MCP::PathValidator.new
            validator.validate!(patterns)

            codebase = Klee.scan(*patterns, ignore: ignore, threshold: 1)
            all_methods = codebase.concepts.flat_map { |_, locs| locs[:methods].to_a }.uniq

            prefixes = conventions["prefixes"] || conventions[:prefixes] || []
            suffixes = conventions["suffixes"] || conventions[:suffixes] || []

            conforming = {}
            unusual = []

            prefixes.each do |prefix|
              matched = all_methods.select { |m| m.start_with?(prefix) }
              conforming["#{prefix}*"] = matched.sort if matched.any?
            end

            suffixes.each do |suffix|
              matched = all_methods.select { |m| m.end_with?(suffix) }
              conforming["*#{suffix}"] = matched.sort if matched.any?
            end

            conforming_methods = conforming.values.flatten.uniq
            non_conforming = all_methods - conforming_methods

            non_conforming.each do |method|
              suggestion = find_similar(method, conforming_methods, threshold)
              unusual << if suggestion
                {
                  method: method,
                  suggestion: suggestion[:name],
                  similarity: suggestion[:distance]
                }
              else
                {method: method, suggestion: nil, similarity: nil}
              end
            end

            unusual.sort_by! { |u| u[:similarity] || Float::INFINITY }

            result = {
              conforming: conforming,
              unusual: unusual.first(50)
            }

            ::MCP::Tool::Response.new([{
              type: "text",
              text: JSON.pretty_generate(result)
            }])
          end

          private

          def find_similar(method, candidates, max_distance)
            best = nil
            best_distance = max_distance + 1

            candidates.each do |candidate|
              distance = levenshtein_distance(method, candidate)
              if distance < best_distance
                best = candidate
                best_distance = distance
              end
            end

            best ? {name: best, distance: best_distance} : nil
          end

          def levenshtein_distance(a, b)
            return b.length if a.empty?
            return a.length if b.empty?

            matrix = Array.new(a.length + 1) { Array.new(b.length + 1) }

            (0..a.length).each { |i| matrix[i][0] = i }
            (0..b.length).each { |j| matrix[0][j] = j }

            (1..a.length).each do |i|
              (1..b.length).each do |j|
                cost = (a[i - 1] == b[j - 1]) ? 0 : 1
                matrix[i][j] = [
                  matrix[i - 1][j] + 1,
                  matrix[i][j - 1] + 1,
                  matrix[i - 1][j - 1] + cost
                ].min
              end
            end

            matrix[a.length][b.length]
          end
        end
      end
    end
  end
end
