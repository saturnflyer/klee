# frozen_string_literal: true

module Klee
  class Profile
    RAILS_GLOBS = %w[app/models/**/*.rb lib/**/*.rb].freeze

    STOPWORDS = %w[
      a an the and or not to for from of in on at by as
      is are was were been being have has had do does did
      will would could should may might must can
      this that these those it its they them we our you your
      if else then when
      with without via into over per vs all any
      id ids key keys current value values
    ].freeze

    def self.resolve(name, patterns:, ignore:, threshold:)
      case name&.to_sym
      when nil
        {patterns: patterns, ignore: Array(ignore), threshold: threshold}
      when :rails
        globs = patterns.empty? ? RAILS_GLOBS : patterns
        {
          patterns: globs,
          ignore: (STOPWORDS + Array(ignore).map(&:to_s)).uniq,
          threshold: threshold
        }
      else
        raise ArgumentError, "unknown profile #{name.inspect}"
      end
    end
  end
end
