module Orgmode

  # Represents a headline in an orgmode file.
  class Headline

    # This is the line
    attr_reader :line

    # This is the "level" of the headline
    attr_reader :level

    def initialize(line)
      @line = line
      if (@line =~ /^\*+/) then
        @level = $&.length
      else
        raise "'#{line}' is not a valid headline"
      end
    end

    # Determines if a line is an orgmode "headline":
    # A headline begins with one or more asterisks.
    def self.is_headline?(line)
      line =~ /^\*+/
    end
  end                           # class Headline
end                             # class Orgmode
