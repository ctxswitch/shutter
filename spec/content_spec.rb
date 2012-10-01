require File.dirname(__FILE__) + '/spec_helper'

describe "Shutter" do
  it "should have templates for all files" do
    Shutter::Content::CONFIG_FILES.each do |name|
      Shutter::Content.const_defined?(:"#{name.upcase.gsub(/\./, "_")}").should == true
    end
  end
end
