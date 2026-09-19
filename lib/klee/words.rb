# frozen_string_literal: true

module Klee
  module Words
    def self.from(name, ignore: [])
      ignored = ignore.map(&:to_s)
      tokenize(name).reject { |word| word.empty? || ignored.include?(word) }
    end

    def self.tokenize(name)
      name.to_s
        .gsub("::", "_")
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .downcase
        .gsub(/[?!=]/, "")
        .split(/[_\s]+/)
    end
  end
end
