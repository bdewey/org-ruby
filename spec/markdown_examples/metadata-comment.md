# Metadata, etc.

I normally filter out things that look like metadata. Can't do it any
more. I need to see all of the following:

```
* DONE Handle inline formatting
  CLOSED: [2009-12-26 Sat 21:41]
  :PROPERTIES:
  :ARCHIVE_TIME: 2009-12-26 Sat 22:16
  :ARCHIVE_FILE: ~/brians-brain/content/projects/orgmode_parser.org
  :ARCHIVE_OLPATH: <%= @page.title %>/Future Development
  :ARCHIVE_CATEGORY: orgmode_parser
  :ARCHIVE_TODO: DONE
  :END:

  I still need to handle:

  - [ ] =Inline code=

  How does the =emacs= HTML parser handle *inline* formatting? Ah,
  it looks like it defines everything in =org-emphasis-alist= (line
  2855 of =org.el=).

  And then look at =org-emphasis-regexp-components=, line 2828 of
  =org.el=. It looks like they just use a crazy regexp for inline
  formatting. Which is good, because it means I can copy!


```
