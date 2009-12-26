require 'stringio'

module Orgmode

  class TextileOutputBuffer < OutputBuffer

    # Handles inline formatting for textile.
    def inline_formatting(input)
      str = StringIO.new
      mode = :normal
      i = 0
      link_url = ""
      link_text = ""
      while (i < input.length) do
        ch = input[i, 1]

        case mode

        when :normal
          
          # Do simple text substitution
          case ch
          when '/'
            ch = '_'

          when '['
            
            # If the next character is '[', we enter link mode.
            if ((i < input.length - 1) && (input[i + 1, 1] == "[")) then
              i += 2
              mode = :link_url
              next
            end
          end
          str << ch

        when :link_url
          
          case ch
          when ']'

            # We've read in the whole link URL. Now see if there's link
            # text, or if this is the short form.
            if ((i < input.length - 1) && (input[i+1, 1] == "[")) then

              # Long form! Expect to get link text.
              mode = :link_text
              i += 2
              next

            else

              # Short form! We can output the link now.
              i += 2
              str << "\"#{link_url}\":#{link_url.gsub(/ /, "%20")}"
              link_url = ""
              mode = :normal
              next

            end

          else

            link_url << ch
          end

        when :link_text

          case ch

          when ']'

            link_url.gsub!(/ /, "%20")
            str << "\"#{link_text}\":#{link_url}"
            link_url = ""
            link_text = ""
            i += 2
            mode = :normal
            next

          else
            link_text << ch
          end
          
        end
        i += 1
      end
      str.string
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
        @output << "#" * @list_indent_stack.length << " " if @output_type == :ordered_list
        @output << "*" * @list_indent_stack.length << " " if @output_type == :unordered_list
        @output << inline_formatting(@buffer) << "\n"
      end
      @buffer = ""
    end


  end                           # class TextileOutputBuffer
end                             # module Orgmode
