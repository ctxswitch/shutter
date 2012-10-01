require File.dirname(__FILE__) + '/spec_helper'

describe "Shutter::CommandLine" do
  before(:each) do
    FileUtils.mkdir("./tmp")
    Shutter::Files.create("./tmp")
    @cmd = Shutter::CommandLine.new("./tmp")
  end

  after(:each) do
    FileUtils.rm Dir.glob('./tmp/*')
    FileUtils.rmdir("./tmp")
  end

  it "should not raise exception when firewall is called" do
    expect { @cmd.firewall }.to_not raise_error
  end

  it "should set default value of persist to false" do
    @cmd.persist.should == false
  end

  it "should set default value of debug to false" do
    @cmd.debug.should == false
  end

  it "should have set config_path to ./tmp" do
    @cmd.config_path.should == "./tmp"
  end

  it "should set the command to :save" do
    @cmd.execute(["--save"],true)
    @cmd.command.should == :save
    @cmd.execute(["-s"],true)
    @cmd.command.should == :save
  end

  it "should set the command to :restore" do
    @cmd.execute(["--restore"],true)
    @cmd.command.should == :restore
    @cmd.execute(["--restore", "--persist"],true)
    @cmd.command.should == :restore
    @cmd.persist.should == true
  end

  it "should set the command to :init" do
    @cmd.execute(["--init"],true)
    @cmd.command.should == :init
  end

  it "should set the command to :reinit" do
    @cmd.execute(["--reinit"],true)
    @cmd.command.should == :reinit
  end

  it "should set the command to :upgrade" do
    @cmd.execute(["--upgrade"],true)
    @cmd.command.should == :upgrade
  end

  it "should set the config path and persist" do
    @cmd.os.stubs(:version).returns("Unknown")
    @cmd.execute(["--dir", "./tmp", "--restore", "--persist"],true)
    @cmd.command.should == :restore
    @cmd.persist.should == true
    @cmd.persist_file.should == "/tmp/iptables.rules"
    @cmd.config_path.should == "./tmp"
    @cmd.execute(["-d", "./tmp", "--restore", "--persist"],true)
    @cmd.command.should == :restore
    @cmd.persist.should == true
    @cmd.persist_file.should == "/tmp/iptables.rules"
    @cmd.config_path.should == "./tmp"
  end

  it "should set the config path and persist with file" do
    @cmd.os.stubs(:version).returns("Unknown")
    @cmd.execute(["--dir", "./tmp", "--restore", "--persist", "./tmp/persistance.file"],true)
    @cmd.command.should == :restore
    @cmd.persist.should == true
    @cmd.persist_file.should == "./tmp/persistance.file"
    @cmd.config_path.should == "./tmp"
    @cmd.execute(["-d", "./tmp", "--restore", "--persist", "./tmp/persistance.file"],true)
    @cmd.command.should == :restore
    @cmd.persist.should == true
    @cmd.persist_file.should == "./tmp/persistance.file"
    @cmd.config_path.should == "./tmp"
  end

end