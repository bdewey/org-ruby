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

    # Determines the paragraph type of the current line.
    def paragraph_type
      return :blank if blank?
      return :ordered_list if ordered_list?
      return :unordered_list if unordered_list?
      return :metadata if metadata?
      return :comment if comment?
      return :paragraph
    end

    # Converts an array of lines to textile format.
    def self.to_textile(lines)
      output = ""
      current_output_type = :start
      current_paragraph = ""
      list_indent_stack = []
      0.upto lines.length-1 do |i|
        line = lines[i]
        data = line.line

        # See if we're carrying paragraph payload, and output
        # it if we're about to switch to some other output type.
        if ((current_paragraph.length > 0) and
            (line.paragraph_type != :paragraph)) then
          output << current_paragraph.textile_substitution << "\n"
          current_paragraph = ""
        end
        list_indent_stack = [] unless (line.paragraph_type == :ordered_list or line.paragraph_type == :unordered_list)
        case line.paragraph_type
          when :metadata, :comment

          # IGNORE

          when :blank

          # Don't output multiple blank lines.
          output << "\n" unless current_output_type == :blank

          # TODO 2009-12-20 bdewey: Handle nesting of lists
          when :ordered_list

          while (not list_indent_stack.empty? and (list_indent_stack.last > line.indent)) do
            list_indent_stack.pop
          end
          list_indent_stack.push(line.indent) if list_indent_stack.empty? or list_indent_stack.last < line.indent
          output << "#" * list_indent_stack.length << line.strip_ordered_list_tag.textile_substitution << "\n"

          when :unordered_list

          while (not list_indent_stack.empty? and (list_indent_stack.last > line.indent)) do
            list_indent_stack.pop
          end
          list_indent_stack.push(line.indent) if list_indent_stack.empty? or list_indent_stack.last < line.indent
          output << "*" * list_indent_stack.length << line.strip_unordered_list_tag.textile_substitution << "\n"

          when :paragraph
          
          # Strip leading & trailing whitespace for paragraphs, and don't output
          # right away. Build up the data in current_paragraph and output only
          # when the output type changes.
          current_paragraph << line.line.strip << " "
        end
        current_output_type = line.paragraph_type
      end
      # See if we're carrying paragraph payload, and output
      # it if we're about to switch to some other output type.
      if (current_paragraph.length > 0) then
        output << current_paragraph.textile_substitution << "\n"
        current_paragraph = ""
      end
      output
    end
    
  end                           # class Line
end                             # module Orgmode
