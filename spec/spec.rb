require 'possibly'

describe "possibly" do
  describe "enumerable" do
    it "#each" do
      expect { |b| Maybe::Some.new(1).each(&b) }.to yield_with_args(1)
      expect { |b| Maybe::None.new.each(&b) }.not_to yield_with_args
    end

    it "#map" do
      expect(Maybe::Some.new(2).map { |v| v * v }.get).to eql(4)
      expect { |b| Maybe::None.new.map(&b) }.not_to yield_with_args
    end

    it "#inject" do
      expect(Maybe::Some.new(2).inject(5) { |v| v * v }).to eql(25)
      expect { |b| Maybe::None.new.inject(&b) }.not_to yield_with_args
      expect(Maybe::None.new.inject(5) { }).to eql(5)
    end

    it "#select" do
      expect(Maybe::Some.new(2).select { |v| v % 2 == 0 }.get).to eql(2)
      expect(Maybe::Some.new(1).select { |v| v % 2 == 0 }.none?).to eql(true)
    end
  end

  describe "array" do
    it "#flatten" do
      expect(Maybe(nil).flatten.none?).to be_true
      expect(Maybe(Maybe(nil)).flatten.none?).to be_true
      expect(Maybe(Maybe(Maybe(nil))).flatten.none?).to be_true
      expect(Maybe(Maybe(Maybe(Maybe(nil)))).flatten.none?).to be_true

      expect(Maybe(1).flatten).to eql(Maybe(1))
      expect(Maybe(Maybe(2)).flatten).to eql(Maybe(2))
      expect(Maybe(Maybe(Maybe(3))).flatten).to eql(Maybe(3))
      expect(Maybe(Maybe(Maybe(Maybe(4)))).flatten).to eql(Maybe(4))

      # doesn't get mixed up with array#flatten
      expect(Maybe(Maybe([[2]])).flatten).to eql(Maybe([[2]]))
    end
  end

  describe "values and non-values" do
    it "None" do
      expect(Maybe(nil).none?).to eql(true)
      expect(Maybe([]).none?).to eql(true)
      expect(Maybe("").none?).to eql(true)
    end

    it "Some" do
      expect(Maybe(0).some?).to eql(true)
      expect(Maybe(false).some?).to eql(true)
      expect(Maybe([1]).some?).to eql(true)
      expect(Maybe(" ").some?).to eql(true)
    end
  end

  describe "is_a" do
    it "Some" do
      expect(Maybe::Some.new(1).is_a?(Maybe::Some)).to eql(true)
      expect(Maybe::Some.new(1).is_a?(Maybe::None)).to eql(false)
      expect(Maybe::None.new.is_a?(Maybe::Some)).to eql(false)
      expect(Maybe::None.new.is_a?(Maybe::None)).to eql(true)
      expect(Maybe::Some.new(1).is_a?(Maybe::Maybe)).to eql(true)
      expect(Maybe::None.new.is_a?(Maybe::Maybe)).to eql(true)
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

  describe "get and or_else" do
    it "get" do
      expect { Maybe::None.new.get }.to raise_error
      expect(Maybe::Some.new(1).get).to eql(1)
    end

    it "or_else" do
      expect(Maybe::None.new.or_else(true)).to eql(true)
      expect(Maybe::None.new.or_else { false }).to eql(false)
      expect(Maybe::Some.new(1).or_else(2)).to eql(1)
      expect(Maybe::Some.new(1).or_else { 2 }).to eql(1)
    end
  end

  describe "forward" do
    it "forwards methods" do
      expect(Maybe::Some.new("maybe").upcase.get).to eql("MAYBE")
      expect(Maybe::Some.new([1, 2, 3]).map { |arr| arr.map { |v| v * v } }.get).to eql([1, 4, 9])
    end
  end
end