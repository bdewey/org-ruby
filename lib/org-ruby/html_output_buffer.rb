require OrgRuby.libpath(*%w[org-ruby output_buffer])

module Orgmode

  class HtmlOutputBuffer < OutputBuffer

    HtmlBlockTag = {
      :paragraph => "p",
      :ordered_list => "li",
      :unordered_list => "li",
      :table_row => "tr"
    }

    ModeTag = {
      :unordered_list => "ul",
      :ordered_list => "ol",
      :table => "table",
      :blockquote => "blockquote",
      :code => "pre"
    }

    def initialize(output, opts = {})
      super(output)
      if opts[:decorate_title] then
        @title_decoration = " class=\"title\""
      else
        @title_decoration = ""
      end
    end

    def push_mode(mode)
      if ModeTag[mode] then
        output_indentation
        @logger.debug "<#{ModeTag[mode]}>\n" 
        @output << "<#{ModeTag[mode]}>\n" 
        # Entering a new mode obliterates the title decoration
        @title_decoration = ""
      end
      super(mode)
    end

    def pop_mode(mode = nil)
      m = super(mode)
      if ModeTag[m] then
        output_indentation
        @logger.debug "</#{ModeTag[m]}>\n"
        @output << "</#{ModeTag[m]}>\n"
      end
    end

    def flush!
      escape_buffer!
      if @buffer_mode == :code then
        # Whitespace is significant in :code mode. Always output the buffer
        # and do not do any additional translation.
        # 
        # FIXME 2009-12-29 bdewey: It looks like I'll always get an extraneous
        # newline at the start of code blocks. Find a way to fix this.
        @logger.debug "FLUSH CODE ==========> #{@buffer.inspect}"
        @output << @buffer << "\n"
      else
        if (@buffer.length > 0) then
          @logger.debug "FLUSH      ==========> #{@output_type}"
          output_indentation
          @output << "<#{HtmlBlockTag[@output_type]}#{@title_decoration}>" \
            << inline_formatting(@buffer) \
            << "</#{HtmlBlockTag[@output_type]}>\n"
          @title_decoration = ""
        end
      end
      @buffer = ""
      @buffer_mode = nil
    end

    ######################################################################
    private

    # Escapes any HTML content in the output accumulation buffer @buffer.
    def escape_buffer!
      @buffer.gsub!(/&/, "&amp;")
      @buffer.gsub!(/</, "&lt;")
      @buffer.gsub!(/>/, "&gt;")
    end

    def output_indentation
      indent = "  " * (@mode_stack.length - 1)
      @output << indent
    end

    Tags = {
      "*" => { :open => "<b>", :close => "</b>" },
      "/" => { :open => "<i>", :close => "</i>" },
      "_" => { :open => "<span style=\"text-decoration:underline;\">",
        :close => "</span>" },
      "=" => { :open => "<code>", :close => "</code>" },
      "~" => { :open => "<code>", :close => "</code>" },
      "+" => { :open => "<del>", :close => "</del>" }
    }

    # Applies inline formatting rules to a string.
    def inline_formatting(str)
      str.rstrip!
      str = @re_help.rewrite_emphasis(str) do |marker, s|
        "#{Tags[marker][:open]}#{s}#{Tags[marker][:close]}"
      end
      str = @re_help.rewrite_links(str) do |link, text|
        text ||= link
        link = link.sub(/^file:(.*)::(.*?)$/) do

          # We don't support search links right now. Get rid of it.

          "file:#{$1}"
        end
        link = link.sub(/^file:/i, "") # will default to HTTP
        link = link.sub(/\.org$/i, ".html")
        "<a href=\"#{link}\">#{text}</a>"
      end
      if (@output_type == :table_row) then
        str.gsub!(/^\|\s*/, "<td>")
        str.gsub!(/\s*\|$/, "</td>")
        str.gsub!(/\s*\|\s*/, "</td><td>")
      end
      str
    end

  end                           # class HtmlOutputBuffer
end                             # module Orgmode
