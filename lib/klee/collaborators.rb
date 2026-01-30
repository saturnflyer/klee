# frozen_string_literal: true

require "prism"

module Klee
  class Collaborators
    def initialize(const)
      @const = const
    end
    attr_reader :const

    def lexed
      Prism.lex_file(Object.const_source_location(const.name).first)
    end

    def additional_processing_types = [:DOT, :BRACKET_LEFT]

    def identifier_with_additional_processing
      lexed.value.each_cons(2).filter_map do |(token, next_token)|
        if token.first.type == :IDENTIFIER &&
            additional_processing_types.include?(next_token.first.type)
          token.first.value
        end
      end
    end

    def tally
      identifier_with_additional_processing.tally
    end

    def rank
      tally.group_by do |_, count|
        count
      end.sort.reverse.to_h.transform_values do |value|
        value.map(&:first)
      end.reject do |key, value|
        value.empty? || key < 3
      end
    end
  end
end
