require "bundler/gem_tasks"
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "prez/version"

module Prez
  module Gem
    class << self
      def dependencies
        {
          thor: "~> 0.19"
        }
      end
    end
  end
end

task :generate do
  puts "Generating bin/prez"
  File.write File.expand_path("../bin/prez", __FILE__), %{#!/usr/bin/env ruby
require "rubygems"
gem "prez", "= #{Prez::Version}"
gem "thor", "#{Prez::Gem.dependencies[:thor]}"
require "prez"
Prez::CLI.start
}
end
