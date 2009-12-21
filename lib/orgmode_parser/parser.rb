##
##  Simple routines for loading / saving an ORG file.
##

module Orgmode

  class Parser

    # All of the lines of the orgmode file
    attr_reader :lines

    # All of the headlines in the org file
    attr_reader :headlines

    # These are any lines before the first headline
    attr_reader :header_lines
    
    def initialize(fname)
      @lines = IO.readlines(fname)
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

    # Saves the loaded orgmode file as a textile file.
    def to_textile
      output = ""
      Line.to_textile(@header_lines)
      @headlines.each do |headline|
        output << headline.to_textile
      end
      output
    end
  end                             # class Parser
end                               # module Orgmode
