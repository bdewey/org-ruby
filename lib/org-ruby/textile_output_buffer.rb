require 'stringio'

module Orgmode

  class TextileOutputBuffer < OutputBuffer

    def initialize(output)
      super(output)
      @add_paragraph = false
      @support_definition_list = true # TODO this should be an option
    end

    def push_mode(mode)
      super(mode)
      @output << "bc.. " if mode_is_code(mode)
      @output << "\np=. " if mode == :center
    end

    def pop_mode(mode = nil)
      m = super(mode)
      @add_paragraph = (mode_is_code(m))
      @output << "\n" if mode == :center
      m
    end

    # Maps org markup to textile markup.
    TextileMap = {
      "*" => "*",
      "/" => "_",
      "_" => "_",
      "=" => "@",
      "~" => "@",
      "+" => "+"
    }

    # Handles inline formatting for textile.
    def inline_formatting(input)
      input = @re_help.rewrite_emphasis(input) do |marker, body|
        m = TextileMap[marker]
        "#{m}#{body}#{m}"
      end
      input = @re_help.rewrite_subp(input) do |type, text|
        if type == "_" then
          "~#{text}~"
        elsif type == "^" then
          "^#{text}^"
        end
      end
      input = @re_help.rewrite_links(input) do |link, text|
        text ||= link
        link = link.gsub(/ /, "%20")
        "\"#{text}\":#{link}"
      end
      input
    end

    # Flushes the current buffer
    def flush!
      @logger.debug "FLUSH ==========> #{@output_type}"
      if (@output_type == :blank) then
        @output << "\n"
      elsif (@buffer.length > 0) then
        if @add_paragraph then
          @output << "p. " if @output_type == :paragraph
          @add_paragraph = false
        end
        @output << "bq. " if current_mode == :blockquote
        if @output_type == :definition_list and @support_definition_list then
          @output << "-" * @list_indent_stack.length << " "
          @buffer.sub!("::", ":=")
        elsif @output_type == :ordered_list then
          @output << "#" * @list_indent_stack.length << " "
        elsif @output_type == :unordered_list or \
            (@output_type == :definition_list and not @support_definition_list) then
          @output << "*" * @list_indent_stack.length << " "
        end
        @output << inline_formatting(@buffer) << "\n"
      end
      clear_accumulation_buffer!
    end


  end                           # class TextileOutputBuffer
end                             # module Orgmode
