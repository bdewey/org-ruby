class String
  # I think this is the most beautiful regexp I've ever written.
  LinkRegexp = /\[\[([^\]]*)\]\[([^\]]*)\]\]/

  # Extend the String class to make it easy to do the simple substitutions
  # from one markup format to another.
  def textile_substitution
    str = self.gsub(LinkRegexp, '"\2":\1')
  end
end

