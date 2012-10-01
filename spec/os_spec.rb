require File.dirname(__FILE__) + '/spec_helper'

describe "Shutter::OS" do
  before(:each) do
    @os = Shutter::OS.new
  end

  it "should have the correct data for redhat systems" do
    @os.stubs(:version).returns("Red Hat")
    @os.persist_file.should == "/etc/sysconfig/iptables"
    @os.dist.should == "RedHat"
    @os.redhat?.should == true
    @os.centos?.should == true
    @os.fedora?.should == true
  end

  it "should have the correct data for ubuntu systems" do
    @os.stubs(:version).returns("Ubuntu")
    @os.persist_file.should == "/etc/iptables/rules"
    @os.dist.should == "Ubuntu"
    @os.redhat?.should == false
    @os.centos?.should == false
    @os.fedora?.should == false
  end

  it "should have the correct data for debian systems" do
    @os.stubs(:version).returns("Debian")
    @os.persist_file.should == "/etc/iptables/rules"
    @os.dist.should == "Debian"
    @os.redhat?.should == false
    @os.centos?.should == false
    @os.fedora?.should == false
  end

  it "should have the correct data for debian systems" do
    @os.stubs(:version).returns("Unknown")
    @os.persist_file.should == "/tmp/iptables.rules"
    @os.dist.should == "Unknown"
    @os.redhat?.should == false
    @os.centos?.should == false
    @os.fedora?.should == false
  end

  it "should not validate any os except redhat" do
    @os.stubs(:version).returns("Unknown")
    expect { @os.validate! }.to raise_error
    @os.stubs(:version).returns("Ubuntu")
    expect { @os.validate! }.to_not raise_error
    @os.stubs(:version).returns("Debian")
    expect { @os.validate! }.to_not raise_error
    @os.stubs(:version).returns("Red Hat")
    expect { @os.validate! }.to_not raise_error
  end
end