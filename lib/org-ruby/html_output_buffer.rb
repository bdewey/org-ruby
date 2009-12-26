require OrgRuby.libpath(*%w[org-ruby output_buffer])

module Orgmode

  class HtmlOutputBuffer < OutputBuffer

    HtmlBlockTag = {
      :paragraph => "p",
      :ordered_list => "li",
      :unordered_list => "li"
    }

    def push_mode(mode)
      super(mode)
      @output << "<ul>\n" if mode == :unordered_list
      @output << "<ol>\n" if mode == :ordered_list
    end

    def pop_mode(mode = nil)
      m = super(mode)
      @output << "</ul>\n" if m == :unordered_list
      @output << "</ol>\n" if m == :ordered_list
    end

    def flush!
      @logger.debug "FLUSH ==========> #{@output_type}"
      if (@buffer.length > 0) then
        @output << "<#{HtmlBlockTag[@output_type]}>" << @buffer.rstrip \
          << "</#{HtmlBlockTag[@output_type]}>\n"
      end
      @buffer = ""
    end
  end                           # class HtmlOutputBuffer
end                             # module Orgmode
