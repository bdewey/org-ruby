require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Orgmode::TextileOutputBuffer do
  it "should substitute / with _" do
    Orgmode::TextileOutputBuffer.new("").inline_formatting("/italic/").should eql("_italic_")
  end

  it "should convert simple links" do
    Orgmode::TextileOutputBuffer.new("").inline_formatting("[[http://www.google.com]]").should \
      eql("\"http://www.google.com\":http://www.google.com")
  end

  it "should convert links with text" do
    Orgmode::TextileOutputBuffer.new("").inline_formatting("[[http://www.google.com][Google]]").should \
      eql("\"Google\":http://www.google.com")
  end

  it "should convert spaces in urls" do
    Orgmode::TextileOutputBuffer.new("").inline_formatting("[[my url]]").should eql("\"my url\":my%20url")
  end
end
