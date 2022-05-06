module Klee
  class PatternCollection
    include Enumerable

    def initialize(&block)
      @patterns = Hash.new { |h, k| h[k] = Set.new }
      instance_eval(&block) if block
    end

    def prefix(which)
      @patterns[:prefix].add which
      to_prefix(which).tap { match(_1) }
    end

    def suffix(which)
      @patterns[:suffix].add which
      to_suffix(which).tap { match(_1) }
    end

    def infix(which)
      @patterns[:infix].add which
      to_infix(which).tap { match(_1) }
    end

    def match(which)
      @patterns[:match].add which
      which
    end

    def each(&block)
      @patterns[:match].each(&block)
    end

    def parts
      @patterns[:prefix] + @patterns[:infix] + @patterns[:suffix]
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
