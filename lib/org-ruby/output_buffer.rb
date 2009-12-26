require 'logger'

module Orgmode

  # The OutputBuffer is used to accumulate multiple lines of orgmode
  # text, and then emit them to the output all in one go. The class
  # will do the final textile substitution for inline formatting and
  # add a newline character prior emitting the output.
  class OutputBuffer

    # This is the temporary buffer that we accumulate into.
    attr_reader :buffer

    # This is the overall output buffer
    attr_reader :output

    # This is the current type of output being accumulated. 
    attr_accessor :output_type

    # Creates a new OutputBuffer object that is bound to an output object.
    # The output will get flushed to =output=.
    def initialize(output)
      @output = output
      @buffer = ""
      @output_type = :start
      @list_indent_stack = []
      @paragraph_modifier = nil
      @cancel_modifier = false
      @mode_stack = []
      @add_paragraph = false
      push_mode(:normal)

      @logger = Logger.new(STDERR)
      @logger.level = Logger::WARN

    end

    Modes = [:normal, :ordered_list, :unordered_list, :blockquote, :code]

    def current_mode
      @mode_stack.last
    end

    def current_mode_list?
      (current_mode == :ordered_list) or (current_mode == :unordered_list)
    end

    def push_mode(mode)
      raise "Not a recognized mode: #{mode}" unless Modes.include?(mode)
      @mode_stack.push(mode)
      @output << "bc.. " if mode == :code
    end

    def pop_mode(mode = nil)
      m = @mode_stack.pop
      @logger.warn "Modes don't match. Expected to pop #{mode}, but popped #{m}" if mode && mode != m
      @add_paragraph = (mode == :code)
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
    end

    # Accumulate the string @str@.
    def << (str)
      @buffer << str
    end

    # Gets the current list indent level. 
    def list_indent_level
      @list_indent_stack.length
    end

    # Test if we're in an output mode in which whitespace is significant.
    def preserve_whitespace?
      return current_mode == :code
    end

    ######################################################################
    private

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
      else
        @list_indent_stack = []
        while ((current_mode == :ordered_list) or
               (current_mode == :unordered_list))
          pop_mode
        end
      end
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
          (@output_type == :unordered_list)) then

        # If the previous output type was a list item, then we only put a paragraph in it
        # if its indent level is greater than the list indent level.

        return false unless line.indent > @list_indent_stack.last
      end

      # Only accumulate paragraphs with lists & paragraphs.
      return false unless
        ((@output_type == :paragraph) or
         (@output_type == :ordered_list) or
         (@output_type == :unordered_list))
      true
    end
  end                           # class OutputBuffer
end                             # module Orgmode
