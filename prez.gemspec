# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "prez/version"
require "rubygems/package_task"

Gem::Specification.new do |spec|
  spec.name          = "prez"
  spec.version       = Prez::Version.to_s
  spec.authors       = ["Mike Virata-Stone"]
  spec.email         = ["mike@virata-stone.com"]
  spec.summary       = "Create simple single file presentations"
  spec.description   = "Gem to aid in the creation of single file HTML presentations."
  spec.homepage      = "https://github.com/mikestone/prez"
  spec.license       = "MIT"

  spec.files         = FileList["bin/**/*", "lib/**/*", "templates/**/*", "vendor/**/*"]
  spec.executables   = ["prez"]
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.19"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
