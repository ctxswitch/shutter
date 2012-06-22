require File.dirname(__FILE__) + '/spec_helper'

describe "Shutter" do
  it "should have templates for all files" do
    Shutter::CONFIG_FILES.each do |name|
      Shutter.constants.include?(:"#{name.upcase.gsub(/\./, "_")}").should == true
    end
  end
end
