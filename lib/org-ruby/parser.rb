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
      @headline_number_stack = []
      output = ""
      if @in_buffer_settings["TITLE"] then
        output << "<p class=\"title\">#{@in_buffer_settings["TITLE"]}</p>\n"
        decorate = false
      else
        decorate = true
      end
      output << Line.to_html(@header_lines, :decorate_title => decorate) unless skip_header_lines?
      decorate = (output.length == 0)
      @headlines.each do |headline|
        output << headline.to_html(:decorate_title => decorate)
        decorate = (output.length == 0)
      end
      rp = RubyPants.new(output)
      rp.to_html
    end

    ######################################################################
    private

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
      else
        @in_buffer_settings[key] = value
      end
    end
  end                             # class Parser
end                               # module Orgmode
