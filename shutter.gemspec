# -*- encoding: utf-8 -*-
require File.expand_path('../lib/shutter/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rob Lyon"]
  gem.email         = ["nosignsoflifehere@gmail.com"]
  gem.description   = %q{Shutter helps maintain firewalls}
  gem.summary       = %q{Shutter helps maintain firewalls}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "shutter"
  gem.require_paths = ["lib"]
  gem.version       = Shutter::VERSION
end
