
begin
  require 'rubygems'
rescue LoadError
  abort '### Can\'t find "rubygems"??? ###'
end

begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem with "gem install bones". ###'
end

begin
  require 'rubypants'
rescue LoadError
  abort '### Please install the "rubypants" gem with "gem install rubypants". ###'
end

ensure_in_path 'lib'
require 'org-ruby'

begin
  require 'rspec/core'
  require 'rspec/core/rake_task'
rescue LoadError
  abort '### Please install the "rspec" gem with "gem install rspec". ###'
end

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
