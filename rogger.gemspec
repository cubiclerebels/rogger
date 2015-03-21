# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rogger/version'

Gem::Specification.new do |spec|
  spec.name          = "rogger"
  spec.version       = Rogger::VERSION
  spec.authors       = ["Lau Siaw Young"]
  spec.email         = ["lausiawyoung@gmail.com"]
  spec.summary       = ""
  spec.description   = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "rails", ">= 4.0.0"
  spec.add_dependency "gelf", "~> 1.4.0"
  spec.add_dependency "lograge", "=0.3.1"
end
