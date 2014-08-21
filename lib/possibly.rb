class Maybe
  ([:each] + Enumerable.instance_methods).each do |enumerable_method|
    define_method(enumerable_method) do |*args, &block|
      res = __enumerable_value.send(enumerable_method, *args, &block)
      res.respond_to?(:each) ? rewrap(res) : res
    end
  end

  def initialize(lazy_enumerable)
    @lazy = lazy_enumerable
  end

  def to_ary
    __enumerable_value
  end
  alias_method :to_a, :to_ary

  def ==(other)
    other.class == self.class
  end
  alias_method :eql?, :==

  def get
    __evaluated.get
  end

  def or_else(*args)
    __evaluated.or_else(*args)
  end

  # rubocop:disable PredicateName
  def is_some?
    __evaluated.is_some?
  end

  def is_none?
    __evaluated.is_none?
  end
  # rubocop:enable PredicateName

  def lazy
    Maybe.new(__enumerable_value.lazy)
  end

  private

  def __enumerable_value
    @lazy
  end

  def __evaluated
    @evaluated ||= Maybe(@lazy.first)
  end

  def rewrap(enumerable)
    Maybe.new(enumerable)
  end

  def self.from_block(&block)
    Maybe.new(lazy_enum_from_block(&block))
  end

  def self.lazy_enum_from_block(&block)
    Enumerator.new do |yielder|
      yielder << block.call
    end.lazy
  end

end

# Represents a non-empty value
class Some < Maybe
  def initialize(value)
    @value = value
  end

  def get
    @value
  end

  def or_else(*)
    @value
  end

  # rubocop:disable PredicateName
  def is_some?
    true
  end

  def is_none?
    false
  end
  # rubocop:enable PredicateName

  def ==(other)
    super && get == other.get
  end
  alias_method :eql?, :==

  def ===(other)
    other && (other.class == self.class || other.class == Maybe) && @value === other.get
  end

  def self.===(other)
    super || (other.class == Maybe && other.is_some?)
  end

  def method_missing(method_sym, *args, &block)
    map { |value| value.send(method_sym, *args, &block) }
  end

  private

  def __enumerable_value
    [@value]
  end

  def rewrap(enumerable)
    Maybe(enumerable.first)
  end
end

# Represents an empty value
class None < Maybe
  def initialize; end

  def get
    fail 'No such element'
  end

  def or_else(els = nil)
    block_given? ? yield : els
  end

  # rubocop:disable PredicateName
  def is_some?
    false
  end

  def is_none?
    true
  end
  # rubocop:enable PredicateName

  def self.===(other)
    super || (other.class == Maybe && other.is_none?)
  end

  def method_missing(*)
    self
  end

  private

  def __enumerable_value
    []
  end
end

# rubocop:disable MethodName
def Maybe(value = nil, &block)
  if block
    Maybe.from_block(&block)
  else
    if value.nil? || (value.respond_to?(:length) && value.length == 0)
      None()
    else
      Some(value)
    end
  end
end

def Some(value)
  Some.new(value)
end

def None
  None.new
end
# rubocop:enable MethodName
