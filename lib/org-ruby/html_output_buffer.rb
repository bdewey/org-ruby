begin
  require 'pygments'
rescue LoadError
  # Pygments is not supported so we try instead with CodeRay
  begin
    require 'coderay'
  rescue LoadError
    # No code syntax highlighting
  end
end

module Orgmode

  class HtmlOutputBuffer < OutputBuffer

    HtmlBlockTag = {
      :paragraph => "p",
      :ordered_list => "li",
      :unordered_list => "li",
      :definition_term => "dt",
      :definition_descr => "dd",
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
      :definition_list => "dl",
      :table => "table",
      :blockquote => "blockquote",
      :example => "pre",
      :src => "pre",
      :inline_example => "pre",
      :center => "div"
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
      @footnotes = {}
      @unclosed_tags = []
      @logger.debug "HTML export options: #{@options.inspect}"
    end

    # Output buffer is entering a new mode. Use this opportunity to
    # write out one of the block tags in the ModeTag constant to put
    # this information in the HTML stream.
    def push_mode(mode)
      if ModeTag[mode] then
        output_indentation
        css_class = ""
        css_class = " class=\"src\"" if mode == :src and @block_lang.empty?
        css_class = " class=\"src src-#{@block_lang}\"" if mode == :src and not @block_lang.empty?
        css_class = " class=\"example\"" if (mode == :example || mode == :inline_example)
        css_class = " style=\"text-align: center\"" if mode == :center

        unless ((mode == :table and skip_tables?) or
                (mode == :src and defined? Pygments))
          @logger.debug "#{mode}: <#{ModeTag[mode]}#{css_class}>\n"
          @output << "<#{ModeTag[mode]}#{css_class}>\n"
        end
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
        # Need to close the floating li elements before closing the list
        if (m == :unordered_list or
            m == :ordered_list or
            m == :definition_list) and
            (not @unclosed_tags.empty?)
          close_floating_li_tags
        end

        unless ((mode == :table and skip_tables?) or
                (mode == :src and defined? Pygments))
          @logger.debug "</#{ModeTag[m]}>\n"
          @output << "</#{ModeTag[m]}>\n"
        end

        # In case it was a sublist, close it here
        close_last_li_tag_maybe
      end
    end

    def flush!
      @buffer = @buffer.rstrip
      if buffer_mode_is_src_block?

        # Only try to colorize #+BEGIN_SRC blocks with a specified language,
        # but we still have to catch the cases when a lexer for the language was not available
        if defined? Pygments or defined? CodeRay
          lang = normalize_lang(@block_lang)

          # NOTE: CodeRay and Pygments already escape the html once, so no need to escape_buffer!
          if defined? Pygments
            begin
              @buffer = Pygments.highlight(@buffer, :lexer => lang)
            rescue
              # Not supported lexer from Pygments, we fallback on using the text lexer
              @buffer = Pygments.highlight(@buffer, :lexer => 'text')
            end
          elsif defined? CodeRay
            # CodeRay might throw a warning when unsupported lang is set,
            # then fallback to using the text lexer
            silence_warnings do
              begin
                @buffer = CodeRay.scan(@buffer, lang).html(:wrap => nil, :css => :style)
              rescue ArgumentError
                @buffer = CodeRay.scan(@buffer, 'text').html(:wrap => nil, :css => :style)
              end
            end
          end
        else
          escape_buffer!
        end

        @logger.debug "FLUSH SRC CODE ==========> #{@buffer.inspect}"
        @output << @buffer
      elsif mode_is_code(@buffer_mode) then
        escape_buffer!

        # Whitespace is significant in :code mode. Always output the buffer
        # and do not do any additional translation.
        @logger.debug "FLUSH CODE ==========> #{@buffer.inspect}"
        @output << @buffer << "\n"
      else
        escape_buffer!
        if @buffer.length > 0 and @output_type == :horizontal_rule then
          @output << "<hr />\n"
        elsif @buffer.length > 0 and @output_type == :definition_list then
          unless buffer_mode_is_table? and skip_tables?
            output_indentation
            d = @buffer.split("::", 2)
            @output << "<#{HtmlBlockTag[:definition_term]}#{@title_decoration}>" << inline_formatting(d[0].strip) \
                    << "</#{HtmlBlockTag[:definition_term]}>"
            if d.length > 1 then
              @output << "<#{HtmlBlockTag[:definition_descr]}#{@title_decoration}>" << inline_formatting(d[1].strip) \
                      << "</#{HtmlBlockTag[:definition_descr]}>\n"
            else
              @output << "\n"
            end
            @title_decoration = ""
          end
        elsif @buffer.length > 0 then
          unless buffer_mode_is_table? and skip_tables?
            @logger.debug "FLUSH      ==========> #{@buffer_mode}"
            output_indentation
            if ((@buffered_lines[0].plain_list?) and
                (@unclosed_tags.count == @list_indent_stack.count))
              @output << @unclosed_tags.pop
              output_indentation
            end
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

            # Only close the list when it is the last element from that list,
            # or when starting another list
            if (@output_type == :unordered_list or
                @output_type == :ordered_list   or
                @output_type == :definition_list) and
                (not @list_indent_stack.empty?)
              @unclosed_tags.push("</#{HtmlBlockTag[@output_type]}>\n")
              @output << "\n"
            else
              @output << "</#{HtmlBlockTag[@output_type]}>\n"
            end
            @title_decoration = ""
          else
            @logger.debug "SKIP       ==========> #{@buffer_mode}"
          end
        end
      end
      clear_accumulation_buffer!
    end

    def output_footnotes!
      return false unless @options[:export_footnotes] and not @footnotes.empty?

      @output << "<div id=\"footnotes\">\n<h2 class=\"footnotes\">Footnotes: </h2>\n<div id=\"text-footnotes\">\n"

      @footnotes.each do |name, defi|
        @output << "<p class=\"footnote\"><sup><a class=\"footnum\" name=\"fn.#{name}\" href=\"#fnr.#{name}\">#{name}</a></sup>" \
                << inline_formatting(defi) \
                << "</p>\n"
      end

      @output << "</div>\n</div>\n"

      return true
    end


    ######################################################################
    private

    def skip_tables?
      @options[:skip_tables]
    end

    def buffer_mode_is_table?
      @buffer_mode == :table
    end

    def buffer_mode_is_src_block?
      @buffer_mode == :src
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
      if @options[:use_sub_superscripts] then
        str = @re_help.rewrite_subp(str) do |type, text|
          if type == "_" then
            "<sub>#{text}</sub>"
          elsif type == "^" then
            "<sup>#{text}</sup>"
          end
        end
      end
      str = @re_help.rewrite_images(str) do |link|
        "<a href=\"#{link}\"><img src=\"#{link}\" /></a>"
      end
      str = @re_help.rewrite_links(str) do |link, text|
        text ||= link
        link = link.sub(/^file:(.*)::(.*?)$/) do

          # We don't support search links right now. Get rid of it.

          "file:#{$1}"
        end
        if link.match(/^file:.*\.org$/)
          link = link.sub(/\.org$/i, ".html")
        end

        link = link.sub(/^file:/i, "") # will default to HTTP

        text = text.gsub(/([^\]]*\.(jpg|jpeg|gif|png))/xi) do |img_link|
          "<img src=\"#{img_link}\" />"
        end
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
      if @options[:export_footnotes] then
        str = @re_help.rewrite_footnote(str) do |name, defi|
          # TODO escape name for url?
          @footnotes[name] = defi if defi
          "<sup><a class=\"footref\" name=\"fnr.#{name}\" href=\"#fn.#{name}\">#{name}</a></sup>"
        end
      end
      Orgmode.special_symbols_to_html(str)
      str
    end

    def close_floating_li_tags
      unless @final_list_node
        unless @unclosed_tags.empty?
          @output << "  " << @unclosed_tags.pop
          output_indentation
        end
      end

      @final_list_node = false
    end

    def close_last_li_tag_maybe
      if (@list_indent_stack.count < @unclosed_tags.count) and not
          (@list_indent_stack.empty? and @unclosed_tags.empty?)
        output_indentation
        @output << @unclosed_tags.pop
        if (@list_indent_stack.count == @unclosed_tags.count) and not
            (@list_indent_stack.empty? and @unclosed_tags.empty?)
          @final_list_node = true
          pop_mode
        end
      end
    end

    def normalize_lang(lang)
      case lang
      when 'emacs-lisp', 'common-lisp', 'lisp'
        'scheme'
      when ''
        'text'
      else
        lang
      end
    end

    # Helper method taken from Rails
    # https://github.com/rails/rails/blob/c2c8ef57d6f00d1c22743dc43746f95704d67a95/activesupport/lib/active_support/core_ext/kernel/reporting.rb#L10
    def silence_warnings
      warn_level = $VERBOSE
      $VERBOSE = nil
      yield
    ensure
      $VERBOSE = warn_level
    end
  end                           # class HtmlOutputBuffer
end                             # module Orgmode
