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
      @lines.each do |line|
        if (Headline.is_headline? line) then
          @headlines << (Headline.new line)
        end
      end
    end                           # self.new
  end                             # class OrgmodeParser
end                               # module OrgmodeParser
