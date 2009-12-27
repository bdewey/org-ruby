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
      :blockquote => "blockquote"
    }

    def push_mode(mode)
      super(mode)
      @output << "<#{ModeTag[mode]}>\n" if ModeTag[mode]
    end

    def pop_mode(mode = nil)
      m = super(mode)
      @output << "</#{ModeTag[m]}>\n" if ModeTag[m]
    end

    def flush!
      @logger.debug "FLUSH ==========> #{@output_type}"
      if (@buffer.length > 0) then
        @output << "<#{HtmlBlockTag[@output_type]}>" << inline_formatting(@buffer) \
          << "</#{HtmlBlockTag[@output_type]}>\n"
      end
      @buffer = ""
    end

    ######################################################################
    private

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
      if (@output_type == :table_row) then
        str.gsub!(/^\|\s*/, "<td>")
        str.gsub!(/\s*\|$/, "</td>")
        str.gsub!(/\s*\|\s*/, "</td><td>")
      end
      str = @emphasis.replace_all(str) do |marker, s|
        "#{Tags[marker][:open]}#{s}#{Tags[marker][:close]}"
      end
      str = @emphasis.rewrite_links(str) do |link, text|
        text ||= link
        "<a href=\"#{link}\">#{text}</a>"
      end
      str
    end

  end                           # class HtmlOutputBuffer
end                             # module Orgmode
