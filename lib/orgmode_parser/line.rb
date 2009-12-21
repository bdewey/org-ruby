module Orgmode

  # Represents a single line of an orgmode file.
  class Line

    # This is the line itself.
    attr_reader :line

    def initialize(line)
      @line = line
    end

    def to_s
      return @line
    end

    # Tests if a line is a comment.
    def comment?
      @line =~ /^\s*#/
    end

    # Tests if a line contains metadata instead of actual content.
    def metadata?
      @line =~ /^\s*(CLOCK|DEADLINE|START|CLOSED):/
    end

    def nonprinting?
      comment? || metadata?
    end

    def blank?
      @line =~ /^\s*$/
    end

    def plain_list?
      ordered_list? or unordered_list?
    end

    def unordered_list?
      @line =~ /^\s*(-|\+|\*)/
    end

    def ordered_list?
      @line =~ /^\s*\d+(\.|\))/
    end

    def plain_text?
      not metadata? and not blank? and not plain_list?
    end

    # Converts an array of lines to textile format.
    # One of the tricky bits is eliminating extra linebreaks
    def self.to_textile(lines)
      output = ""
      0.upto lines.length-1 do |i|
        line = lines[i]
        data = line.line
        if line.plain_text? then
          data.lstrip!
          if (i < lines.length - 1 && lines[i+1].plain_text?) then
            data.rstrip!
            data << " " 
          end
        end
        output << data unless line.nonprinting?
      end
      output
    end
    
  end                           # class Line
end                             # module Orgmode
