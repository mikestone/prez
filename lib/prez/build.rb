require "thor/actions"
require "thor/group"

module Prez
  class Build < Thor::Group
    include Thor::Actions
    include Prez::Builder
    argument :name, type: :string

    def check_file!
      if File.exists? name
        @filename = name
      elsif File.exists? "#{name}.prez"
        @filename = "#{name}.prez"
      else
        raise Prez::Error.new("Missing prez file '#{name}'")
      end

      if filename =~ /\.html$/
        raise Prez::Error.new("Prez file cannot be an html file: '#{name}'")
      end
    end

    def generate_html
      create_file html_filename, build_html(filename)
    end

    private

    def base_name
      filename.sub /\.prez$/, ""
    end

    def filename
      @filename
    end

    def html_filename
      "#{base_name}.html"
    end

    class << self
      def source_root
        File.absolute_path File.expand_path("../../../templates", __FILE__)
      end
    end
  end
end
