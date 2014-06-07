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
      expect(Maybe(nil).eql? Maybe(nil)).to be_true
      expect(Maybe(nil).eql? Maybe(5)).to be_false
      expect(Maybe(5).eql? Maybe(5)).to be_true
      expect(Maybe(3).eql? Maybe(5)).to be_false
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

  describe "get and or_else" do
    it "get" do
      expect { None.get }.to raise_error
      expect(Some(1).get).to eql(1)
    end

    it "or_else" do
      expect(None().or_else(true)).to eql(true)
      expect(None().or_else { false }).to eql(false)
      expect(Some(1).or_else(2)).to eql(1)
      expect(Some(1).or_else { 2 }).to eql(1)
    end
  end

  describe "forward" do
    it "forwards methods" do
      expect(Some("maybe").upcase.get).to eql("MAYBE")
      expect(Some([1, 2, 3]).map { |arr| arr.map { |v| v * v } }.get).to eql([1, 4, 9])
    end
  end
end