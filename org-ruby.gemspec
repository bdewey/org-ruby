# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "org-ruby"
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Dewey"]
  s.date = "2012-05-22"
  s.description = "This gem contains Ruby routines for parsing org-mode files.The most\nsignificant thing this library does today is convert org-mode files to\nHTML or textile. Currently, you cannot do much to customize the\nconversion. The supplied textile conversion is optimized for\nextracting \"content\" from the orgfile as opposed to \"metadata.\" "
  s.email = "bdewey@gmail.com"
  s.executables = ["org-ruby"]
  s.extra_rdoc_files = ["History.txt", "README.rdoc", "announcement.txt", "bin/org-ruby"]
  s.files = [".bnsignore", ".gitignore", "Gemfile", "Gemfile.lock", "History.txt", "README.rdoc", "Rakefile", "TAGS", "announcement.txt", "bin/org-ruby", "lib/org-ruby.rb", "lib/org-ruby/headline.rb", "lib/org-ruby/html_output_buffer.rb", "lib/org-ruby/html_symbol_replace.rb", "lib/org-ruby/line.rb", "lib/org-ruby/output_buffer.rb", "lib/org-ruby/parser.rb", "lib/org-ruby/regexp_helper.rb", "lib/org-ruby/textile_output_buffer.rb", "lib/org-ruby/textile_symbol_replace.rb", "lib/org-ruby/tilt.rb", "org-ruby.gemspec", "spec/data/freeform-example.org", "spec/data/freeform.org", "spec/data/hyp-planning.org", "spec/data/remember.org", "spec/headline_spec.rb", "spec/html_examples/advanced-code.html", "spec/html_examples/advanced-code.org", "spec/html_examples/advanced-lists.html", "spec/html_examples/advanced-lists.org", "spec/html_examples/block_code.html", "spec/html_examples/block_code.org", "spec/html_examples/blockcomment.html", "spec/html_examples/blockcomment.org", "spec/html_examples/blockquote.html", "spec/html_examples/blockquote.org", "spec/html_examples/center.html", "spec/html_examples/center.org", "spec/html_examples/code-comment.html", "spec/html_examples/code-comment.org", "spec/html_examples/comment-trees.html", "spec/html_examples/comment-trees.org", "spec/html_examples/custom-seq-todo.html", "spec/html_examples/custom-seq-todo.org", "spec/html_examples/custom-todo.html", "spec/html_examples/custom-todo.org", "spec/html_examples/custom-typ-todo.html", "spec/html_examples/custom-typ-todo.org", "spec/html_examples/deflist.html", "spec/html_examples/deflist.org", "spec/html_examples/entities.html", "spec/html_examples/entities.org", "spec/html_examples/escape-pre.html", "spec/html_examples/escape-pre.org", "spec/html_examples/export-exclude-only.html", "spec/html_examples/export-exclude-only.org", "spec/html_examples/export-keywords.html", "spec/html_examples/export-keywords.org", "spec/html_examples/export-tags.html", "spec/html_examples/export-tags.org", "spec/html_examples/export-title.html", "spec/html_examples/export-title.org", "spec/html_examples/footnotes.html", "spec/html_examples/footnotes.org", "spec/html_examples/horizontal_rule.html", "spec/html_examples/horizontal_rule.org", "spec/html_examples/html-literal.html", "spec/html_examples/html-literal.org", "spec/html_examples/inline-formatting.html", "spec/html_examples/inline-formatting.org", "spec/html_examples/inline-images.html", "spec/html_examples/inline-images.org", "spec/html_examples/link-features.html", "spec/html_examples/link-features.org", "spec/html_examples/lists.html", "spec/html_examples/lists.org", "spec/html_examples/metadata-comment.html", "spec/html_examples/metadata-comment.org", "spec/html_examples/only-list.html", "spec/html_examples/only-list.org", "spec/html_examples/only-table.html", "spec/html_examples/only-table.org", "spec/html_examples/skip-header.html", "spec/html_examples/skip-header.org", "spec/html_examples/skip-table.html", "spec/html_examples/skip-table.org", "spec/html_examples/subsupscript-nil.html", "spec/html_examples/subsupscript-nil.org", "spec/html_examples/subsupscript.html", "spec/html_examples/subsupscript.org", "spec/html_examples/tables.html", "spec/html_examples/tables.org", "spec/html_examples/text.html", "spec/html_examples/text.org", "spec/line_spec.rb", "spec/output_buffer_spec.rb", "spec/parser_spec.rb", "spec/regexp_helper_spec.rb", "spec/spec_helper.rb", "spec/textile_examples/block_code.org", "spec/textile_examples/block_code.textile", "spec/textile_examples/blockquote.org", "spec/textile_examples/blockquote.textile", "spec/textile_examples/center.org", "spec/textile_examples/center.textile", "spec/textile_examples/footnotes.org", "spec/textile_examples/footnotes.textile", "spec/textile_examples/keywords.org", "spec/textile_examples/keywords.textile", "spec/textile_examples/links.org", "spec/textile_examples/links.textile", "spec/textile_examples/lists.org", "spec/textile_examples/lists.textile", "spec/textile_examples/single-space-plain-list.org", "spec/textile_examples/single-space-plain-list.textile", "spec/textile_examples/tables.org", "spec/textile_examples/tables.textile", "spec/textile_output_buffer_spec.rb", "tasks/test_case.rake", "test/test_orgmode_parser.rb", "util/gen-special-replace.el"]
  s.homepage = "http://github.com/bdewey/org-ruby"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "org-ruby"
  s.rubygems_version = "1.8.10"
  s.summary = "This gem contains Ruby routines for parsing org-mode files."
  s.test_files = ["test/test_orgmode_parser.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubypants>, [">= 0.2.0"])
      s.add_development_dependency(%q<bones>, [">= 3.8.0"])
    else
      s.add_dependency(%q<rubypants>, [">= 0.2.0"])
      s.add_dependency(%q<bones>, [">= 3.8.0"])
    end
  else
    s.add_dependency(%q<rubypants>, [">= 0.2.0"])
    s.add_dependency(%q<bones>, [">= 3.8.0"])
  end
end
