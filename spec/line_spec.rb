require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Orgmode::Line do

  it "should tell comments" do
    comments = ["# hello", "#hello" ]
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

  [": inline", " :inline", "\t\t:\tinline"].each do |inline_example|
    it "should recognize this inline example: #{inline_example}" do
      Orgmode::Line.new(inline_example).inline_example?.should be_true
    end
  end
    

  it "should recognize plain lists" do
    list_formats = ["-",
                    "+",
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
    Orgmode::Line.new("").indent.should eql(0)
    Orgmode::Line.new(" a").indent.should eql(1)
    Orgmode::Line.new("   ").indent.should eql(0)
    Orgmode::Line.new("   \n").indent.should eql(0)
    Orgmode::Line.new("   a").indent.should eql(3)
  end

  it "should return paragraph type" do
    Orgmode::Line.new("").paragraph_type.should eql(:blank)
    Orgmode::Line.new("1. foo").paragraph_type.should eql(:ordered_list)
    Orgmode::Line.new("- [ ] checkbox").paragraph_type.should eql(:unordered_list)
    Orgmode::Line.new("hello!").paragraph_type.should eql(:paragraph)
  end

  it "should recognize BEGIN and END comments" do
    begin_examples = {
      "#+BEGIN_SRC emacs-lisp -n -r\n" => "SRC",
      "#+BEGIN_EXAMPLE" => "EXAMPLE",
      "\t#+BEGIN_QUOTE  " => "QUOTE"
    }

    end_examples = {
      "#+END_SRC" => "SRC",
      "#+END_EXAMPLE" => "EXAMPLE",
      "\t#+END_QUOTE  " => "QUOTE"
    }

    begin_examples.each_key do |str|
      line = Orgmode::Line.new str
      line.begin_block?.should be_true
      line.block_type.should eql(begin_examples[str])
    end

    end_examples.each_key do |str|
      line = Orgmode::Line.new str
      line.end_block?.should be_true
      line.block_type.should eql(end_examples[str])
    end
  end

  it "should accept assigned types" do
    cases = {
      "# this looks like a comment" => :comment,
      "  1. This looks like an ordered list" => :ordered_list,
      "       - this looks like an # unordered list" => :unordered_list,
      " | one | two | table! |  \n" => :table_row,
      "\n" => :blank,
      " |-----+-----+--------|  \n" => :table_separator
    }

    cases.each_pair do |key, value|
      l = Orgmode::Line.new key
      l.paragraph_type.should eql(value)
      l.assigned_paragraph_type = :paragraph
      l.paragraph_type.should eql(:paragraph) 
      l.assigned_paragraph_type = nil
      l.paragraph_type.should eql(value)
    end
  end

  it "should parse in-buffer settings" do
    cases = {
      "#+ARCHIVE: %s_done" => { :key => "ARCHIVE", :value => "%s_done" },
      "#+CATEGORY: foo" => { :key => "CATEGORY", :value => "foo"},
      "#+BEGIN_EXAMPLE:" => { :key => "BEGIN_EXAMPLE", :value => "" },
      "#+A:" => { :key => "A", :value => "" } # Boundary: Smallest keyword is one letter
    }
    cases.each_pair do |key, value|
      l = Orgmode::Line.new key
      l.in_buffer_setting?.should be_true
      called = nil
      l.in_buffer_setting? do |k, v|
        k.should eql(value[:key])
        v.should eql(value[:value])
        called = true
      end
      called.should be_true
    end
  end

  it "should reject ill-formed settings" do
    cases = [
             "##+ARCHIVE: blah",
             "#CATEGORY: foo",
             "",
             "\n",
             "   #+BEGIN_EXAMPLE:\n"
            ]

    cases.each do |c|
      l = Orgmode::Line.new c
      l.in_buffer_setting?.should be_nil
    end
  end
end
