def Some(value) Some.new(value); end
def None() None.new(); end
def Maybe(value) if value == nil || (value.respond_to?(:length) && value.length == 0) then None() else Some(value) end; end

class Maybe; end

class Some < Maybe
  def get() @value; end
  def getOrElse(els) @value; end
  def isSome() true; end
  def isNone() false; end
  def initialize(value) @value = value; end
  def method_missing(method_sym, *args, &block)
    if [].respond_to? method_sym
      res = [@value].send(method_sym, *args, &block)
      if res.respond_to?(:each) then Maybe(res[0]) else res end
    else
      Maybe(@value.send(method_sym, *args, &block))
    end
  end
end

class None < Maybe
  def get() raise "No such element"; end
  def getOrElse(els) els; end
  def isSome() false; end
  def isNone() true; end
  def method_missing(method_sym, *args, &block) None(); end
end