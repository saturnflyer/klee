# frozen_string_literal: true

module Klee
  module MCP
    class PathValidator
      def initialize(allowed_roots: [Dir.pwd])
        @allowed_roots = allowed_roots.map { |r| File.expand_path(r) }
      end

      def validate!(patterns)
        patterns.each do |pattern|
          expanded = expand_pattern_root(pattern)
          unless allowed?(expanded)
            raise SecurityError, "Pattern '#{pattern}' resolves to '#{expanded}' which is outside allowed roots: #{@allowed_roots.join(", ")}"
          end
        end
      end

      private

      def expand_pattern_root(pattern)
        base = pattern.split(/[*?\[{]/).first || "."
        base = "." if base.empty?
        File.expand_path(base)
      end

      def allowed?(path)
        @allowed_roots.any? { |root| path.start_with?(root) }
      end
    end
  end
end
