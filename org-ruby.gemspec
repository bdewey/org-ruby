# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "org-ruby/version"

Gem::Specification.new do |s|
  s.name        = "org-ruby"
  s.version     = Org::Ruby::VERSION
  s.authors     = ["niku"]
  s.email       = ["niku@niku.name"]
  s.homepage    = ""
  s.summary     = %q{Ruby routines for parsing org-mode}
  s.description = %q{This gem contains Ruby routines for parsing org-mode files.The most significant thing this library does today is convert org-mode files to
HTML or textile. Currently, you cannot do much to customize the conversion. The supplied textile conversion is optimized for extracting "content" from the orgfile as opposed to "metadata."}

  s.rubyforge_project = "org-ruby"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bones"
  s.add_development_dependency "rubypants"
end
