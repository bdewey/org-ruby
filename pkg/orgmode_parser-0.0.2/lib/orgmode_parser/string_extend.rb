require 'stringio'

class String
  # I think this is the most beautiful regexp I've ever written.
  LinkRegexp = /\[\[([^\]]*)\]\[([^\]]*)\]\]/

  # Extend the String class to make it easy to do the simple substitutions
  # from one markup format to another.
  def textile_substitution
    str = StringIO.new
    mode = :normal
    i = 0
    link_url = ""
    link_text = ""
    while (i < self.length) do
      ch = self[i, 1]

      case mode

      when :normal
        
        # Do simple text substitution
        case ch
        when '/'
          ch = '_'

        when '['
          
          # If the next character is '[', we enter link mode.
          if ((i < self.length - 1) && (self[i + 1, 1] == "[")) then
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
          if ((i < self.length - 1) && (self[i+1, 1] == "[")) then

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
end

