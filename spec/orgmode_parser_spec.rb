
require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Orgmode::Parser do
  it "should open ORG files" do
    parser = Orgmode::Parser.new("data/remember.org")
  end

  it "should fail on non-existant files" do
    lambda { parser = Orgmode::Parser.new("does-not-exist.org") }.should raise_error
  end

  it "should load all of the lines" do
    parser = Orgmode::Parser.new("data/remember.org")
    parser.lines.length.should == 53
  end

  it "should find all headlines" do
    parser = Orgmode::Parser.new("data/remember.org")
    parser.should have(12).headlines
  end

  it "can find a headline by index" do
    parser = Orgmode::Parser.new("data/remember.org")
    parser.headlines[1].line.should == "** YAML header in Webby\n"
  end

  it "should determine headline levels" do
    parser = Orgmode::Parser.new("data/remember.org")
    parser.headlines[0].level.should == 1
    parser.headlines[1].level.should == 2
  end

  it "should put body lines in headlines" do
    parser = Orgmode::Parser.new("data/remember.org")
    parser.headlines[0].should have(0).body_lines
    parser.headlines[1].should have(6).body_lines
  end

  it "should understand lines before the first headline" do
    parser = Orgmode::Parser.new("data/freeform.org")
    parser.should have(19).header_lines
  end

  it "should tell comments" do
    Orgmode::Parser.is_comment?("# hello").should_not be_nil
    Orgmode::Parser.is_comment?(" \t# Leading whitespace").should_not be_nil
    Orgmode::Parser.is_comment?("Not a comment").should be_nil
  end

  it "should return a textile string" do
    parser = Orgmode::Parser.new("data/freeform.org")
    parser.to_textile.should be_kind_of(String)
  end
end

describe Orgmode::Headline do

  it "should recognize headlines that start with asterisks" do
    Orgmode::Headline.is_headline?("*** test\n").should_not be_nil
  end

  it "should reject headlines without headlines at the start" do
    Orgmode::Headline.is_headline?("  nope!").should be_nil
    Orgmode::Headline.is_headline?("  tricked you!!!***").should be_nil
  end

  it "should reject improper initialization" do
    lambda { Orgmode::Headline.new " tricked**" }.should raise_error
  end

  it "should properly determine headline level" do
    samples = %w[*one **two ***three ****four]
    expected = 1
    samples.each do |sample|
      h = Orgmode::Headline.new sample
      h.level.should == expected
      expected += 1
    end
  end

  it "should find simple headline text" do
    h = Orgmode::Headline.new "*** sample"
    h.headline_text.should == "sample"
  end

  it "should understand tags" do
    h = Orgmode::Headline.new "*** sample :tag:tag2:\n"
    h.headline_text.should == "sample"
    h.should have(2).tags
    h.tags[0].should == "tag"
    h.tags[1].should == "tag2"
  end

  it "should understand a single tag" do
    h = Orgmode::Headline.new "*** sample :tag:\n"
    h.headline_text.should == "sample"
    h.should have(1).tags
    h.tags[0].should == "tag"
  end
end
