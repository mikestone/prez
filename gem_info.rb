lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "prez/version"

module Prez
  module Gem
    class << self
      def dependencies
        {
          sass: "~> 3.4",
          therubyracer: "~> 0.12",
          thor: "~> 0.19",
          uglifier: "~> 2.7"
        }
      end
    end
  end
end
