
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'org-ruby'

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  readme_file 'README.rdoc'
  name  'org-ruby'
  authors  'Brian Dewey'
  email  'bdewey@gmail.com'
  url  'http://github.com/bdewey/org-ruby'
  version  OrgRuby::VERSION
  colorize false                # Windows consoles won't colorize
  gem.need_tar false            # Can't TAR from Windows
  depend_on 'rubypants'
  spec.opts ['-D', '--color']
}


# EOF
