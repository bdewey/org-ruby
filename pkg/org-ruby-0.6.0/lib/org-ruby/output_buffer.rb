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
      push_mode(:normal)
    end

    Modes = [:normal, :ordered_list, :unordered_list, :definition_list, :blockquote, :src, :example, :table, :inline_example, :center]

    def current_mode
      @mode_stack.last
    end

    def current_mode_list?
      (current_mode == :ordered_list) or (current_mode == :unordered_list)
    end

    def push_mode(mode)
      raise "Not a recognized mode: #{mode}" unless Modes.include?(mode)
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
      @logger.debug "Looking at #{line.paragraph_type}: #{line.to_s}"
      if not should_accumulate_output?(line) then
        flush!
        maintain_list_indent_stack(line)
        @output_type = line.paragraph_type 
      end
      push_mode(:inline_example) if line.inline_example? and current_mode != :inline_example
      pop_mode(:inline_example) if current_mode == :inline_example && !line.inline_example?
      push_mode(:table) if enter_table?
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

    def maintain_list_indent_stack(line)
      if (line.plain_list?) then
        while (not @list_indent_stack.empty? \
               and (@list_indent_stack.last > line.indent)) 
          @list_indent_stack.pop
          pop_mode
        end
        if (@list_indent_stack.empty? \
            or @list_indent_stack.last < line.indent)
          @list_indent_stack.push(line.indent)
          push_mode line.paragraph_type
        end
      elsif line.blank? then

        # Nothing

      elsif ((line.paragraph_type == :paragraph) and
             (not @list_indent_stack.empty? and
              line.indent > @list_indent_stack.last))

        # Nothing -- output this paragraph inside
        # the list block (ul/ol)

      else
        @list_indent_stack = []
        while ((current_mode == :ordered_list) or
               (current_mode == :definition_list) or
               (current_mode == :unordered_list))
          pop_mode
        end
      end
    end

    def output_footnotes!
      return false
    end

    # Tests if the current line should be accumulated in the current
    # output buffer.  (Extraneous line breaks in the orgmode buffer
    # are removed by accumulating lines in the output buffer without
    # line breaks.)
    def should_accumulate_output?(line)

      # Special case: Preserve line breaks in block code mode.
      return false if preserve_whitespace?

      # Special case: Multiple blank lines get accumulated.
      return true if line.paragraph_type == :blank and @output_type == :blank
      
      # Currently only "paragraphs" get accumulated with previous output.
      return false unless line.paragraph_type == :paragraph
      if ((@output_type == :ordered_list) or
          (@output_type == :definition_list) or
          (@output_type == :unordered_list)) then

        # If the previous output type was a list item, then we only put a paragraph in it
        # if its indent level is greater than the list indent level.

        return false unless line.indent > @list_indent_stack.last
      end

      # Only accumulate paragraphs with lists & paragraphs.
      return false unless
        ((@output_type == :paragraph) or
         (@output_type == :ordered_list) or
         (@output_type == :definition_list) or
         (@output_type == :unordered_list))
      true
    end
  end                           # class OutputBuffer
end                             # module Orgmode
