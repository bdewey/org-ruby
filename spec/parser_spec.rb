require 'spec_helper'

describe Orgmode::Parser do
  it "should open ORG files" do
    parser = Orgmode::Parser.load(RememberFile)
  end

  it "should fail on non-existant files" do
    expect { parser = Orgmode::Parser.load("does-not-exist.org") }.to raise_error
  end

  it "should load all of the lines" do
    parser = Orgmode::Parser.load(RememberFile)
    expect(parser.lines.length).to eql(53)
  end

  it "should find all headlines" do
    parser = Orgmode::Parser.load(RememberFile)
    expect(parser.headlines.length).to eql(12)
  end

  it "can find a headline by index" do
    parser = Orgmode::Parser.load(RememberFile)
    line = parser.headlines[1].to_s
    expect(line).to eql("** YAML header in Webby\n")
  end

  it "should determine headline levels" do
    parser = Orgmode::Parser.load(RememberFile)
    expect(parser.headlines[0].level).to eql(1)
    expect(parser.headlines[1].level).to eql(2)
  end

  it "should include the property drawer items from a headline" do
    parser = Orgmode::Parser.load(FreeformExampleFile)
    expect(parser.headlines.first.property_drawer.count).to eql(2)
    expect(parser.headlines.first.property_drawer['DATE']).to eql('2009-11-26')
    expect(parser.headlines.first.property_drawer['SLUG']).to eql('future-ideas')
  end

  it "should put body lines in headlines" do
    parser = Orgmode::Parser.load(RememberFile)
    expect(parser.headlines[0].body_lines.length).to eql(1)
    expect(parser.headlines[1].body_lines.length).to eql(7)
  end

  it "should understand lines before the first headline" do
    parser = Orgmode::Parser.load(FreeformFile)
    expect(parser.header_lines.length).to eql(19)
  end

  it "should load in-buffer settings" do
    parser = Orgmode::Parser.load(FreeformFile)
    expect(parser.in_buffer_settings.length).to eql(12)
    expect(parser.in_buffer_settings["TITLE"]).to eql("Freeform")
    expect(parser.in_buffer_settings["EMAIL"]).to eql("bdewey@gmail.com")
    expect(parser.in_buffer_settings["LANGUAGE"]).to eql("en")
  end

  it "should understand OPTIONS" do
    parser = Orgmode::Parser.load(FreeformFile)
    expect(parser.options.length).to eql(19)
    expect(parser.options["TeX"]).to eql("t")
    expect(parser.options["todo"]).to eql("t")
    expect(parser.options["\\n"]).to eql("nil")
    expect(parser.export_todo?).to be_truthy
    parser.options.delete("todo")
    expect(parser.export_todo?).to be_falsey
  end

  it "should skip in-buffer settings inside EXAMPLE blocks" do
    parser = Orgmode::Parser.load(FreeformExampleFile)
    expect(parser.in_buffer_settings.length).to eql(0)
  end

  it "should return a textile string" do
    parser = Orgmode::Parser.load(FreeformFile)
    expect(parser.to_textile).to be_kind_of(String)
  end

  it "should understand export table option" do
    fname = File.join(File.dirname(__FILE__), %w[html_examples skip-table.org])
    data = IO.read(fname)
    p = Orgmode::Parser.new(data)
    expect(p.export_tables?).to be_falsey
  end

  context "with a table that begins with a separator line" do
    let(:parser) { Orgmode::Parser.new(data) }
    let(:data) { Pathname.new(File.dirname(__FILE__)).join('data', 'tables.org').read }

    it "should parse without errors" do
      expect(parser.headlines.size).to eql(2)
    end
  end

  describe "Custom keyword parser" do
    fname = File.join(File.dirname(__FILE__), %w[html_examples custom-todo.org])
    p = Orgmode::Parser.load(fname)
    valid_keywords = %w[TODO INPROGRESS WAITING DONE CANCELED]
    invalid_keywords = %w[TODOX todo inprogress Waiting done cANCELED NEXT |]
    valid_keywords.each do |kw|
      it "should match custom keyword #{kw}" do
        expect((kw =~ p.custom_keyword_regexp)).to be_truthy
      end
    end
    invalid_keywords.each do |kw|
      it "should not match custom keyword #{kw}" do
        expect((kw =~ p.custom_keyword_regexp)).to be_nil
      end
    end
    it "should not match blank as a custom keyword" do
      expect(("" =~ p.custom_keyword_regexp)).to be_nil
    end
  end

  describe "Custom include/exclude parser" do
    fname = File.join(File.dirname(__FILE__), %w[html_examples export-tags.org])
    p = Orgmode::Parser.load(fname)
    it "should load tags" do
      expect(p.export_exclude_tags.length).to eql(2)
      expect(p.export_select_tags.length).to eql(1)
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
        expect(expected).to be_kind_of(String)
        parser = Orgmode::Parser.new(IO.read(file))
        actual = parser.to_textile
        expect(actual).to be_kind_of(String)
        expect(actual).to eql(expected)
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
        expect(expected).to be_kind_of(String)
        parser = Orgmode::Parser.new(IO.read(file), { :allow_include_files => true })
        actual = parser.to_html
        expect(actual).to be_kind_of(String)
        expect(actual).to eql(expected)
      end

      it "should render #{basename}.org to HTML using Tilt templates" do
        ENV['ORG_RUBY_ENABLE_INCLUDE_FILES'] = 'true'
        expected = IO.read(textile_name)
        template = Tilt.new(file).render
        expect(template).to eql(expected)
        ENV['ORG_RUBY_ENABLE_INCLUDE_FILES'] = ''
      end
    end

    it "should not render #+INCLUDE directive when explicitly indicated" do
      data_directory = File.join(File.dirname(__FILE__), "html_examples")
      expected = File.read(File.join(data_directory, "include-file-disabled.html"))
      org_file = File.join(data_directory, "include-file.org")
      parser = Orgmode::Parser.new(IO.read(org_file), :allow_include_files => false)
      actual = parser.to_html
      expect(actual).to eql(expected)
    end

    it "should render #+INCLUDE when ORG_RUBY_INCLUDE_ROOT is set" do
      data_directory = File.expand_path(File.join(File.dirname(__FILE__), "html_examples"))
      ENV['ORG_RUBY_INCLUDE_ROOT'] = data_directory
      expected = File.read(File.join(data_directory, "include-file.html"))
      org_file = File.join(data_directory, "include-file.org")
      parser = Orgmode::Parser.new(IO.read(org_file))
      actual = parser.to_html
      expect(actual).to eql(expected)
      ENV['ORG_RUBY_INCLUDE_ROOT'] = nil
    end
  end

  describe "Export to HTML test cases with code syntax highlight" do
    code_syntax_examples_directory = File.join(File.dirname(__FILE__), "html_code_syntax_highlight_examples")

    # Include the code syntax highlight support tests
    if defined? CodeRay
      # Use CodeRay for syntax highlight (pure Ruby solution)
      org_files = File.expand_path(File.join(code_syntax_examples_directory, "*-coderay.org"))
    elsif defined? Pygments
      # Use pygments (so that it works with Jekyll, Gollum and possibly Github)
      org_files = File.expand_path(File.join(code_syntax_examples_directory, "*-pygments.org"))
    else
      # Do not use syntax coloring for source code blocks
      org_files = File.expand_path(File.join(code_syntax_examples_directory, "*-no-color.org"))
    end
    files = Dir.glob(org_files)

    files.each do |file|
      basename = File.basename(file, ".org")
      org_filename = File.join(code_syntax_examples_directory, basename + ".html")
      org_filename = File.expand_path(org_filename)

      it "should convert #{basename}.org to HTML" do
        expected = IO.read(org_filename)
        expect(expected).to be_kind_of(String)
        parser = Orgmode::Parser.new(IO.read(file), :allow_include_files => true)
        actual = parser.to_html
        expect(actual).to be_kind_of(String)
        expect(actual).to eql(expected)
      end

      it "should render #{basename}.org to HTML using Tilt templates" do
        ENV['ORG_RUBY_ENABLE_INCLUDE_FILES'] = 'true'
        expected = IO.read(org_filename)
        template = Tilt.new(file).render
        expect(template).to eql(expected)
        ENV['ORG_RUBY_ENABLE_INCLUDE_FILES'] = ''
      end
    end
  end

  describe "Export to Markdown test cases" do
    data_directory = File.join(File.dirname(__FILE__), "markdown_examples")
    org_files = File.expand_path(File.join(data_directory, "*.org" ))
    files = Dir.glob(org_files)
    files.each do |file|
      basename = File.basename(file, ".org")
      markdown_name = File.join(data_directory, basename + ".md")
      markdown_name = File.expand_path(markdown_name)

      it "should convert #{basename}.org to Markdown" do
        expected = IO.read(markdown_name)
        expect(expected).to be_kind_of(String)
        parser = Orgmode::Parser.new(IO.read(file), :allow_include_files => false)
        actual = parser.to_markdown
        expect(actual).to be_kind_of(String)
        expect(actual).to eql(expected)
      end
    end
  end
end
