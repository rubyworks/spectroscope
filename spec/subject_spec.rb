describe "explict subject" do
  subject { [1,2,3] }

  it "should have the prescribed definition" do
    subject.should == [1,2,3]
  end

  describe '#its' do
    subject { [4,5,6] }

    its(:size){ should == 3 }
  end
end

describe 'implict subject' do

  describe Array do
    its(:size) { should === 0 }

    it "will be an empty Array" do
      should.empty?
    end
  end

end

