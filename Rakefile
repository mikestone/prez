require "bundler/gem_tasks"
require_relative "gem_info.rb"

task :generate do
  puts "Generating bin/prez"
  File.write File.expand_path("../bin/prez", __FILE__), %{#!/usr/bin/env ruby
require "rubygems"
gem "prez", "= #{Prez::Version}"
gem "sass", "#{Prez::Gem.dependencies[:sass]}"
gem "therubyracer", "#{Prez::Gem.dependencies[:therubyracer]}"
gem "thor", "#{Prez::Gem.dependencies[:thor]}"
gem "uglifier", "#{Prez::Gem.dependencies[:uglifier]}"
require "prez/cli"
Prez::CLI.start
}
end
