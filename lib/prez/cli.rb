require "prez/build"
require "prez/new"
require "prez/start"
require "prez/version"
require "thor"

module Prez
  class CLI < Thor
    register Prez::Build, "build", "build NAME", "Builds the single html presentation from the prez file"
    register Prez::New, "new", "new NAME", "Generates a new presentation"
    register Prez::Start, "start", "start NAME", "Launches your browser with the given presentation"

    map "-v" => "version"

    desc "version", "Show the prez version"
    long_desc "
      This can be optionally used as 'prez -v'"
    def version
      say Prez::Version
    end

    class << self
      def exit_on_failure?
        true
      end
    end
  end
end
