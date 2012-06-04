# -*- encoding: utf-8 -*-
require File.expand_path('../lib/zipfian/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Junegunn Choi"]
  gem.email         = ["junegunn.c@gmail.com"]
  gem.description   = %q{Zipfian distribution}
  gem.summary       = %q{Zipfian distribution}
  gem.homepage      = "https://github.com/junegunn/zipfian"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "zipfian"
  gem.require_paths = ["lib"]
  gem.version       = Zipfian::VERSION

  gem.add_development_dependency 'test-unit'
  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-test'
  gem.add_development_dependency 'parallelize'
end
