module Orgmode

  # Represents a single line of an orgmode file.
  class Line

    # This is the line itself.
    attr_reader :line

    # The indent level of this line. this is important to properly translate
    # nested lists from orgmode to textile.
    # TODO 2009-12-20 bdewey: Handle tabs
    attr_reader :indent

    def initialize(line)
      @line = line
      @indent = 0
      @line =~ /\s*/
      @indent = $&.length unless blank?
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
      @line =~ /^\s*(CLOCK|DEADLINE|START|CLOSED|SCHEDULED):/
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

    UnorderedListRegexp = /^\s*(-|\+|\*)\s*/

    def unordered_list?
      @line =~ UnorderedListRegexp
    end

    def strip_unordered_list_tag
      @line.sub(UnorderedListRegexp, "")
    end

    OrderedListRegexp = /^\s*\d+(\.|\))\s*/

    def ordered_list?
      @line =~ OrderedListRegexp
    end

    def strip_ordered_list_tag
      @line.sub(OrderedListRegexp, "")
    end

    def plain_text?
      not metadata? and not blank? and not plain_list?
    end

    def table_row?
      # for an org-mode table, the first non-whitespace character is a
      # | (pipe).
      @line =~ /^\s*\|/
    end

    def table_separator?
      # an org-mode table separator has the first non-whitespace
      # character as a | (pipe), then consists of nothing else other
      # than pipes, hyphens, and pluses.

      @line =~ /^\s*\|[-\|\+]*\s*$/
    end

    def table?
      table_row? or table_separator?
    end

    BlockRegexp = /^\s*#\+(BEGIN|END)_(\w*)/

    def begin_block?
      @line =~ BlockRegexp && $1 == "BEGIN"
    end

    def end_block?
      @line =~ BlockRegexp && $1 == "END"
    end

    def block_type
      $2 if @line =~ BlockRegexp
    end

    # Determines the paragraph type of the current line.
    def paragraph_type
      return :blank if blank?
      return :ordered_list if ordered_list?
      return :unordered_list if unordered_list?
      return :metadata if metadata?
      return :comment if comment?
      return :table_separator if table_separator?
      return :table_row if table_row?
      return :paragraph
    end

    # Converts an array of lines to textile format.
    def self.to_textile(lines)
      output = ""
      output_buffer = OutputBuffer.new(output)
      lines.each do |line|

        # See if we're carrying paragraph payload, and output
        # it if we're about to switch to some other output type.
        output_buffer.prepare(line)

        case line.paragraph_type
        when :metadata, :table_separator, :blank

          # IGNORE

        when :comment
          
          output_buffer.push_mode(:blockquote) if line.begin_block? and line.block_type == "QUOTE"
          output_buffer.push_mode(:code) if line.begin_block? and line.block_type == "EXAMPLE"
          output_buffer.pop_mode(:blockquote) if line.end_block? and line.block_type == "QUOTE"
          output_buffer.pop_mode(:code) if line.end_block? and line.block_type == "EXAMPLE"

        when :table_row

          output_buffer << line.line.lstrip

        when :ordered_list
            
          output_buffer << line.strip_ordered_list_tag << " "
          
        when :unordered_list
          
          output_buffer << line.strip_unordered_list_tag << " "

        when :paragraph

          if output_buffer.preserve_whitespace? then
            output_buffer << line.line
          else
            output_buffer << line.line.strip << " "
          end
        end
      end
      output_buffer.flush!
      output
    end
  end                           # class Line
end                             # module Orgmode
