module Klee
  class Patterns
    include Enumerable

    def initialize(&block)
      @patterns = Hash.new { |h, k| h[k] = Set.new }
      instance_eval(&block) if block
    end

    def prefix(which)
      @patterns[__callee__].add which
      send("to_#{__callee__}", which).tap { match(_1) }
    end
    alias_method :suffix, :prefix
    alias_method :infix, :prefix

    def match(which)
      @patterns[:match].add which
      which
    end

    def prefixes
      @patterns[:prefix]
    end

    def infixes
      @patterns[:infix]
    end

    def suffixes
      @patterns[:suffix]
    end

    def each(&block)
      @patterns[:match].each(&block)
    end

    def keys
      @patterns.except(:match).values.inject(Set.new, :+)
    end

    def key_for(pattern)
      keys.find { pattern =~ _1 }
    end

    private

    def quote(which)
      Regexp.quote(which)
    end

    def to_match(which)
      which
    end

    def to_prefix(which)
      /\A#{quote(which)}/
    end

    def to_infix(which)
      /.*#{quote(which)}.*/
    end

    def to_suffix(which)
      /#{quote(which)}\z/
    end
  end
end
