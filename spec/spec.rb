require 'possibly'

describe "possibly" do
  describe "enumerable" do
    it "#each" do
      expect { |b| Some(1).each(&b) }.to yield_with_args(1)
      expect { |b| None().each(&b) }.not_to yield_with_args
    end

    it "#map" do
      expect(Some(2).map { |v| v * v }.get).to eql(4)
      expect { |b| None().map(&b) }.not_to yield_with_args
    end

    it "#inject" do
      expect(Some(2).inject(5) { |v| v * v }).to eql(25)
      expect { |b| None().inject(&b) }.not_to yield_with_args
      expect(None().inject(5) { }).to eql(5)
    end

    it "#select" do
      expect(Some(2).select { |v| v % 2 == 0 }.get).to eql(2)
      expect(Some(1).select { |v| v % 2 == 0 }.is_none?).to eql(true)
    end

    it "#flat_map" do
      div = ->(num, denom) {
        if (denom == 0)
          Maybe(nil)
        else
          Maybe(num.to_f / denom.to_f)
        end
      }
      expect(Maybe(5).flat_map { |x| div.call(1, x) }).to eql(Maybe(0.2))
      expect(Maybe(0).flat_map { |x| div.call(1, x) }).to eql(None())
    end
  end

  describe "values and non-values" do
    it "None" do
      expect(Maybe(nil).is_none?).to eql(true)
      expect(Maybe([]).is_none?).to eql(true)
      expect(Maybe("").is_none?).to eql(true)
    end

    it "Some" do
      expect(Maybe(0).is_some?).to eql(true)
      expect(Maybe(false).is_some?).to eql(true)
      expect(Maybe([1]).is_some?).to eql(true)
      expect(Maybe(" ").is_some?).to eql(true)
    end
  end

  describe "is_a" do
    it "Some" do
      expect(Some(1).is_a?(Some)).to eql(true)
      expect(Some(1).is_a?(None)).to eql(false)
      expect(None().is_a?(Some)).to eql(false)
      expect(None().is_a?(None)).to eql(true)
      expect(Some(1).is_a?(Maybe)).to eql(true)
      expect(None().is_a?(Maybe)).to eql(true)
    end
  end

  describe "equality" do
    it "#eql?" do
      expect(Maybe(nil).eql? Maybe(nil)).to be true
      expect(Maybe(nil).eql? Maybe(5)).to be false
      expect(Maybe(5).eql? Maybe(5)).to be true
      expect(Maybe(3).eql? Maybe(5)).to be false
    end
  end

  describe "case equality" do
    it "#===" do
      expect(Some(1) === Some(1)).to be true
      expect(Maybe(1) === Some(2)).to be false
      expect(Some(1) === None).to be false
      expect(None === Some(1)).to be false
      expect(None === None()).to be true
      expect(Some((1..3)) === Some(2)).to be true
      expect(Some(Integer) === Some(2)).to be true
      expect(Maybe === Some(2)).to be true
      expect(Maybe === None()).to be true
      expect(Some === Some(6)).to be true

      expect(Some(1) === Some(1).lazy).to be true
      expect(Maybe(1) === Some(2).lazy).to be false
      expect(None === Some(1).lazy).to be false
      expect(None === None().lazy).to be true
      expect(Some((1..3)) === Some(2).lazy).to be true
      expect(Some(Integer) === Some(2).lazy).to be true
      expect(Maybe === Some(2).lazy).to be true
      expect(Maybe === None().lazy).to be true
      expect(Some === Some(6).lazy).to be true
    end
  end

  describe "case expression" do
    def test_case_when(case_value, match_value, non_match_value)
      value = case case_value
      when non_match_value
        false
      when match_value
        true
      else
        false
      end

      expect(value).to be true
    end

    it "matches Some" do
      test_case_when(Maybe(1), Some, None)
    end

    it "matches None" do
      test_case_when(Maybe(nil), None, Some)
    end

    it "matches to integer value" do
      test_case_when(Maybe(1), Some(1), Some(2))
    end

    it "matches to range" do
      test_case_when(Maybe(1), Some((0..2)), Some((2..3)))
    end

    it "matches to lambda" do
      even = ->(a) { a % 2 == 0 }
      odd = ->(a) { a % 2 == 1 }
      test_case_when(Maybe(2), Some(even), Some(odd))
    end

    it "matches to lazy" do
      test_case_when(Maybe { 1 }, Some(1), Some(2))
    end
  end

  describe "to array" do
    it "#to_ary" do
      a, _ = Maybe(1)
      expect(a).to eql(1)
      expect([Maybe(1)].map { |(x)| x }).to eql([1])
    end

    it "#to_a" do
      expect(Maybe(1).to_a).to eql([1])
      expect(Maybe(nil).to_a).to eql([])
    end
  end

  describe "get and get_or_else" do
    it "get" do
      expect { None.get }.to raise_error
      expect(Some(1).get).to eql(1)
    end

    it "get_or_else" do
      expect(None().get_or_else(true)).to eql(true)
      expect(None().get_or_else { false }).to eql(false)
      expect(Some(1).get_or_else(2)).to eql(1)
      expect(Some(1).get_or_else { 2 }).to eql(1)
    end
  end

  describe "or_else" do
    it "returns self if it's a Some" do
      current = Maybe(true)
      other = Maybe(true)

      expect(current.or_else(other)).to equal current
    end

    it "returns other if it's a Some" do
      current = Maybe(nil)
      other = Maybe(true)

      expect(current.or_else(other)).to equal other
    end

    it "takes also a block" do
      current = Maybe(true)
      other = Maybe(true)

      expect(current.or_else { other }).to equal current
    end
  end

  describe "forward" do
    it "forwards methods" do
      expect(Some("maybe").upcase.get).to eql("MAYBE")
      expect(Some([1, 2, 3]).map { |arr| arr.map { |v| v * v } }.get).to eql([1, 4, 9])
    end
  end

  describe "inner" do
    it "forwards all (also Enumerable) methods" do
      expect(Some(["first", "second", "third"]).inner.first.upcase.get_or_else { false }).to eql("FIRST")
      expect(Some(["first", "second", "third"]).inner.map(&:upcase).get_or_else { false }).to eql(["FIRST", "SECOND", "THIRD"])
      expect(Some([]).inner.first.upcase.get_or_else { "NONE" }).to eql("NONE")
    end
  end

  describe "combine" do
    it "combines multiple Some values" do
      expect(Maybe("foo").combine(Maybe("bar")).get).to eql(["foo", "bar"])
      expect(Maybe("foo").combine(Maybe("bar"), Maybe("baz")).get).to eql(["foo", "bar", "baz"])
      expect(Maybe.combine(Maybe("foo"), Maybe("bar"), Maybe("baz")).get).to eql(["foo", "bar", "baz"])
      expect(Maybe.combine(Maybe("foo"), Maybe("bar"), Maybe("baz")).map do |(foo, bar, baz)|
        "#{foo} and #{bar} and finally, #{baz}"
      end.get).to eql ("foo and bar and finally, baz")
    end

    it "returns None if any None" do
      expect(Maybe("foo").combine(Maybe(nil)).get_or_else { false }).to eql(false)
      expect(Maybe("foo").combine(Maybe(nil)) { |a, b| "#{a} + #{b}" }.get_or_else { false }).to eql(false)
      expect(Maybe.combine(Maybe("foo"), Maybe(nil)).get_or_else { false }).to eql(false)
      expect(Maybe.combine(Maybe("foo"), Maybe(nil)) { |a, b| "#{a} + #{b}" }.get_or_else { false }).to eql(false)
    end
  end

  describe "laziness" do
    it "can be initialized lazily" do
      init_called = false
      map_called = false

      m = Maybe do
        init_called = true
        2
      end.map do |v|
        map_called = true
        v * v
      end

      expect(init_called).to eql(lazy_enabled ? false : true)
      expect(map_called).to eql(lazy_enabled ? false : true)
      expect(m.get).to eql(4)
      expect(init_called).to eql(true)
      expect(map_called).to eql(true)
    end

    it "can be converted to lazy" do
      map_called = false

      m = Maybe(2).lazy.map do |v|
        map_called = true
        v * v
      end

      expect(map_called).to eql(lazy_enabled ? false : true)
      expect(m.get).to eql(4)
      expect(map_called).to eql(true)
    end
  end

  def lazy_enabled
    @lazy_enabled ||= [].respond_to?(:lazy)
  end
end
