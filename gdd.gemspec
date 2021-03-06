# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gdd/version'

Gem::Specification.new do |spec|
  spec.name          = "gdd"
  spec.version       = Gdd::VERSION
  spec.authors       = ["Leo"]
  spec.email         = ["leonid.inbox@gmail.com"]
  spec.description   = %q{Google Driven Development}
  spec.summary       = %q{Google Driven Development}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'thor'
  spec.add_dependency 'active_support'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'classifier'
  spec.add_dependency 'phantomjs-poltergeist'
end
