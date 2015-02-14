module Prez
  module Files
    class MissingError < StandardError
      def initialize(name, extension)
        super "Could not find file name '#{name}' with extension '#{extension}'"
      end
    end

    class Paths
      attr_reader :extension, :paths

      def initialize(extension, dirname)
        @extension = extension

        @paths = [].tap do |paths|
          paths << File.expand_path(".")
          paths << File.expand_path(File.join(".", dirname))
          paths << File.expand_path(File.join("../../../vendor", dirname), __FILE__)
        end
      end

      def find(name)
        paths.each do |path|
          file = File.join path, "#{name}.#{extension}"

          if File.exists?(file)
            return file
          end
        end

        raise Prez::Files::MissingError.new(name, extension)
      end
    end

    class << self
      SEARCH_PATHS = {
        "js" => Prez::Files::Paths.new("js", "javascripts"),
        "css" => Prez::Files::Paths.new("css", "stylesheets")
      }

      def contents(name, extension)
        file = find name, extension
        File.read file
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
