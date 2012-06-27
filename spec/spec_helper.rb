require 'rubygems'
require 'bundler/setup'
require 'shutter'

RSpec.configure do |config|
  config.mock_with :mocha
end

ENV['SHUTTER_CONFIG'] = "./tmp"
ENV['SHUTTER_PERSIST_FILE'] = "./tmp/iptables"
ENV['SHUTTER_MODE'] = "testing"