describe String do
  it "should substitute / with _" do
    "/italic/".textile_substitution.should eql("_italic_")
  end

  it "should convert simple links" do
    "[[http://www.google.com]]".textile_substitution.should eql("\"http://www.google.com\":http://www.google.com")
  end

  it "should convert links with text" do
    "[[http://www.google.com][Google]]".textile_substitution.should eql("\"Google\":http://www.google.com")
  end

  it "should convert spaces in urls" do
    "[[my url]]".textile_substitution.should eql("\"my url\":my%20url")
  end
end
