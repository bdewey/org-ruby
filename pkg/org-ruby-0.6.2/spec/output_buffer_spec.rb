require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Orgmode::OutputBuffer do

  it "computes outline level numbering" do
    output_buffer = Orgmode::OutputBuffer.new ""
    output_buffer.get_next_headline_number(1).should eql("1")
    output_buffer.get_next_headline_number(1).should eql("2")
    output_buffer.get_next_headline_number(1).should eql("3")
    output_buffer.get_next_headline_number(1).should eql("4")
    output_buffer.get_next_headline_number(2).should eql("4.1")
    output_buffer.get_next_headline_number(2).should eql("4.2")
    output_buffer.get_next_headline_number(1).should eql("5")
    output_buffer.get_next_headline_number(2).should eql("5.1")
    output_buffer.get_next_headline_number(2).should eql("5.2")
    output_buffer.get_next_headline_number(4).should eql("5.2.0.1")
  end

end
