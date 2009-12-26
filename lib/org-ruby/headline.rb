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
    LineRegexp = /^\*+\s*/

    # This matches the tags on a headline
    TagsRegexp = /\s*:[\w:]*:\s*$/

    # Special keywords allowed at the start of a line.
    Keywords = %w[TODO DONE]

    KeywordsRegexp = Regexp.new("\\s*(#{Keywords.join('|')})\\s*")

    def initialize(line)
      super(line)
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
        if (@headline_text =~ KeywordsRegexp) then
          @headline_text = $'
          @keyword = $1
        end
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

    def to_html
      output = "<h#{@level}>#{@headline_text}</h#{@level}>\n"
      output << Line.to_html(@body_lines)
      output
    end
  end                           # class Headline
end                             # class Orgmode
