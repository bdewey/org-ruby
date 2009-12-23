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

    UnorderedListRegexp = /^\s*(-|\+|\*)/

    def unordered_list?
      @line =~ UnorderedListRegexp
    end

    def strip_unordered_list_tag
      @line.sub(UnorderedListRegexp, "")
    end

    OrderedListRegexp = /^\s*\d+(\.|\))/

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

    # Tests if the current line should be accumulated in the current
    # output buffer.  (Extraneous line breaks in the orgmode buffer
    # are removed by accumulating lines in the output buffer without
    # line breaks.)
    def self.should_accumulate_output?(line)
      
      # Currently only "paragraphs" get accumulated with previous output.
      return false unless line.paragraph_type == :paragraph
      if ((@previous_output_type == :ordered_list) or
          (@previous_output_type == :unordered_list)) then

        # If the previous output type was a list item, then we only put a paragraph in it
        # if its indent level is greater than the list indent level.

        return false unless line.indent > @list_indent_stack.last
      end
      true
    end

    # Converts an array of lines to textile format.
    def self.to_textile(lines)
      @output = ""
      @previous_output_type = :start
      @output_buffer = ""
      @list_indent_stack = []
      @paragraph_modifier = nil
      0.upto lines.length-1 do |i|
        line = lines[i]
        data = line.line

        # See if we're carrying paragraph payload, and output
        # it if we're about to switch to some other output type.
        if not should_accumulate_output?(line) then
          flush_output_buffer
        end
        @list_indent_stack = [] unless (line.paragraph_type == :ordered_list or line.paragraph_type == :unordered_list)
        case line.paragraph_type
        when :metadata, :table_separator

          # IGNORE

        when :comment
          
          @paragraph_modifier = "bq. " if line.begin_block? and line.block_type == "QUOTE"
          @paragraph_modifier = nil if line.end_block?

        when :table_row

          @output << line.line.lstrip.textile_substitution << "\n"

        when :blank

          # Don't output multiple blank lines.
          @output << "\n" unless @previous_output_type == :blank

          

        when :ordered_list

          while (not @list_indent_stack.empty? \
                 and (@list_indent_stack.last > line.indent)) 
            @list_indent_stack.pop
          end
          if (@list_indent_stack.empty? \
              or @list_indent_stack.last < line.indent)
            @list_indent_stack.push(line.indent)
          end
            
          @output_buffer << "#" * @list_indent_stack.length <<
            line.strip_ordered_list_tag << " "
          
        when :unordered_list
          
          while (not @list_indent_stack.empty? \
                 and (@list_indent_stack.last > line.indent)) 
            @list_indent_stack.pop
          end
          if (@list_indent_stack.empty? or @list_indent_stack.last < line.indent)
            @list_indent_stack.push(line.indent) 
          end
          @output_buffer << "*" * @list_indent_stack.length <<
            line.strip_unordered_list_tag << " "

        when :paragraph
          
          # Strip leading & trailing whitespace for paragraphs, and
          # don't output right away. Build up the data in
          # @output_buffer and output only when the output type
          # changes.
          @output_buffer << line.line.strip << " "
        end
        @previous_output_type = line.paragraph_type
      end
      flush_output_buffer
      @output
    end

    ######################################################################
    private

    def self.flush_output_buffer
      if (@output_buffer.length > 0) then
        @output << @paragraph_modifier if @paragraph_modifier
        @output << @output_buffer.textile_substitution << "\n"
        @output_buffer = ""
      end
    end
    
  end                           # class Line
end                             # module Orgmode
