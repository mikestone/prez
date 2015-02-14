require "prez/build"
require "prez/version"
require "thor"
require "thor/actions"

module Prez
  class CLI < Thor
    include Thor::Actions
    register Prez::Build, "build", "build NAME", "Builds the single html presentation from the prez file"

    map "-v" => "version"

    desc "new NAME", "Generates a new presentation"
    def new(name)
      template "new.prez.tt", "#{name}.prez"
    end

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

      def source_root
        File.absolute_path File.expand_path("../../../templates", __FILE__)
      end
    end
  end
end
