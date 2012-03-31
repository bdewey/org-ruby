require 'bones'
ensure_in_path 'lib'
require 'org-ruby'

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => 'spec'
task 'gem:release' => 'spec'

Bones {
  readme_file 'README.rdoc'
  name  'org-ruby'
  authors  'Brian Dewey'
  email  'bdewey@gmail.com'
  url  'http://github.com/bdewey/org-ruby'
  version  OrgRuby::VERSION
  depend_on 'rubypants'
}


# EOF
