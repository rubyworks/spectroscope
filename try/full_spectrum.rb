describe "Show them how to Beat It" do

  # will fail
  it "shows them how to funky" do
    "funky".assert != "funky"
  end

  # will pass
  it "shows them what's right" do
    "right".assert == "right"
  end

  # will error
  it "shows no one wants to be defeated" do
    raise SyntaxError
  end

  # pending
  it "shows you better do what you can" do
    raise NotImplementedError
  end

  # omit
  it "shows you should just beat it" do
    e = NotImplementedError.new
    e.set_assertion(true)
    raise e
  end

end
