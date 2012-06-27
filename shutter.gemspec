# -*- encoding: utf-8 -*-
require File.expand_path('../lib/shutter/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rob Lyon"]
  gem.email         = ["nosignsoflifehere@gmail.com"]
  gem.description   = %q{Shutter is a tool that gives system administrators the ability 
                         to manage iptables firewall settings through simple lists instead 
                         of complex iptables rules. Please note: This application currently 
                         only works with Red Hat based distributions, as the need arrises 
                         more distributions will be added.
                        }
  gem.summary       = %q{Shutter helps manage iptables firewalls}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "shutter"
  gem.require_paths = ["lib"]
  gem.version       = Shutter::VERSION
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('mocha')
end
