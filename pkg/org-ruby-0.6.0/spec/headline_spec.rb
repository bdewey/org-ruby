
require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Orgmode::Headline do

  it "should recognize headlines that start with asterisks" do
    Orgmode::Headline.headline?("*** test\n").should_not be_nil
  end

  it "should reject headlines without headlines at the start" do
    Orgmode::Headline.headline?("  nope!").should be_nil
    Orgmode::Headline.headline?("  tricked you!!!***").should be_nil
  end

  it "should reject improper initialization" do
    lambda { Orgmode::Headline.new " tricked**" }.should raise_error
  end

  it "should properly determine headline level" do
    samples = ["* one", "** two", "*** three", "**** four"]
    expected = 1
    samples.each do |sample|
      h = Orgmode::Headline.new sample
      h.level.should eql(expected)
      expected += 1
    end
  end

  it "should properly determine headline level with offset" do
    h = Orgmode::Headline.new("* one", nil, 1)
    h.level.should eql(2)
  end

  it "should find simple headline text" do
    h = Orgmode::Headline.new "*** sample"
    h.headline_text.should eql("sample")
  end

  it "should understand tags" do
    h = Orgmode::Headline.new "*** sample :tag:tag2:\n"
    h.headline_text.should eql("sample")
    h.should have(2).tags
    h.tags[0].should eql("tag")
    h.tags[1].should eql("tag2")
  end

  it "should understand a single tag" do
    h = Orgmode::Headline.new "*** sample :tag:\n"
    h.headline_text.should eql("sample")
    h.should have(1).tags
    h.tags[0].should eql("tag")
  end

  it "should understand keywords" do
    h = Orgmode::Headline.new "*** TODO Feed cat  :home:"
    h.headline_text.should eql("Feed cat")
    h.keyword.should eql("TODO")
  end
end

