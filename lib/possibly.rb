# coding: utf-8
class Maybe
  ([:each] + Enumerable.instance_methods).each do |enumerable_method|
    define_method(enumerable_method) do |*args, &block|
      @invocation ||= [enumerable_method, args, block]
      res = __enumerable_value.send(enumerable_method, *args, &block)
      res.respond_to?(:each) ? Maybe(res.first, self.stack, @invocation) : res
    end
  end

  def to_ary
    __enumerable_value
  end
  alias_method :to_a, :to_ary

  def ==(other)
    other.class == self.class
  end
  alias_method :eql?, :==

  def inspect
    to_s
  end

  protected

  def print_error(msg)
    message =
      if msg
        msg + "\n\n"
      else
        "\n"
      end

    message + print_stack + "\n"
  end

  def print_stack
    longest_method = stack.drop(1).map { |inv| inv.first }.map(&:length).max || 0
    stack.map { |(method, value)|
      method ||= ""
      "#{method.ljust(longest_method)} => #{value}"
    }.join("\n")
  end

  def stack
    @parent_stack + [self_stack]
  end

  def self_stack
    [inst_method, self.inspect]
  end


  def inst_method
    "#{print_method(@inst_method)}"
  end

  def print_method(invocation)
    method, args, block = invocation

    print_method =
      if method == :[]
        args.to_s
      else
        method.to_s
      end

    print_args =
      if method == :[]
        nil
      elsif args.empty?
        nil
      else
        "(#{args.join(', ')})"
      end

    [print_method, print_args].compact.join("")
  end
end

# Represents a non-empty value
class Some < Maybe
  def initialize(value, inst_method = nil, parent_stack = [])
    @value = value
    @inst_method = inst_method || ["Some.new", []]
    @parent_stack = parent_stack
  end

  def get
    @value
  end

  def or_else(*)
    @value
  end

  def or_raise(*)
    @value
  end

  def or_nil
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
    other && other.class == self.class && @value === other.get
  end

  def method_missing(method_sym, *args, &block)
    @invocation ||= [method_sym, args, block]
    map { |value| value.send(method_sym, *args, &block) }
  end

  def to_s
    "Some(#{@value})"
  end

  private

  def __enumerable_value
    [@value]
  end
end

# Represents an empty value
class None < Maybe

  class ValueExpectedException < Exception; end

  def initialize(inst_method = nil, parent_stack = [])
    @inst_method = inst_method || ["None.new", []]
    @parent_stack = parent_stack
  end

  def get
    msg ||= "`get` called to None. A value was expected."
    raise ValueExpectedException.new(print_error(msg))
  end

  def or_else(els = nil)
    block_given? ? yield : els
  end

  def or_raise(*args)
    opts, args = extract_opts(args)
    msg_or_exception, msg = args
    default_message = "`or_raise` called to None. A value was expected."

    exception_object =
      if msg_or_exception.respond_to? :exception
        if msg
          msg_or_exception.exception(msg)
        else
          msg_or_exception.exception
        end
      else
        ValueExpectedException.new(msg_or_exception || default_message)
      end

    exception_and_stack =
      if opts[:print_stack] == false
        exception_object
      else
        exception_object.exception(print_error(exception_object.message))
      end

    raise exception_and_stack
  end

  def or_nil
    nil
  end

  # rubocop:disable PredicateName
  def is_some?
    false
  end

  def is_none?
    true
  end
  # rubocop:enable PredicateName

  def method_missing(method_sym, *args, &block)
    None([method_sym, args, block], self.stack)
  end

  def to_s
    "None"
  end

  private

  def __enumerable_value
    []
  end

  def extract_opts(args)
    *initial, last = *args

    if last.is_a?(::Hash)
      [last, initial]
    else
      [{}, args]
    end
  end
end

# rubocop:disable MethodName
def Maybe(value, parent_stack = [], inst_method = nil)
  inst_method ||= ["Maybe", []]
  if value.nil? || (value.respond_to?(:length) && value.length == 0)
    None(inst_method, parent_stack)
  else
    Some(value, inst_method, parent_stack)
  end
end

def Some(value, inst_method = nil, parent_stack = [])
  inst_method ||= ["Some", []]
  Some.new(value, inst_method, parent_stack)
end

def None(inst_method = nil, parent_stack = [])
  inst_method ||= ["None", []]
  None.new(inst_method, parent_stack)
end
# rubocop:enable MethodName
