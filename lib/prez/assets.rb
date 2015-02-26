require "coffee-script"
require "prez/cache"
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

      def compiled_contents
        Prez::Cache.get "asset:#{extension}:compiled:#{file}", contents do
          compile contents
        end
      end

      def compile(contents)
        contents
      end

      def minified_contents
        Prez::Cache.get "asset:#{extension}:minified:#{file}", compiled_contents do
          minify compiled_contents
        end
      end

      def minify(contents)
        contents
      end

      def to_tag
        if dev? && !self_closing?
          "#{open}\n#{compiled_contents}#{close}"
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

        if options[:style]
          attributes << %{style="#{options[:style]}"}
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

      def compile(contents)
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

      def compile(contents)
        if file =~ /\.coffee$/
          CoffeeScript.compile contents
        else
          contents
        end
      end

      def minify(contents)
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

      def compile(contents)
        Sass::Engine.new(contents,
                         syntax: :scss,
                         style: :expanded,
                         load_paths: [File.dirname(file)]).render
      end

      def minify(contents)
        Sass::Engine.new(contents,
                         syntax: :scss,
                         style: :compressed,
                         load_paths: [File.dirname(file)]).render
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
