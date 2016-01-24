require "thor/actions"
require "thor/group"

module Prez
  class Build < Thor::Group
    include Thor::Actions
    include Prez::Builder
    argument :name, type: :string, required: false, default: nil

    def check_file!
      if File.exists? prez_name
        @filename = prez_name
      elsif File.exists? "#{prez_name}.prez"
        @filename = "#{prez_name}.prez"
      else
        raise Prez::Error.new("Missing prez file '#{prez_name}'")
      end

      if filename =~ /\.html$/
        raise Prez::Error.new("Prez file cannot be an html file: '#{prez_name}'")
      end
    end

    def generate_html
      create_file html_filename, build_html(filename)
    end

    private

    def prez_name
      @prez_name = name || only_existing_prez
    end

    def only_existing_prez
      results = Dir.glob "*.prez"

      if results.empty?
        raise Prez::Error.new("No .prez files found!")
      elsif results.size > 1
        raise Prez::Error.new("More than one .prez file found!\nPlease specify which one you want to build.")
      end

      results.first
    end

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
