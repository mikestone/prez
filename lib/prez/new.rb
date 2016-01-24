require "thor/actions"
require "thor/group"

module Prez
  class New < Thor::Group
    include Thor::Actions
    argument :name, type: :string

    def check_file!
      if File.exists? filename
        raise Prez::Error.new("There is already a presentation file named '#{filename}'")
      end
    end

    def generate_prez
      template "new.prez.tt", "#{name}.prez"
    end

    private

    def filename
      if name =~ /\.prez$/
        name
      else
        "#{name}.prez"
      end
    end

    class << self
      def source_root
        File.absolute_path File.expand_path("../../../templates", __FILE__)
      end
    end
  end
end
