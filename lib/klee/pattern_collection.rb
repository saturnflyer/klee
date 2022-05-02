module Klee
  class PatternCollection
    include Enumerable

    def initialize(&block)
      @patterns = []
      instance_eval(&block) if block
    end

    def prefix(which)
      match(/\A#{quote(which)}/)
    end

    def suffix(which)
      match(/#{quote(which)}\z/)
    end

    def middle(which)
      match(/.*#{quote(which)}.*/)
    end

    def match(which)
      @patterns << which
    end

    def each(&block)
      @patterns.each(&block)
    end

    private def quote(which)
      Regexp.quote(which)
    end
  end
end
