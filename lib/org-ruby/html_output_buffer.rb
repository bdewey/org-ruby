require OrgRuby.libpath(*%w[org-ruby output_buffer])

module Orgmode

  class HtmlOutputBuffer < OutputBuffer

    HtmlBlockTag = {
      :paragraph => "p",
      :ordered_list => "li",
      :unordered_list => "li",
      :table_row => "tr",
      :table_header => "tr",
      :heading1 => "h1",
      :heading2 => "h2",
      :heading3 => "h3",
      :heading4 => "h4",
      :heading5 => "h5",
      :heading6 => "h6"
    }

    ModeTag = {
      :unordered_list => "ul",
      :ordered_list => "ol",
      :table => "table",
      :blockquote => "blockquote",
      :example => "pre",
      :src => "pre",
      :inline_example => "pre"
    }

    attr_reader :options

    def initialize(output, opts = {})
      super(output)
      if opts[:decorate_title] then
        @title_decoration = " class=\"title\""
      else
        @title_decoration = ""
      end
      @options = opts
      @logger.debug "HTML export options: #{@options.inspect}"
    end

    # Output buffer is entering a new mode. Use this opportunity to
    # write out one of the block tags in the ModeTag constant to put
    # this information in the HTML stream.
    def push_mode(mode)
      if ModeTag[mode] then
        output_indentation
        css_class = ""
        css_class = " class=\"src\"" if mode == :src
        css_class = " class=\"example\"" if (mode == :example || mode == :inline_example)
        @logger.debug "#{mode}: <#{ModeTag[mode]}#{css_class}>\n" 
        @output << "<#{ModeTag[mode]}#{css_class}>\n" unless mode == :table and skip_tables?
        # Entering a new mode obliterates the title decoration
        @title_decoration = ""
      end
      super(mode)
    end

    # We are leaving a mode. Close any tags that were opened when
    # entering this mode.
    def pop_mode(mode = nil)
      m = super(mode)
      if ModeTag[m] then
        output_indentation
        @logger.debug "</#{ModeTag[m]}>\n"
        @output << "</#{ModeTag[m]}>\n" unless mode == :table and skip_tables?
      end
    end

    def flush!
      escape_buffer!
      if mode_is_code(@buffer_mode) then
        # Whitespace is significant in :code mode. Always output the buffer
        # and do not do any additional translation.
        @logger.debug "FLUSH CODE ==========> #{@buffer.inspect}"
        @output << @buffer << "\n"
      else
        if (@buffer.length > 0) then
          unless buffer_mode_is_table? and skip_tables?
            @logger.debug "FLUSH      ==========> #{@buffer_mode}"
            output_indentation
            @output << "<#{HtmlBlockTag[@output_type]}#{@title_decoration}>" 
            if (@buffered_lines[0].kind_of?(Headline)) then
              headline = @buffered_lines[0]
              raise "Cannot be more than one headline!" if @buffered_lines.length > 1
              if @options[:export_heading_number] then
                level = headline.level
                heading_number = get_next_headline_number(level)
                output << "<span class=\"heading-number heading-number-#{level}\">#{heading_number} </span>"
              end
              if @options[:export_todo] and headline.keyword then
                keyword = headline.keyword
                output << "<span class=\"todo-keyword #{keyword}\">#{keyword} </span>"
              end
            end
            @output << inline_formatting(@buffer) 
            @output << "</#{HtmlBlockTag[@output_type]}>\n"
            @title_decoration = ""
          else
            @logger.debug "SKIP       ==========> #{@buffer_mode}"
          end
        end
      end
      clear_accumulation_buffer!
    end

    ######################################################################
    private

    def skip_tables?
      @options[:skip_tables]
    end

    def buffer_mode_is_table?
      @buffer_mode == :table
    end

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
      str = @re_help.rewrite_subp(str) do |type, text|
        if type == "_" then
          "<sub>#{text}</sub>"
        elsif type == "^" then
          "<sup>#{text}</sup>"
        end
      end
      str = @re_help.rewrite_images(str) do |link|
        "<img src=\"#{link}\" />"
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
      if (@output_type == :table_header) then
        str.gsub!(/^\|\s*/, "<th>")
        str.gsub!(/\s*\|$/, "</th>")
        str.gsub!(/\s*\|\s*/, "</th><th>")
      end
      str
    end

  end                           # class HtmlOutputBuffer
end                             # module Orgmode
