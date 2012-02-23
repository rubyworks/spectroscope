example_count = 0

describe "let" do

  let(:count) { example_count += 1 }

  it "memoizes the value" do
    count.should == 1
    count.should == 1
  end

  it "is not cached across examples" do
    count.should == 2
  end

end

