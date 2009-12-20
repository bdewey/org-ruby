module Orgmode

  # Represents a headline in an orgmode file.
  class Headline

    # This is the line
    attr_reader :line

    # This is the "level" of the headline
    attr_reader :level

    # This is the headline text -- the part of the headline minus the leading
    # asterisks, the keywords, and the tags.
    attr_reader :headline_text

    # This contains the lines that "belong" to the headline.
    attr_reader :body_lines

    # These are the headline tags
    attr_reader :tags

    # This is the regex that matches a line
    LineRegex = /^\*+\s*/

    # This matches the tags on a headline
    TagsRegex = /\s*:[\w:]*:\s*$/

    def initialize(line)
      @line = line
      @body_lines = []
      @tags = []
      if (@line =~ LineRegex) then
        @level = $&.strip.length
        @headline_text = $'.strip
        if (@headline_text =~ TagsRegex) then
          @tags = $&.split(/:/)              # split tag text on semicolon
          @tags.delete_at(0)                 # the first item will be empty; discard
          @headline_text.gsub!(TagsRegex, "") # Removes the tags from the headline
        end
      else
        raise "'#{line}' is not a valid headline"
      end
    end

    # Determines if a line is an orgmode "headline":
    # A headline begins with one or more asterisks.
    def self.is_headline?(line)
      line =~ LineRegex
    end

    # Converts this headline and its body to textile.
    def to_textile
      output = "h#{@level}. #{@headline_text}\n"
      @body_lines.each do |line|
        output << line
      end
      output
    end
  end                           # class Headline
end                             # class Orgmode
