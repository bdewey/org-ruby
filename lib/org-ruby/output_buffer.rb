require 'logger'

module Orgmode

  # The OutputBuffer is used to accumulate multiple lines of orgmode
  # text, and then emit them to the output all in one go. The class
  # will do the final textile substitution for inline formatting and
  # add a newline character prior emitting the output.
  class OutputBuffer

    # This is the accumulation buffer. It's a holding pen so
    # consecutive lines of the right type can get stuck together
    # without intervening newlines.
    attr_reader :buffer

    # These are the Line objects that are currently in the accumulation
    # buffer.
    attr_reader :buffered_lines

    # This is the output mode of the accumulation buffer.
    attr_reader :buffer_mode

    # This is the overall output buffer
    attr_reader :output

    # This is the current type of output being accumulated.
    attr_accessor :output_type

    # This stack is used to do proper outline numbering of headlines.
    attr_accessor :headline_number_stack

    # Creates a new OutputBuffer object that is bound to an output object.
    # The output will get flushed to =output=.
    def initialize(output)
      @output = output
      @buffer = ""
      @buffered_lines = []
      @buffer_mode = nil
      @output_type = :start
      @list_indent_stack = []
      @paragraph_modifier = nil
      @cancel_modifier = false
      @mode_stack = []
      @headline_number_stack = []

      @logger = Logger.new(STDERR)
      if ENV['DEBUG'] or $DEBUG
        @logger.level = Logger::DEBUG
      else
        @logger.level = Logger::WARN
      end

      @re_help = RegexpHelper.new
    end

    HeadingModes = [:heading1, :heading2, :heading3, :heading4, :heading5, :heading6]

    def current_mode
      @mode_stack.last
    end

    def current_mode_list?
      (current_mode == :ordered_list) or (current_mode == :unordered_list)
    end

    def push_mode(mode)
      @mode_stack.push(mode)
    end

    def pop_mode(mode = nil)
      m = @mode_stack.pop
      @logger.warn "Modes don't match. Expected to pop #{mode}, but popped #{m}" if mode && mode != m
      m
    end

    # Prepares the output buffer to receive content from a line.
    # As a side effect, this may flush the current accumulated text.
    def prepare(line)
      @logger.debug "Looking at #{line.paragraph_type}(#{current_mode}) : #{line.to_s}"
      if line.begin_block? and line.code_block?
        flush!
        # We try to get the lang from #+BEGIN_SRC blocks
        @block_lang = line.block_lang
      elsif current_mode == :example and line.end_block?
        flush!
      elsif not should_accumulate_output?(line)
        flush!
        maintain_mode_stack(line)
      end
      @output_type = line.paragraph_type
      push_mode(:inline_example, line) if line.inline_example? and current_mode != :inline_example and not line.property_drawer?
      pop_mode(:inline_example) if current_mode == :inline_example and !line.inline_example?
      push_mode(:property_drawer, line) if line.property_drawer? and current_mode != :property_drawer
      pop_mode(:property_drawer) if current_mode == :property_drawer and line.property_drawer_end_block?
      push_mode(:table, line) if enter_table?
      pop_mode(:table) if exit_table?
      @buffered_lines.push(line)
    end

    # Flushes everything currently in the accumulation buffer into the
    # output buffer. Derived classes must override this to actually move
    # content into the output buffer with the appropriate markup. This
    # method just does common bookkeeping cleanup.
    def clear_accumulation_buffer!
      @buffer = ""
      @buffer_mode = nil
      @buffered_lines = []
    end

    # Gets the next headline number for a given level. The intent is
    # this function is called sequentially for each headline that
    # needs to get numbered. It does standard outline numbering.
    def get_next_headline_number(level)
      raise "Headline level not valid: #{level}" if level <= 0
      while level > @headline_number_stack.length do
        @headline_number_stack.push 0
      end
      while level < @headline_number_stack.length do
        @headline_number_stack.pop
      end
      raise "Oops, shouldn't happen" unless level == @headline_number_stack.length
      @headline_number_stack[@headline_number_stack.length - 1] += 1
      @headline_number_stack.join(".")
    end

    # Tests if we are entering a table mode.
    def enter_table?
      ((@output_type == :table_row) || (@output_type == :table_header) || (@output_type == :table_separator)) &&
        (current_mode != :table)
    end

    # Tests if we are existing a table mode.
    def exit_table?
      ((@output_type != :table_row) && (@output_type != :table_header) && (@output_type != :table_separator)) &&
        (current_mode == :table)
    end

    # Accumulate the string @str@.
    def << (str)
      if @buffer_mode && @buffer_mode != current_mode then
        raise "Accumulation buffer is mixing modes: @buffer_mode == #{@buffer_mode}, current_mode == #{current_mode}"
      else
        @buffer_mode = current_mode
      end
      @buffer << str
    end

    # Gets the current list indent level.
    def list_indent_level
      @list_indent_stack.length
    end

    # Test if we're in an output mode in which whitespace is significant.
    def preserve_whitespace?
      mode_is_code current_mode
    end

    ######################################################################
    private

    def mode_is_code(mode)
      case mode
      when :src, :inline_example, :example
        true
      else
        false
      end
    end

    def maintain_mode_stack(line)
      # Always close heading line
      pop_mode if HeadingModes.include?(current_mode)
      # Always close paragraph mode
      pop_mode if current_mode == :paragraph

      if ((not line.paragraph_type == :blank) or
          @output_type == :blank)
        # Close previous tags on demand. Two blank lines close all tags.
        while ((not @list_indent_stack.empty?) and
               @list_indent_stack.last >= line.indent)
          unless (line.plain_list? and
                  current_mode == line.paragraph_type and
                  @list_indent_stack.last == line.indent)
            pop_mode
          else
            break
          end
        end
        # Open plain list.
        if line.plain_list?
          if (@list_indent_stack.empty? or
              @list_indent_stack.last < line.indent)
            push_mode(line.paragraph_type, line)
            @output << "\n"
          end
        end
        # Open tag preceding text, including list item.
        if (@list_indent_stack.empty? or
            @list_indent_stack.last <= line.indent)
          if (line.paragraph_type == :ordered_list or
              line.paragraph_type == :unordered_list)
            push_mode(:list_item, line)
          elsif not line.paragraph_type == :blank
            push_mode(line.paragraph_type, line)
          end
        end
      else # If blank line, close preceding paragraph
        pop_mode if current_mode == :paragraph
      end
    end

    def output_footnotes!
      return false
    end

    # Tests if the current line should be accumulated in the current
    # output buffer.
    def should_accumulate_output?(line)
      # Special case: Assign mode if not yet done.
      return false if not current_mode

      # Special case: We are accumulating source code block content for colorizing
      return true if line.paragraph_type == :src and @output_type == :src

      # Special case: Blank line at least splits paragraphs
      return false if @output_type == :blank

      if line.paragraph_type == :paragraph
        # Paragraph gets accumulated only if its indent level is
        # greater than the indent level of the previous modes.
        @list_indent_stack[0..-2].each do |indent|
          return false if line.indent <= indent
        end
        # Special case: Multiple "paragraphs" get accumulated.
        return true if current_mode == :paragraph
      end

      false
    end
  end                           # class OutputBuffer
end                             # module Orgmode
