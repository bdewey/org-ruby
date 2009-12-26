require OrgRuby.libpath(*%w[org-ruby output_buffer])

module Orgmode

  class HtmlOutputBuffer < OutputBuffer

    HtmlBlockTag = {
      :paragraph => "p",
      :ordered_list => "li",
      :unordered_list => "li"
    }

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
