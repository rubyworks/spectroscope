describe Spectrum::Describe::Scope do

  describe "#let" do
    count = 0

    let(:counter) { count += 1 }

    it "memoizes the value" do
      counter.should == 1
      counter.should == 1
    end

    it "is not cached across examples" do
      counter.should == 2
    end
  end

  describe "#let!" do
    order = []
    count = 0

    let!(:counter) do
      order << :let!
      count += 1
    end

    it "calls the helper method in a before hook" do
      order << :example
      order.should == [:let!, :example]
      counter.should == 1
    end
  end

end
