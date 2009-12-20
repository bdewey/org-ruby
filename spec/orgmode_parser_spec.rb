
require File.join(File.dirname(__FILE__), %w[spec_helper])

describe OrgmodeParser do
  it "should open ORG files" do
    parser = OrgmodeParser.new("foo.org")
  end
end

