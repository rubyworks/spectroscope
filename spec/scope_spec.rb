describe "scopes are independent instances" do

  it "defines an instance variable" do
    @x = 1
  end

  describe "sub-example" do

    it "should not have instance variable from parent" do
      @x.should == nil
    end

  end

end
