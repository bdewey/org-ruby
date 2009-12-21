
require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Orgmode::Parser do
  it "should open ORG files" do
    parser = Orgmode::Parser.load("data/remember.org")
  end

  it "should fail on non-existant files" do
    lambda { parser = Orgmode::Parser.load("does-not-exist.org") }.should raise_error
  end

  it "should load all of the lines" do
    parser = Orgmode::Parser.load("data/remember.org")
    parser.lines.length.should == 53
  end

  it "should find all headlines" do
    parser = Orgmode::Parser.load("data/remember.org")
    parser.should have(12).headlines
  end

  it "can find a headline by index" do
    parser = Orgmode::Parser.load("data/remember.org")
    parser.headlines[1].line.should == "** YAML header in Webby\n"
  end

  it "should determine headline levels" do
    parser = Orgmode::Parser.load("data/remember.org")
    parser.headlines[0].level.should == 1
    parser.headlines[1].level.should == 2
  end

  it "should put body lines in headlines" do
    parser = Orgmode::Parser.load("data/remember.org")
    parser.headlines[0].should have(0).body_lines
    parser.headlines[1].should have(6).body_lines
  end

  it "should understand lines before the first headline" do
    parser = Orgmode::Parser.load("data/freeform.org")
    parser.should have(19).header_lines
  end

  it "should return a textile string" do
    parser = Orgmode::Parser.load("data/freeform.org")
    parser.to_textile.should be_kind_of(String)
  end
end

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

describe Orgmode::Line do

  it "should tell comments" do
    comments = ["# hello", "#hello", "   #hello", "\t#hello\n"]
    comments.each do |c|
      line = Orgmode::Line.new c
      line.comment?.should be_true
    end

    not_comments = ["", "\n", "hello\n", "  foo ### bar\n"]
    not_comments.each do |c|
      line = Orgmode::Line.new c
      line.comment?.should_not be_true
    end
  end

  it "should tell blank lines" do
    blank = ["", " ", "\t", "\n", "  \t\t\n\n"]
    blank.each do |b|
      line = Orgmode::Line.new b
      line.blank?.should be_true
    end
  end

  it "should recognize plain lists" do
    list_formats = ["-",
                    "+",
                    "  *",
                    "  -",
                    "  +",
                    " 1.",
                    " 2)"]
    list_formats.each do |list|
      line = Orgmode::Line.new list
      line.plain_list?.should be_true
    end
  end

  it "should recognize indentation" do
    Orgmode::Line.new("").indent.should == 0
    Orgmode::Line.new(" a").indent.should == 1
    Orgmode::Line.new("   ").indent.should == 0
    Orgmode::Line.new("   \n").indent.should == 0
    Orgmode::Line.new("   a").indent.should == 3
  end

  it "should return paragraph type" do
    Orgmode::Line.new("").paragraph_type.should == :blank
    Orgmode::Line.new("1. foo").paragraph_type.should == :ordered_list
    Orgmode::Line.new("- [ ] checkbox").paragraph_type.should == :unordered_list
    Orgmode::Line.new("hello!").paragraph_type.should == :paragraph
  end

  it "can convert an array of lines to textile"
end
