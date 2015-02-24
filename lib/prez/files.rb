module Prez
  module Files
    class MissingError < StandardError
      def initialize(name, extension)
        super "Could not find file name '#{name}' with extension '#{extension}'"
      end
    end

    class Paths
      attr_reader :extension_alias, :extensions, :paths

      def initialize(extension_alias, extensions, dirname, options = {})
        @extension_alias = extension_alias
        @extensions = extensions
        @binary = options.fetch :binary, false

        @paths = [].tap do |paths|
          paths << File.expand_path(".")
          paths << File.expand_path(File.join(".", dirname))
          paths << File.expand_path(File.join("../../../vendor", dirname), __FILE__)
        end
      end

      def find(name)
        paths.each do |path|
          extensions.each do |extension|
            files = [File.join(path, "#{name}.#{extension}")]

            if name.end_with?(".#{extension}")
              files << File.join(path, name)
            end

            files.each do |file|
              if File.exists?(file)
                return file
              end
            end
          end
        end

        raise Prez::Files::MissingError.new(name, extension_alias)
      end

      def binary?
        @binary
      end
    end

    class << self
      SEARCH_PATHS = {
        "js" => Prez::Files::Paths.new("js", ["js.coffee", "coffee", "js"], "javascripts"),
        "css" => Prez::Files::Paths.new("css", ["css.scss", "scss", "css"], "stylesheets"),
        "font" => Prez::Files::Paths.new("font", ["eot", "svg", "ttf", "woff", "woff2"], "fonts", binary: true),
        "image" => Prez::Files::Paths.new("image", ["gif", "jpeg", "jpg", "png", "svg", "tif", "tiff"], "images", binary: true)
      }

      def contents(name, extension)
        file = find name, extension

        if SEARCH_PATHS[extension].binary?
          File.read file, mode: "rb"
        else
          File.read file
        end
      end

      def find(name, extension)
        unless SEARCH_PATHS[extension]
          raise Prez::Files::MissingError.new(name, extension)
        end

        SEARCH_PATHS[extension].find name
      end
    end
  end
end
