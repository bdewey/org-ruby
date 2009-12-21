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
    def is_comment?
      @line =~ /^\s*#/
    end

    # Tests if a line contains metadata instead of actual content.
    def is_metadata?
      @line =~ /^\s*(CLOCK|DEADLINE|START|CLOSED):/
    end

    def is_nonprinting?
      is_comment? || is_metadata?
    end
  end                           # class Line
end                             # module Orgmode
