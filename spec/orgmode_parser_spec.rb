
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
end
