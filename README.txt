org-ruby
    by Brian Dewey
    http://www.bdewey.com

== DESCRIPTION:

This gem contains Ruby routines for parsing org-mode files.The most
significant thing this library does today is convert org-mode files to
HTML or textile. Currently, you cannot do much to customize the
conversion. The supplied textile conversion is optimized for
extracting "content" from the orgfile as opposed to "metadata." 

== FEATURES/PROBLEMS:

* Converts org-mode files to HTML or Textile
* Supports tables, block quotes, and block code
* Supports bold, italic, underline, strikethrough, and code inline formatting.
* Supports hyperlinks that are in double-brackets
* Upcoming: Handle export options specified in the org buffer.

== SYNOPSIS:

From the command line:

     org-ruby sample.org

...will output a HTML version of sample.org.

     org-ruby --translate textile sample.org

...will output a textile version of sample.org.

From Ruby code:

     Orgmode::Parser.new(data)

...will construct a new +Parser+ object. 

== INSTALL:

sudo gem install org-ruby

== LICENSE:

(The MIT License)

Copyright (c) 2009 Brian Dewey

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
