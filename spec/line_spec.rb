require File.join(File.dirname(__FILE__), %w[spec_helper])

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

  it "should recognize table rows" do
    Orgmode::Line.new("| One   | Two   | Three |").table_row?.should be_true
    Orgmode::Line.new("  |-------+-------+-------|\n").table_separator?.should be_true
    Orgmode::Line.new("| Four  | Five  | Six   |").table_row?.should be_true
    Orgmode::Line.new("| Seven | Eight | Nine  |").table_row?.should be_true
  end

  it "should recognize indentation" do
    Orgmode::Line.new("").indent.should eql 0
    Orgmode::Line.new(" a").indent.should eql 1
    Orgmode::Line.new("   ").indent.should eql 0
    Orgmode::Line.new("   \n").indent.should eql 0
    Orgmode::Line.new("   a").indent.should eql 3
  end

  it "should return paragraph type" do
    Orgmode::Line.new("").paragraph_type.should eql :blank
    Orgmode::Line.new("1. foo").paragraph_type.should eql :ordered_list
    Orgmode::Line.new("- [ ] checkbox").paragraph_type.should eql :unordered_list
    Orgmode::Line.new("hello!").paragraph_type.should eql :paragraph
  end
end
