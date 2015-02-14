require "prez/files"
require "thor/actions"
require "thor/group"

module Prez
  class Build < Thor::Group
    include Thor::Actions
    argument :name, type: :string

    def check_file!
      if File.exists? name
        @filename = name
      elsif File.exists? "#{name}.prez"
        @filename = "#{name}.prez"
      else
        raise Thor::Error.new(set_color("Missing prez file '#{name}'", :red, :bold))
      end

      if filename =~ /\.html$/
        raise Thor::Error.new(set_color("Prez file cannot be html file: '#{name}'", :red, :bold))
      end
    end

    def generate_html
      template filename, html_filename
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

    def javascript(name)
      %{<script type="text/javascript">\n#{Prez::Files.contents name, "js"}</script>}
    rescue Prez::Files::MissingError
      raise Thor::Error.new(set_color("Could not find file: '#{name}.js'", :red, :bold))
    end

    def stylesheet(name)
      %{<style type="text/css">\n#{Prez::Files.contents name, "css"}</style>}
    rescue Prez::Files::MissingError
      raise Thor::Error.new(set_color("Could not find file: '#{name}.css'", :red, :bold))
    end

    class << self
      def source_root
        File.expand_path "."
      end
    end
  end
end
