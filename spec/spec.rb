require 'maybe'

describe "maybe" do
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
    end

    it "#select" do
      expect(Some(2).select { |v| v % 2 == 0 }.get).to eql(2)
      expect(Some(1).select { |v| v % 2 == 0 }.isNone).to eql(true)
    end
  end

  describe "values and non-values" do
    it "None" do
      expect(Maybe(nil).isNone).to eql(true)
      expect(Maybe([]).isNone).to eql(true)
      expect(Maybe("").isNone).to eql(true)
    end

    it "Some" do
      expect(Maybe(0).isSome).to eql(true)
      expect(Maybe(false).isSome).to eql(true)
      expect(Maybe([1]).isSome).to eql(true)
      expect(Maybe(" ").isSome).to eql(true)
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

  describe "get and getOrElse" do
    it "get" do
      expect { None().get }.to raise_error
      expect(Some(1).get).to eql(1)
    end

    it "getOrElse" do
      expect(None().getOrElse(true)).to eql(true)
      expect(Some(1).getOrElse(2)).to eql(1)
    end
  end

  describe "forward" do
    it "forwards methods" do
      expect(Some("maybe").upcase.get).to eql("MAYBE")
      expect(Some([1, 2, 3]).map { |arr| arr.map { |v| v * v } }.get).to eql([1, 4, 9])
    end
  end
end