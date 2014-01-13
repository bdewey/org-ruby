Inline Formatting

I want to make sure I handle all inline formatting. I need to handle
**bold**, *italic*, `code`, `verbatim`, *underline*, ~~strikethrough~~.

In addition, I need to make sure I can handle links. We've got simple
links, like this:

 * [http://www.bing.com](http://www.bing.com)
 * [http://www.google.com](http://www.google.com)
 * http://www.gmail.com

Note the last one **is not** a link, as the source doesn't include it in
double-brackets and I don't auto-recognize URLs.

I should also handle links with [helpful text](http://www.xkcd.com).

Helpful addition from [punchagan](https://github.com/punchagan), we now
recognize when the link goes to an image and make the link anchor be the
image, like this:

 * [http://farm7.static.flickr.com/6078/6084185195_552aa270b2.jpg](http://farm7.static.flickr.com/6078/6084185195_552aa270b2.jpg)

Also, if you make the descriptive text be an image, then it will get formatted
with an image tag, like so:

 * ![http://imgs.xkcd.com/comics/t_cells.png](http://imgs.xkcd.com/comics/t_cells.png)

Helpful addition from [wallyqs](https://github.com/wallyqs):


While "naked" links don't work (like http://www.google.com), angle links
do work. This should look like a link: [http://www.google.com](http://www.google.com).

It should be possible to use both kind of links on the same paragraph:

This is an angle link [http://google.com](http://google.com) and this is a bracket link [to a repository](https://github.com/bdewey/org-ruby).

This is a bracket link [to a repository](https://github.com/bdewey/org-ruby) and this is an angle link [http://google.com](http://google.com).

This is a bracket link [to a repository](https://github.com/bdewey/org-ruby) and this is a bracket link too  [to a repository](https://github.com/bdewey/org-ruby).

This is an angle link [http://google.com](http://google.com) and this is an angle link too [http://google.com](http://google.com).
