require "coffee-script"
require "prez/data_uri"
require "prez/error"
require "prez/files"
require "prez/sass_extensions"
require "sass"
require "uglifier"

module Prez
  module Assets
    class Tagged
      attr_reader :name, :contents, :file, :options

      def initialize(name, options = {})
        @name = name
        @contents = Prez::Files.contents name, extension
        @file = Prez::Files.find name, extension
        @options = options
      end

      def dev?
        options.fetch :dev, false
      end

      def self_closing?
        false
      end

      def minified_contents
        minify contents
      end

      def minify(contents)
        contents
      end

      def to_tag
        if dev? && !self_closing?
          "#{open}\n#{contents}#{close}"
        else
          "#{open}#{minified_contents.strip}#{close}"
        end
      end
    end

    class Image < Prez::Assets::Tagged
      def self_closing?
        true
      end

      def extension
        "image"
      end

      def open
        attributes = []

        if options[:width]
          attributes << %{width="#{options[:width]}"}
        end

        if options[:height]
          attributes << %{height="#{options[:height]}"}
        end

        %{<img #{attributes.join " "} src="}
      end

      def close
        %{" />}
      end

      def image_type
        extension = file[/\.([^.]*)$/, 1]

        case extension
        when "gif"
          "image/gif"
        when "jpeg", "jpg"
          "image/jpeg"
        when "png"
          "image/png"
        when "svg"
          "image/svg+xml"
        when "tif", "tiff"
          "image/tiff"
        else
          raise Prez::Error.new("Unknown image extension '#{extension}'")
        end
      end

      def minify(contents)
        Prez::DataUri.new(image_type, contents).to_s
      end
    end

    class Javascript < Prez::Assets::Tagged
      def extension
        "js"
      end

      def open
        %{<script type="text/javascript">}
      end

      def close
        %{</script>}
      end

      def minify(contents)
        contents = CoffeeScript.compile contents if file =~ /\.coffee$/
        Uglifier.compile contents
      end
    end

    class Stylesheet < Prez::Assets::Tagged
      def extension
        "css"
      end

      def open
        %{<style type="text/css">}
      end

      def close
        %{</style>}
      end

      def minify(contents)
        Sass::Engine.new(contents,
                         syntax: :scss,
                         style: :compressed,
                         load_paths: [File.expand_path("..", file)]).render
      end
    end

    class << self
      def image(name, options = {})
        Prez::Assets::Image.new(name, options).to_tag
      end

      def javascript(name, options = {})
        Prez::Assets::Javascript.new(name, options).to_tag
      end

      def stylesheet(name, options = {})
        Prez::Assets::Stylesheet.new(name, options).to_tag
      end
    end
  end
end
