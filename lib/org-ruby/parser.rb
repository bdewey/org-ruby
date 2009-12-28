require 'rubygems'
require 'rubypants'

module Orgmode

  ##
  ##  Simple routines for loading / saving an ORG file.
  ##

  class Parser

    # All of the lines of the orgmode file
    attr_reader :lines

    # All of the headlines in the org file
    attr_reader :headlines

    # These are any lines before the first headline
    attr_reader :header_lines
    
    # I can construct a parser object either with an array of lines
    # or with a single string that I will split along \n boundaries.
    def initialize(lines)
      if lines.is_a? Array then
        @lines = lines
      elsif lines.is_a? String then
        @lines = lines.split("\n")
      else
        raise "Unsupported type for +lines+: #{lines.class}"
      end
        
      @headlines = Array.new
      @current_headline = nil
      @header_lines = []
      @lines.each do |line|
        if (Headline.headline? line) then
          @current_headline = Headline.new line
          @headlines << @current_headline
        else
          line = Line.new line
          if (@current_headline) then
            @current_headline.body_lines << line
          else
            @header_lines << line
          end
        end
      end
    end                           # initialize

    # Creates a new parser from the data in a given file
    def self.load(fname)
      lines = IO.readlines(fname)
      return self.new(lines)
    end

    # Saves the loaded orgmode file as a textile file.
    def to_textile
      output = ""
      output << Line.to_textile(@header_lines)
      @headlines.each do |headline|
        output << headline.to_textile
      end
      output
    end

    # Converts the loaded org-mode file to HTML.
    def to_html
      output = ""
      output << Line.to_html(@header_lines)
      @headlines.each do |headline|
        output << headline.to_html
      end
      rp = RubyPants.new(output)
      rp.to_html
    end
  end                             # class Parser
end                               # module Orgmode
