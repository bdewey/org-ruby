##
##  Simple routines for loading / saving an ORG file.
##

module Orgmode

  class Parser

    # All of the lines of the orgmode file
    attr_reader :lines

    # All of the headlines in the org file
    attr_reader :headlines
    
    def initialize(fname)
      @lines = IO.readlines(fname)
      @headlines = Array.new
      @current_headline = nil
      @lines.each do |line|
        if (Headline.is_headline? line) then
          @current_headline = Headline.new line
          @headlines << @current_headline
        else
          @current_headline.body_lines << line if @current_headline
        end
      end
    end                           # self.new
  end                             # class OrgmodeParser
end                               # module OrgmodeParser
