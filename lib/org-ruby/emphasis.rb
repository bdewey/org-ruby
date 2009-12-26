require 'logger'

module Orgmode

  class Emphasis

    ######################################################################
    # EMPHASIS
    #
    # I figure it's best to stick as closely to the elisp implementation
    # as possible for emphasis. org.el defines the regular expression that
    # is used to apply "emphasis" (in my terminology, inline formatting
    # instead of block formatting). Here's the documentation from org.el.
    #
    # Terminology: In an emphasis string like " *strong word* ", we
    # call the initial space PREMATCH, the final space POSTMATCH, the
    # stars MARKERS, "s" and "d" are BORDER characters and "trong wor"
    # is the body.  The different components in this variable specify
    # what is allowed/forbidden in each part:
    #
    # pre          Chars allowed as prematch.  Line beginning allowed, too.
    # post         Chars allowed as postmatch.  Line end will be allowed too.
    # border       The chars *forbidden* as border characters.
    # body-regexp  A regexp like \".\" to match a body character.  Don't use
    #              non-shy groups here, and don't allow newline here.
    # newline      The maximum number of newlines allowed in an emphasis exp.
    #
    # I currently don't use +newline+ because I've thrown this information
    # away by this point in the code. TODO -- revisit?
    attr_reader   :pre_emphasis
    attr_reader   :post_emphasis
    attr_reader   :border_forbidden
    attr_reader   :body_regexp
    attr_reader   :markers

    attr_reader   :org_emphasis_regexp

    def initialize
      # Set up the emphasis regular expression.
      @pre_emphasis = " \t\\('\""
      @post_emphasis = "- \t.,:!?;'\"\\)"
      @border_forbidden = " \t\r\n,\"'"
      @body_regexp = ".*?"
      @markers = "*/_=~+"
      @logger = Logger.new(STDERR)
      @logger.level = Logger::WARN
      build_org_emphasis_regexp
      build_org_link_regexp
    end

    # Finds all emphasis matches in a string.
    # Supply a block that will get the marker and body as parameters.
    def match_all(str)
      str.scan(@org_emphasis_regexp) do |match|
        yield $2, $3
      end
    end

    # Compute replacements for all matching emphasized phrases.
    # Supply a block that will get the marker and body as parameters;
    # return the replacement string from your block.
    def replace_all(str)
      str.gsub(@org_emphasis_regexp) do |match|
        inner = yield $2, $3
        "#{$1}#{inner}#{$4}"
      end
    end

    # Give this a block that expect the link and optional friendly
    # text. Return how that link should get formatted.
    def rewrite_links(str)
      i = str.gsub(@org_link_regexp) do |match|
        yield $1, nil
      end
      i.gsub(@org_link_text_regexp) do |match|
        yield $1, $2
      end
    end

    private

    def build_org_emphasis_regexp
      @org_emphasis_regexp = Regexp.new("([#{@pre_emphasis}]|^)\n" +
                                        "(  [#{@markers}]  )\n" + 
                                        "(  [^#{@border_forbidden}]  | " +
                                        "  [^#{@border_forbidden}]#{@body_regexp}[^#{@border_forbidden}]  )\n" +
                                        "\\2\n" +
                                        "([#{@post_emphasis}]|$)\n", Regexp::EXTENDED)
      @logger.debug "Just created regexp: #{@org_emphasis_regexp}"
    end

    def build_org_link_regexp
      @org_link_regexp = /\[\[
                             ([^\]]*) # This is the URL
                          \]\]/x
      @org_link_text_regexp = /\[\[
                                 ([^\]]*) # This is the URL
                               \]\[
                                 ([^\]]*) # This is the friendly text
                               \]\]/x
    end
  end                           # class Emphasis
end                             # module Orgmode
