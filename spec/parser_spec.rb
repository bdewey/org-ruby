
require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Orgmode::Parser do
  it "should open ORG files" do
    parser = Orgmode::Parser.load(RememberFile)
  end

  it "should fail on non-existant files" do
    lambda { parser = Orgmode::Parser.load("does-not-exist.org") }.should raise_error
  end

  it "should load all of the lines" do
    parser = Orgmode::Parser.load(RememberFile)
    parser.lines.length.should eql(53)
  end

  it "should find all headlines" do
    parser = Orgmode::Parser.load(RememberFile)
    parser.should have(12).headlines
  end

  it "can find a headline by index" do
    parser = Orgmode::Parser.load(RememberFile)
    parser.headlines[1].line.should eql("** YAML header in Webby\n")
  end

  it "should determine headline levels" do
    parser = Orgmode::Parser.load(RememberFile)
    parser.headlines[0].level.should eql(1)
    parser.headlines[1].level.should eql(2)
  end

  it "should put body lines in headlines" do
    parser = Orgmode::Parser.load(RememberFile)
    parser.headlines[0].should have(1).body_lines
    parser.headlines[1].should have(7).body_lines
  end

  it "should understand lines before the first headline" do
    parser = Orgmode::Parser.load(FreeformFile)
    parser.should have(19).header_lines
  end

  it "should load in-buffer settings" do
    parser = Orgmode::Parser.load(FreeformFile)
    parser.should have(12).in_buffer_settings
    parser.in_buffer_settings["TITLE"].should eql("Freeform")
    parser.in_buffer_settings["EMAIL"].should eql("bdewey@gmail.com")
    parser.in_buffer_settings["LANGUAGE"].should eql("en")
  end

  it "should understand OPTIONS" do
    parser = Orgmode::Parser.load(FreeformFile)
    parser.should have(19).options
    parser.options["TeX"].should eql("t")
    parser.options["todo"].should eql("t")
    parser.options["\\n"].should eql("nil")
    parser.export_todo?.should be_true
    parser.options.delete("todo")
    parser.export_todo?.should be_false
  end

  it "should skip in-buffer settings inside EXAMPLE blocks" do
    parser = Orgmode::Parser.load(FreeformExampleFile)
    parser.should have(0).in_buffer_settings
  end

  it "should return a textile string" do
    parser = Orgmode::Parser.load(FreeformFile)
    parser.to_textile.should be_kind_of(String)
  end

  it "should understand export table option" do
    fname = File.join(File.dirname(__FILE__), %w[html_examples skip-table.org])
    data = IO.read(fname)
    p = Orgmode::Parser.new(data)
    p.export_tables?.should be_false
  end

  describe "Custom keyword parser" do
    fname = File.join(File.dirname(__FILE__), %w[html_examples custom-todo.org])
    p = Orgmode::Parser.load(fname)
    valid_keywords = %w[TODO INPROGRESS WAITING DONE CANCELED]
    invalid_keywords = %w[TODOX todo inprogress Waiting done cANCELED NEXT |]
    valid_keywords.each do |kw|
      it "should match custom keyword #{kw}" do
        (kw =~ p.custom_keyword_regexp).should be_true
      end
    end
    invalid_keywords.each do |kw|
      it "should not match custom keyword #{kw}" do
        (kw =~ p.custom_keyword_regexp).should be_nil
      end
    end
    it "should not match blank as a custom keyword" do
      ("" =~ p.custom_keyword_regexp).should be_nil
    end
  end

  describe "Custom include/exclude parser" do
    fname = File.join(File.dirname(__FILE__), %w[html_examples export-tags.org])
    p = Orgmode::Parser.load(fname)
    it "should load tags" do
      p.should have(2).export_exclude_tags
      p.should have(1).export_select_tags
    end
  end

  describe "Export to Textile test cases" do
    data_directory = File.join(File.dirname(__FILE__), "textile_examples")
    org_files = File.expand_path(File.join(data_directory, "*.org" ))
    files = Dir.glob(org_files)
    files.each do |file|
      basename = File.basename(file, ".org")
      textile_name = File.join(data_directory, basename + ".textile")
      textile_name = File.expand_path(textile_name)

      it "should convert #{basename}.org to Textile" do
        expected = IO.read(textile_name)
        expected.should be_kind_of(String)
        parser = Orgmode::Parser.new(IO.read(file))
        actual = parser.to_textile
        actual.should be_kind_of(String)
        actual.should == expected
      end
    end
  end

  describe "Export to HTML test cases" do
    # Dynamic generation of examples from each *.org file in html_examples.
    # Each of these files is convertable to HTML.
    data_directory = File.join(File.dirname(__FILE__), "html_examples")
    org_files = File.expand_path(File.join(data_directory, "*.org" ))
    files = Dir.glob(org_files)
    files.each do |file|
      basename = File.basename(file, ".org")
      textile_name = File.join(data_directory, basename + ".html")
      textile_name = File.expand_path(textile_name)

      it "should convert #{basename}.org to HTML" do
        expected = IO.read(textile_name)
        expected.should be_kind_of(String)
        parser = Orgmode::Parser.new(IO.read(file))
        actual = parser.to_html
        actual.should be_kind_of(String)
        actual.should == expected
      end
    end
  end
end

