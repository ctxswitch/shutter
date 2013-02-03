if ENV['COVERAGE'] == "true"
  require 'simplecov'
  FILTER_DIRS = ['spec']
 
  SimpleCov.start do
    FILTER_DIRS.each{ |f| add_filter f }
  end
end

require 'rubygems'
require 'bundler/setup'
require 'mocha/api'
require 'shutter'

RSpec.configure do |config|
  config.mock_with :mocha
end
