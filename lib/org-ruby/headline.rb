require OrgRuby.libpath(*%w[org-ruby line])

module Orgmode

  # Represents a headline in an orgmode file.
  class Headline < Line

    # This is the "level" of the headline
    attr_reader :level

    # This is the headline text -- the part of the headline minus the leading
    # asterisks, the keywords, and the tags.
    attr_reader :headline_text

    # This contains the lines that "belong" to the headline.
    attr_reader :body_lines

    # These are the headline tags
    attr_reader :tags

    # Optional keyword found at the beginning of the headline.
    attr_reader :keyword

    # This is the regex that matches a line
    LineRegexp = /^\*+\s+/

    # This matches the tags on a headline
    TagsRegexp = /\s*:[\w:]*:\s*$/

    # Special keywords allowed at the start of a line.
    Keywords = %w[TODO DONE]

    KeywordsRegexp = Regexp.new("^(#{Keywords.join('|')})\$")

    def initialize(line, parser = nil)
      super(line, parser)
      @body_lines = []
      @tags = []
      if (@line =~ LineRegexp) then
        @level = $&.strip.length
        @headline_text = $'.strip
        if (@headline_text =~ TagsRegexp) then
          @tags = $&.split(/:/)              # split tag text on semicolon
          @tags.delete_at(0)                 # the first item will be empty; discard
          @headline_text.gsub!(TagsRegexp, "") # Removes the tags from the headline
        end
        @keyword = nil
        parse_keywords
      else
        raise "'#{line}' is not a valid headline"
      end
    end

    # Determines if a line is an orgmode "headline":
    # A headline begins with one or more asterisks.
    def self.headline?(line)
      line =~ LineRegexp
    end

    # Converts this headline and its body to textile.
    def to_textile
      output = "h#{@level}. #{@headline_text}\n"
      output << Line.to_textile(@body_lines)
      output
    end

    def to_html(opts = {})
      if opts[:decorate_title]
        decoration = " class=\"title\""
        opts.delete(:decorate_title)
      else
        decoration = ""
      end
      output = "<h#{@level}#{decoration}>"
      if @parser and @parser.export_heading_number? then
        heading_number = @parser.get_next_headline_number(@level)
        output << "<span class=\"heading-number heading-number-#{@level}\">#{heading_number} </span>"
      end
      if @parser and @parser.export_todo? and @keyword then
        output << "<span class=\"todo-keyword #{@keyword}\">#{@keyword} </span>"
      end
      output << "#{escape(@headline_text)}</h#{@level}>\n"
      output << Line.to_html(@body_lines, opts)
      output
    end

    ######################################################################
    private

    # TODO 2009-12-29 This duplicates escape_buffer! in html_output_buffer. DRY.
    def escape(str)
      str = str.gsub(/&/, "&amp;")
      str = str.gsub(/</, "&lt;")
      str = str.gsub(/>/, "&gt;")
      str
    end

    def parse_keywords
      re = @parser.custom_keyword_regexp if @parser
      re ||= KeywordsRegexp
      words = @headline_text.split
      if words.length > 0 && words[0] =~ re then
        @keyword = words[0]
        @headline_text.sub!(Regexp.new("^#{@keyword}\s*"), "")
      end
    end
  end                           # class Headline
end                             # class Orgmode
