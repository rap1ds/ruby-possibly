module Maybe
  class Maybe
    ([:each] + Enumerable.instance_methods).each do |enumerable_method|
      define_method(enumerable_method) { |*args, &block|
        res = __enumerable_value.send(enumerable_method, *args, &block)
        if res.respond_to?(:each) then Maybe(res.first) else res end
      }
    end

    def to_ary
      __enumerable_value
    end
    alias_method :to_a, :to_ary

    def ==(o)
      o.class == self.class
    end
    alias_method :eql?, :==
  end

  class Some < Maybe
    def get() @value; end
    def or_else(els=nil) @value; end
    def is_some?() true; end
    def is_none?() false; end
    def initialize(value) @value = value; end
    def ==(o)
      super && get == o.get
    end
    alias_method :eql?, :==
    def method_missing(method_sym, *args, &block)
      map { |value| value.send(method_sym, *args, &block) }
    end

    private
    def __enumerable_value() [@value]; end
  end

  class None < Maybe
    def get() raise "No such element"; end
    def or_else(els=nil) block_given? ? yield : els; end
    def is_some?() false; end
    def is_none?() true; end
    def method_missing(method_sym, *args, &block)
      None.new
    end

    private
    def __enumerable_value() []; end
  end
end

def Maybe(value)
  if value == nil || (value.respond_to?(:length) && value.length == 0)
    Maybe::None.new()
  else
    Maybe::Some.new(value)
  end
end