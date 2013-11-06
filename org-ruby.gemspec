# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "org-ruby"
  s.version = "0.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Dewey"]
  s.date = Time.now.strftime("%Y-%m-%d")
  s.description = "An org-mode parser written in Ruby. This gem contains Ruby routines for parsing org-mode files.The most\nsignificant thing this library does today is convert org-mode files to\nHTML or textile. Currently, you cannot do much to customize the\nconversion. The supplied textile conversion is optimized for\nextracting \"content\" from the orgfile as opposed to \"metadata.\" "
  s.email = "bdewey@gmail.com"
  s.executables = ["org-ruby"]
  s.extra_rdoc_files = ["History.txt", "README.rdoc", "bin/org-ruby"]
  s.files = ["History.txt", "README.rdoc", "bin/org-ruby", "lib/org-ruby.rb", "lib/org-ruby/headline.rb", "lib/org-ruby/html_output_buffer.rb", "lib/org-ruby/html_symbol_replace.rb", "lib/org-ruby/line.rb", "lib/org-ruby/output_buffer.rb", "lib/org-ruby/parser.rb", "lib/org-ruby/regexp_helper.rb", "lib/org-ruby/textile_output_buffer.rb", "lib/org-ruby/textile_symbol_replace.rb", "lib/org-ruby/tilt.rb"]
  s.homepage = "http://github.com/bdewey/org-ruby"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "org-ruby"
  s.rubygems_version = "1.8.10"
  s.summary = "This gem contains Ruby routines for parsing org-mode files."
  s.license = "MIT"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubypants>, [">= 0.2.0"])
    else
      s.add_dependency(%q<rubypants>, [">= 0.2.0"])
    end
  else
    s.add_dependency(%q<rubypants>, [">= 0.2.0"])
  end
end
