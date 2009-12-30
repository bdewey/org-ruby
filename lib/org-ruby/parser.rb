require 'rubygems'
require 'rubypants'

module Orgmode

  ##
  ##  Simple routines for loading / saving an ORG file.
  ##

  class Parser

    # All of the lines of the orgmode file
    attr_reader :lines

    # All of the headlines in the org file
    attr_reader :headlines

    # These are any lines before the first headline
    attr_reader :header_lines

    # This contains any in-buffer settings from the org-mode file.
    # See http://orgmode.org/manual/In_002dbuffer-settings.html#In_002dbuffer-settings
    attr_reader :in_buffer_settings

    # This contains in-buffer options; a special case of in-buffer settings.
    attr_reader :options

    # Array of custom keywords.
    attr_reader :custom_keywords

    # Regexp that recognizes words in custom_keywords.
    def custom_keyword_regexp
      return nil if @custom_keywords.empty?
      Regexp.new("^(#{@custom_keywords.join('|')})\$")
    end

    # A set of tags that, if present on any headlines in the org-file, means
    # only those headings will get exported.
    def export_select_tags
      return Array.new unless @in_buffer_settings["EXPORT_SELECT_TAGS"]
      @in_buffer_settings["EXPORT_SELECT_TAGS"].split
    end

    # A set of tags that, if present on any headlines in the org-file, means
    # that subtree will not get exported.
    def export_exclude_tags
      return Array.new unless @in_buffer_settings["EXPORT_EXCLUDE_TAGS"]
      @in_buffer_settings["EXPORT_EXCLUDE_TAGS"].split
    end

    # Returns true if we are to export todo keywords on headings.
    def export_todo?
      "t" == @options["todo"]
    end

    # This stack is used to do proper outline numbering of headlines.
    attr_accessor :headline_number_stack

    # Returns true if we are to export heading numbers.
    def export_heading_number?
      "t" == @options["num"]
    end

    # Should we skip exporting text before the first heading?
    def skip_header_lines?
      "t" == @options["skip"]
    end

    # Should we export tables? Defaults to true, must be overridden
    # with an explicit "nil"
    def export_tables?
      "nil" != @options["|"]
    end

    # Gets the next headline number for a given level. The intent is
    # this function is called sequentially for each headline that
    # needs to get numbered. It does standard outline numbering.
    def get_next_headline_number(level)
      raise "Headline level not valid: #{level}" if level <= 0
      while level > @headline_number_stack.length do
        @headline_number_stack.push 0
      end
      while level < @headline_number_stack.length do
        @headline_number_stack.pop
      end
      raise "Oops, shouldn't happen" unless level == @headline_number_stack.length
      @headline_number_stack[@headline_number_stack.length - 1] += 1
      @headline_number_stack.join(".")
    end

    # I can construct a parser object either with an array of lines
    # or with a single string that I will split along \n boundaries.
    def initialize(lines)
      if lines.is_a? Array then
        @lines = lines
      elsif lines.is_a? String then
        @lines = lines.split("\n")
      else
        raise "Unsupported type for +lines+: #{lines.class}"
      end

      @custom_keywords = []
      @headlines = Array.new
      @current_headline = nil
      @header_lines = []
      @in_buffer_settings = { }
      @headline_number_stack = []
      @options = { }
      mode = :normal
      previous_line = nil
      @lines.each do |line|
        case mode
        when :normal

          if (Headline.headline? line) then
            @current_headline = Headline.new line, self
            @headlines << @current_headline
          else
            line = Line.new line, self
            # If there is a setting on this line, remember it.
            line.in_buffer_setting? do |key, value|
              store_in_buffer_setting key, value
            end
            if line.table_separator? then
              previous_line.assigned_paragraph_type = :table_header if previous_line and previous_line.paragraph_type == :table_row
            end
            mode = :code if line.begin_block? and line.block_type == "EXAMPLE"
            if (@current_headline) then
              @current_headline.body_lines << line
            else
              @header_lines << line
            end
          end

        when :code

          # As long as we stay in code mode, force lines to be either blank or paragraphs.
          # Don't try to interpret structural items, like headings and tables.
          line = Line.new line
          if line.end_block? and line.block_type == "EXAMPLE"
            mode = :normal
          else
            line.assigned_paragraph_type = :paragraph unless line.blank?
          end
          if (@current_headline) then
            @current_headline.body_lines << line
          else
            @header_lines << line
          end
        end                     # case
        previous_line = line
      end                       # @lines.each
    end                         # initialize

    # Creates a new parser from the data in a given file
    def self.load(fname)
      lines = IO.readlines(fname)
      return self.new(lines)
    end

    # Saves the loaded orgmode file as a textile file.
    def to_textile
      output = ""
      output << Line.to_textile(@header_lines)
      @headlines.each do |headline|
        output << headline.to_textile
      end
      output
    end

    # Converts the loaded org-mode file to HTML.
    def to_html
      mark_trees_for_export
      @headline_number_stack = []
      export_options = { }
      export_options[:skip_tables] = true if not export_tables?
      output = ""
      if @in_buffer_settings["TITLE"] then
        output << "<p class=\"title\">#{@in_buffer_settings["TITLE"]}</p>\n"
      else
        export_options[:decorate_title] = true
      end
      output << Line.to_html(@header_lines, export_options) unless skip_header_lines?
      
      # If we've output anything at all, remove the :decorate_title option.
      export_options.delete(:decorate_title) if (output.length > 0)
      @headlines.each do |headline|
        output << headline.to_html(export_options)
        export_options.delete(:decorate_title) if (output.length > 0)
      end
      rp = RubyPants.new(output)
      rp.to_html
    end

    ######################################################################
    private

    # Uses export_select_tags and export_exclude_tags to determine
    # which parts of the org-file to export.
    def mark_trees_for_export
      marked_any = false
      # cache the tags
      select = export_select_tags
      exclude = export_exclude_tags
      inherit_export_level = nil
      ancestor_stack = []

      # First pass: See if any headlines are explicitly selected
      @headlines.each do |headline|
        ancestor_stack.pop while not ancestor_stack.empty? and headline.level <= ancestor_stack.last.level
        if inherit_export_level and headline.level > inherit_export_level
          headline.export_state = :all
        else
          inherit_export_level = nil
          headline.tags.each do |tag|
            if (select.include? tag) then
              marked_any = true
              headline.export_state = :all
              ancestor_stack.each { |a| a.export_state = :headline_only unless a.export_state == :all }
              inherit_export_level = headline.level
            end
          end
        end
        ancestor_stack.push headline
      end

      # If nothing was selected, then EVERYTHING is selected.
      @headlines.each { |h| h.export_state = :all } unless marked_any

      # Second pass. Look for things that should be excluded, and get rid of them.
      @headlines.each do |headline|
        if inherit_export_level and headline.level > inherit_export_level
          headline.export_state = :exclude
        else
          inherit_export_level = nil
          headline.tags.each do |tag|
            if (exclude.include? tag) then
              headline.export_state = :exclude
              inherit_export_level = headline.level
            end
          end
        end
      end
    end

    # Stores an in-buffer setting.
    def store_in_buffer_setting(key, value)
      if key == "OPTIONS" then

        # Options are stored in a hash. Special-case.

        value.split.each do |opt|
          if opt =~ /^(.*):(.*?)$/ then
            @options[$1] = $2
          else
            raise "Unexpected option: #{opt}"
          end
        end
      elsif key =~ /^(TODO|SEQ_TODO|TYP_TODO)$/ then
        # Handle todo keywords specially.
        value.split.each do |keyword|
          keyword.gsub!(/\(.*\)/, "") # Get rid of any parenthetical notes
          keyword = Regexp.escape(keyword)
          next if keyword == "\\|"      # Special character in the todo format, not really a keyword
          @custom_keywords << keyword
        end
      else
        @in_buffer_settings[key] = value
      end
    end
  end                             # class Parser
end                               # module Orgmode
