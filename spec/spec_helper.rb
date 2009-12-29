
require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. lib org-ruby]))


RememberFile = File.join(File.dirname(__FILE__), %w[data remember.org])
FreeformFile = File.join(File.dirname(__FILE__), %w[data freeform.org])
FreeformExampleFile = File.join(File.dirname(__FILE__), %w[data freeform-example.org])


Spec::Runner.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

