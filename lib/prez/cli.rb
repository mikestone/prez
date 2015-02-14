require "thor"

module Prez
  class CLI < Thor
    include Thor::Actions

    desc "new NAME", "Generates a new presentation"
    def new(name)
      template "new.prez", "#{name}.prez"
    end

    class << self
      def source_root
        File.absolute_path File.expand_path("../../../templates", __FILE__)
      end
    end
  end
end
