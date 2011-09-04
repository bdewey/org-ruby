# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{org-ruby}
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Brian Dewey}]
  s.date = %q{2011-09-03}
  s.description = %q{This gem contains Ruby routines for parsing org-mode files.The most
significant thing this library does today is convert org-mode files to
HTML or textile. Currently, you cannot do much to customize the
conversion. The supplied textile conversion is optimized for
extracting "content" from the orgfile as opposed to "metadata." }
  s.email = %q{bdewey@gmail.com}
  s.executables = [%q{org-ruby}]
  s.extra_rdoc_files = [%q{History.txt}, %q{README.rdoc}, %q{bin/org-ruby}]
  s.files = [%q{.bnsignore}, %q{History.txt}, %q{README.rdoc}, %q{Rakefile}, %q{TAGS}, %q{bin/org-ruby}, %q{lib/org-ruby.rb}, %q{lib/org-ruby/headline.rb}, %q{lib/org-ruby/html_output_buffer.rb}, %q{lib/org-ruby/html_symbol_replace.rb}, %q{lib/org-ruby/line.rb}, %q{lib/org-ruby/output_buffer.rb}, %q{lib/org-ruby/parser.rb}, %q{lib/org-ruby/regexp_helper.rb}, %q{lib/org-ruby/textile_output_buffer.rb}, %q{lib/org-ruby/textile_symbol_replace.rb}, %q{spec/data/freeform-example.org}, %q{spec/data/freeform.org}, %q{spec/data/hyp-planning.org}, %q{spec/data/remember.org}, %q{spec/headline_spec.rb}, %q{spec/html_examples/advanced-code.html}, %q{spec/html_examples/advanced-code.org}, %q{spec/html_examples/advanced-lists.html}, %q{spec/html_examples/advanced-lists.org}, %q{spec/html_examples/block_code.html}, %q{spec/html_examples/block_code.org}, %q{spec/html_examples/blockcomment.html}, %q{spec/html_examples/blockcomment.org}, %q{spec/html_examples/blockquote.html}, %q{spec/html_examples/blockquote.org}, %q{spec/html_examples/center.html}, %q{spec/html_examples/center.org}, %q{spec/html_examples/code-comment.html}, %q{spec/html_examples/code-comment.org}, %q{spec/html_examples/custom-seq-todo.html}, %q{spec/html_examples/custom-seq-todo.org}, %q{spec/html_examples/custom-todo.html}, %q{spec/html_examples/custom-todo.org}, %q{spec/html_examples/custom-typ-todo.html}, %q{spec/html_examples/custom-typ-todo.org}, %q{spec/html_examples/deflist.html}, %q{spec/html_examples/deflist.org}, %q{spec/html_examples/entities.html}, %q{spec/html_examples/entities.org}, %q{spec/html_examples/escape-pre.html}, %q{spec/html_examples/escape-pre.org}, %q{spec/html_examples/export-exclude-only.html}, %q{spec/html_examples/export-exclude-only.org}, %q{spec/html_examples/export-keywords.html}, %q{spec/html_examples/export-keywords.org}, %q{spec/html_examples/export-tags.html}, %q{spec/html_examples/export-tags.org}, %q{spec/html_examples/export-title.html}, %q{spec/html_examples/export-title.org}, %q{spec/html_examples/footnotes.html}, %q{spec/html_examples/footnotes.org}, %q{spec/html_examples/html-literal.html}, %q{spec/html_examples/html-literal.org}, %q{spec/html_examples/inline-formatting.html}, %q{spec/html_examples/inline-formatting.org}, %q{spec/html_examples/inline-images.html}, %q{spec/html_examples/inline-images.org}, %q{spec/html_examples/link-features.html}, %q{spec/html_examples/link-features.org}, %q{spec/html_examples/lists.html}, %q{spec/html_examples/lists.org}, %q{spec/html_examples/metadata-comment.html}, %q{spec/html_examples/metadata-comment.org}, %q{spec/html_examples/only-list.html}, %q{spec/html_examples/only-list.org}, %q{spec/html_examples/only-table.html}, %q{spec/html_examples/only-table.org}, %q{spec/html_examples/skip-header.html}, %q{spec/html_examples/skip-header.org}, %q{spec/html_examples/skip-table.html}, %q{spec/html_examples/skip-table.org}, %q{spec/html_examples/subsupscript-nil.html}, %q{spec/html_examples/subsupscript-nil.org}, %q{spec/html_examples/subsupscript.html}, %q{spec/html_examples/subsupscript.org}, %q{spec/html_examples/tables.html}, %q{spec/html_examples/tables.org}, %q{spec/html_examples/text.html}, %q{spec/html_examples/text.org}, %q{spec/line_spec.rb}, %q{spec/output_buffer_spec.rb}, %q{spec/parser_spec.rb}, %q{spec/regexp_helper_spec.rb}, %q{spec/spec_helper.rb}, %q{spec/textile_examples/block_code.org}, %q{spec/textile_examples/block_code.textile}, %q{spec/textile_examples/blockquote.org}, %q{spec/textile_examples/blockquote.textile}, %q{spec/textile_examples/center.org}, %q{spec/textile_examples/center.textile}, %q{spec/textile_examples/footnotes.org}, %q{spec/textile_examples/footnotes.textile}, %q{spec/textile_examples/keywords.org}, %q{spec/textile_examples/keywords.textile}, %q{spec/textile_examples/links.org}, %q{spec/textile_examples/links.textile}, %q{spec/textile_examples/lists.org}, %q{spec/textile_examples/lists.textile}, %q{spec/textile_examples/single-space-plain-list.org}, %q{spec/textile_examples/single-space-plain-list.textile}, %q{spec/textile_examples/tables.org}, %q{spec/textile_examples/tables.textile}, %q{spec/textile_output_buffer_spec.rb}, %q{tasks/test_case.rake}, %q{test/test_orgmode_parser.rb}, %q{util/gen-special-replace.el}]
  s.homepage = %q{http://github.com/bdewey/org-ruby}
  s.rdoc_options = [%q{--main}, %q{README.rdoc}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{org-ruby}
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{This gem contains Ruby routines for parsing org-mode files.}
  s.test_files = [%q{test/test_orgmode_parser.rb}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubypants>, [">= 0.2.0"])
      s.add_development_dependency(%q<bones>, [">= 3.7.1"])
    else
      s.add_dependency(%q<rubypants>, [">= 0.2.0"])
      s.add_dependency(%q<bones>, [">= 3.7.1"])
    end
  else
    s.add_dependency(%q<rubypants>, [">= 0.2.0"])
    s.add_dependency(%q<bones>, [">= 3.7.1"])
  end
end
