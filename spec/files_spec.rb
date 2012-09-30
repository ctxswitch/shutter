require File.dirname(__FILE__) + '/spec_helper'
require 'fileutils'

describe "Shutter::Files" do
  it "should create the configuration directory if it does not exist" do
    Shutter::Files.create_config_dir('./tmp/configs')
    File.directory?('./tmp/configs').should == true
    FileUtils.rm_rf('./tmp/configs')
  end

  it "should not recursively create the configuration directory if the parent does not exist" do
    expect { Shutter::Files.create_config_dir('./tmp/configs/this') }.to raise_error
  end

  it "should include the templates for all files" do
    Shutter::Files::CONFIG_FILES.each do |name|
      Shutter::Files.constants.include?(:"#{name.upcase.gsub(/\./, "_")}").should == true
    end
  end
end