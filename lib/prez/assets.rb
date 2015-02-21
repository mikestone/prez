require "coffee-script"
require "prez/files"
require "sass"
require "uglifier"

module Prez
  module Assets
    class Tagged
      attr_reader :name, :contents, :file

      def initialize(name, options = {})
        @name = name
        @contents = Prez::Files.contents name, extension
        @file = Prez::Files.find name, extension
        @dev = options.fetch :dev, false
      end

      def dev?
        @dev
      end

      def minified_contents
        minify contents
      end

      def minify(contents)
        contents
      end

      def to_tag
        if dev?
          "#{open}\n#{contents}#{close}"
        else
          "#{open}#{minified_contents.strip}#{close}"
        end
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
      def javascript(name, options = {})
        Prez::Assets::Javascript.new(name, options).to_tag
      end

      def stylesheet(name, options = {})
        Prez::Assets::Stylesheet.new(name, options).to_tag
      end
    end
  end
end
