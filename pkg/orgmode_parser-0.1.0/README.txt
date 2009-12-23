orgmode_parser
    by Brian Dewey
    http://www.bdewey.com

== DESCRIPTION:

Helpful Ruby routines for parsing orgmode files. The most significant
thing this library does today is convert orgmode files to
textile. Currently, you cannot do much to customize the
conversion. The supplied textile conversion is optimized for
extracting "content" from the orgfile as opposed to "metadata."

== FEATURES/PROBLEMS:

* Upcoming: Handle export options specified in the org buffer.
* Bug: Currently doesn't handle orgmode inline code or block code syntax.

== SYNOPSIS:

From the command line:

     orgparser sample.org

...will output a textile version of @sample.org@. 

From Ruby code:

     Orgmode::Parser.new(data)

...will construct a new @Parser@ object. 

== INSTALL:

sudo gem install orgmode_parser

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
