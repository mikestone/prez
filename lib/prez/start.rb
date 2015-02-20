require "launchy"
require "prez/builder"
require "prez/error"
require "thor/actions"
require "thor/group"
require "webrick"

module Prez
  class Start < Thor::Group
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
      say "Generating html..."
      @html = build_html filename
    end

    def start_server
      say "Starting server..."
      server = WEBrick::HTTPServer.new Port: 0, Logger: Prez::Start::NoopLog.new, AccessLog: []
      port = server.config[:Port]

      server.mount_proc "/" do |request, response|
        response.body = @html
        server.stop
      end

      begin
        Launchy.open "http://localhost:#{port}/"
        server.start
      ensure
        server.shutdown
      end
    end

    private

    def filename
      @filename
    end

    class << self
      def source_root
        File.absolute_path File.expand_path("../../../templates", __FILE__)
      end
    end

    class NoopLog < WEBrick::BasicLog
      def initialize
        @level = INFO
      end
    end
  end
end
