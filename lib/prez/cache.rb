require "digest"
require "fileutils"
require "yaml"

module Prez
  class Cache
    DIR = ".prez-cache"

    attr_reader :toc

    def initialize
      unless File.directory?(dir)
        Dir.mkdir dir
      end

      if File.exists?(toc_file)
        @toc = YAML.load File.read(toc_file)
      else
        @toc = { prez_version: Prez::Version.to_s }
      end
    end

    def dir
      Prez::Cache::DIR
    end

    def toc_file
      File.join dir, "toc.yml"
    end

    def include?(key, hash)
      toc.include?(key) && File.file?(cached_path(key, hash))
    end

    def cached_path(key, hash)
      File.join dir, Prez::Cache.md5(key), hash
    end

    def get(key, hash)
      File.read cached_path(key, hash)
    ensure
      toc[key][:last_touched][hash] = Time.now
      save
    end

    def put(key, hash, contents)
      unless include?(key, hash)
        toc[key] = {
          last_touched: {},
          saved: {}
        }
      end

      path = cached_path key, hash

      unless File.directory?(File.dirname(path))
        FileUtils.makedirs File.dirname(path)
      end

      File.write path, contents
      toc[key][:key_hash] = Prez::Cache.md5 key
      toc[key][:last_touched][hash] = Time.now
      toc[key][:saved][hash] = Time.now
    ensure
      save
    end

    def save
      File.write toc_file, YAML.dump(toc)
    end

    class << self
      def get(key, pre_cache_contents)
        hash = md5 pre_cache_contents

        if instance.include?(key, hash)
          instance.get key, hash
        else
          yield.tap do |results|
            instance.put key, hash, results
          end
        end
      end

      def md5(contents)
        Digest::MD5.hexdigest contents
      end

      def instance
        @instance ||= Prez::Cache.new
      end
    end
  end
end
