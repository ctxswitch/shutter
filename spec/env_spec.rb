require File.dirname(__FILE__) + '/spec_helper'

describe "Environment Sanity Check" do
  it "should have the SHUTTER_CONFIG variable set to ./tmp" do
    ENV['SHUTTER_CONFIG'].should == "./tmp"
  end

  it "should have the SHUTTER_PERSIST_FILE variable set to ./tmp/iptables" do
    ENV['SHUTTER_PERSIST_FILE'].should == "./tmp/iptables"
  end

  it "should be able to write to ./tmp" do
    File.open("./tmp/test", "w") { |f| f.write("Foo") }
    IO.read("./tmp/test").should == "Foo"
    File.unlink("./tmp/test")
  end
end