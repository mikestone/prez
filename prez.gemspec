# coding: utf-8
require "rubygems/package_task"
require_relative "gem_info.rb"

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

  spec.add_dependency "coffee-script", Prez::Gem.dependencies[:coffee_script]
  spec.add_dependency "sass", Prez::Gem.dependencies[:sass]
  spec.add_dependency "therubyracer", Prez::Gem.dependencies[:therubyracer]
  spec.add_dependency "thor", Prez::Gem.dependencies[:thor]
  spec.add_dependency "uglifier", Prez::Gem.dependencies[:uglifier]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
