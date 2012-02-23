describe "hooks" do

  describe "before advice" do

    before :each do
      @x = 1
    end

    it "has setup" do
      @x.should == 1
    end

  end


  describe "after advice" do

    it "does something" do
      @x = 1
    end

    after :each do
      raise unless @x == 1
    end

  end


  describe "can have more than one before and after" do

    before :each do
      @x = 1
    end

    before :each do
      @y = 2
    end

    it "has setup" do
      @x.should == 1
      @y.should == 2
    end

  end


  describe "advice can be filtered on label" do

    it "is general" do
      @special.should == nil
    end

    it "is special" do
      @special.should == true
    end

    before :each, /special/ do
      @special = true
    end

    after :each, /special/ do
      @special = nil
    end

  end

  describe "advice is inherited by sub-examples" do

    before :each do
      @z = 3
    end

    describe "sub-example" do

      it "has setup" do
        @z.should == 3
      end

    end

  end

end
