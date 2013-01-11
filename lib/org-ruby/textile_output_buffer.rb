require 'stringio'

module Orgmode

  class TextileOutputBuffer < OutputBuffer

    def initialize(output)
      super(output)
      @add_paragraph = true
      @support_definition_list = true # TODO this should be an option
      @footnotes = {}
    end

    def push_mode(mode, indent)
      @list_indent_stack.push(indent)
      super(mode)
      @output << "bc. " if mode_is_code? mode
      if mode == :center or mode == :blockquote
        @add_paragraph = false
        @output << "\n"
      end
    end

    def pop_mode(mode = nil)
      m = super(mode)
      @list_indent_stack.pop
      if m == :center or m == :blockquote
        @add_paragraph = true
        @output << "\n"
      end
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
      input = @re_help.rewrite_footnote(input) do |name, defi|
        # textile only support numerical names! Use hash as a workarround
        name = name.hash.to_s unless name.to_i.to_s == name # check if number
        @footnotes[name] = defi if defi
        "[#{name}]"
      end
      Orgmode.special_symbols_to_textile(input)
      input
    end

    def output_footnotes!
      return false if @footnotes.empty?

      @footnotes.each do |name, defi|
        @output << "\nfn#{name}. #{defi}\n"
      end

      return true
    end

    # Flushes the current buffer
    def flush!
      @logger.debug "FLUSH ==========> #{@output_type}"
      if @output_type == :blank and not preserve_whitespace?
        @output << "\n"
      elsif @buffer.length > 0
        @buffer.gsub!(/\A\n*/, "")
        @output << "p. " if @add_paragraph and current_mode == :paragraph
        if @mode_stack[0] and current_mode == :paragraph
          @output << "p=. " if @mode_stack[0] == :center
          @output << "bq. " if @mode_stack[0] == :blockquote
        end
        if current_mode == :definition_item and @support_definition_list
          @output << "-" * @mode_stack.count(:definition_item) << " "
          @buffer.sub!("::", ":=")
        elsif current_mode == :list_item
          if @mode_stack[-2] == :ordered_list
            @output << "#" * @mode_stack.count(:list_item) << " "
          else # corresponds to unordered list
            @output << "*" * @mode_stack.count(:list_item) << " "
          end
        end
        if (@buffered_lines[0].kind_of?(Headline)) then
          headline = @buffered_lines[0]
          raise "Cannot be more than one headline!" if @buffered_lines.length > 1
          @output << "h#{headline.level}. #{headline.headline_text}\n"
        else
          @output << inline_formatting(@buffer) << "\n"
        end
      end
      clear_accumulation_buffer!
    end


  end                           # class TextileOutputBuffer
end                             # module Orgmode
