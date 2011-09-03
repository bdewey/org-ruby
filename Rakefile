
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'org-ruby'

task :default => 'spec:run'
task 'gem:release' => 'spec:run'

Bones {
  readme_file 'README.rdoc'
  name  'org-ruby'
  authors  'Brian Dewey'
  email  'bdewey@gmail.com'
  url  'http://github.com/bdewey/org-ruby'
  version  OrgRuby::VERSION
  depend_on 'rubypants'
  spec.opts ['--color']
}


# EOF
