require File.dirname(__FILE__) + '/spec_helper'
require 'fileutils'

describe "Shutter::CommandLine" do
  it "should create the configuration directory if it does not exist" do
    cmd = Shutter::CommandLine.new('./tmp/configs')
    cmd.init
    File.directory?('./tmp/configs').should == true
    FileUtils.rm_rf('./tmp/configs')
  end

  it "should not recursively create the configuration directory if the parent does not exist" do
    cmd = Shutter::CommandLine.new('./tmp/configs/this')
    expect { cmd.init }.to raise_error
  end
end