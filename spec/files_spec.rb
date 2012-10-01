require File.dirname(__FILE__) + '/spec_helper'
require 'fileutils'

describe "Shutter::Files" do
  before(:each) do
    FileUtils.mkdir("./tmp")
    @cmd = Shutter::CommandLine.new("./tmp")
  end

  after(:each) do
    FileUtils.rm Dir.glob('./tmp/*')
    FileUtils.rmdir("./tmp")
  end

  it "should create the configuration directory if it does not exist" do
    Shutter::Files.create_config_dir('./tmp/configs')
    File.directory?('./tmp/configs').should == true
    FileUtils.rm_rf('./tmp/configs')
  end

  it "should not recursively create the configuration directory if the parent does not exist" do
    expect { Shutter::Files.create_config_dir('./tmp/configs/this') }.to raise_error
  end

  # it "should include the templates for all files" do
  #   Shutter::Files::CONFIG_FILES.each do |name|
  #     Shutter::Files.const_defined?(:"#{name.upcase.gsub(/\./, "_")}").should == true
  #   end
  # end

  it "should create the files in the configuration directory if they do not exist" do
    Shutter::Files.create_config_dir('./spec/tmp')
    Shutter::Files.create('./spec/tmp')
    Shutter::Files::CONFIG_FILES.each do |name|
      File.exists?("./spec/tmp/#{name}")
      File.read("./spec/tmp/#{name}").should == Shutter::Files.const_get(:"#{name.upcase.gsub(/\./, "_")}")
    end
    FileUtils.rm_rf('./spec/tmp')
  end

  it "should not touch the configs when they already exist" do
    Shutter::Files.create_config_dir('./spec/tmp')
    Shutter::Files::CONFIG_FILES.each do |name|
      FileUtils.copy("./spec/files/#{name}", "./spec/tmp/#{name}")
    end
    Shutter::Files.create('./spec/tmp')
    Shutter::Files::CONFIG_FILES.each do |name|
      File.exists?("./spec/tmp/#{name}")
      unless name == "base.ipt"
        File.read("./spec/tmp/#{name}").should_not == Shutter::Files.const_get(:"#{name.upcase.gsub(/\./, "_")}")
      end
    end
    FileUtils.rm_rf('./spec/tmp')
  end

  it "should overwrite the configs when overwrite is specified" do
    Shutter::Files.create_config_dir('./spec/tmp')
    Shutter::Files::CONFIG_FILES.each do |name|
      FileUtils.copy("./spec/files/#{name}", "./spec/tmp/#{name}")
    end
    Shutter::Files.create('./spec/tmp',true)
    Shutter::Files::CONFIG_FILES.each do |name|
      File.exists?("./spec/tmp/#{name}")
      File.read("./spec/tmp/#{name}").should == Shutter::Files.const_get(:"#{name.upcase.gsub(/\./, "_")}")
    end
    FileUtils.rm_rf('./spec/tmp')
  end

  it "should overwrite the configs when overwrite false but there are exceptions" do
    Shutter::Files.create_config_dir('./spec/tmp')
    Shutter::Files::CONFIG_FILES.each do |name|
      FileUtils.copy("./spec/files/#{name}", "./spec/tmp/#{name}")
    end
    except = ['iface.forward','base.ipt']
    Shutter::Files.create('./spec/tmp',false,except)
    Shutter::Files::CONFIG_FILES.each do |name|
      File.exists?("./spec/tmp/#{name}")
      unless except.include?(name)
        File.read("./spec/tmp/#{name}").should_not == Shutter::Files.const_get(:"#{name.upcase.gsub(/\./, "_")}")
      else
        File.read("./spec/tmp/#{name}").should == Shutter::Files.const_get(:"#{name.upcase.gsub(/\./, "_")}")
      end
    end
    FileUtils.rm_rf('./spec/tmp')
  end
end