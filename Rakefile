
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'orgmode_parser'

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name  'orgmode_parser'
  authors  'Brian Dewey'
  email  'bdewey@gmail.com'
  url  'http://bdewey.com'
  version  OrgmodeParser::VERSION
}

# EOF
