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
    class_option :server, type: :boolean, desc: "Keep the server up for dynamic refreshes"

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
      return if options[:server]
      @html = build_html filename
    end

    def start_server
      say "Starting server..."
      @server = WEBrick::HTTPServer.new Port: 0, Logger: Prez::Start::NoopLog.new, AccessLog: []
      port = @server.config[:Port]

      if options[:server]
        ["INT", "TERM"].each do |signal|
          trap signal do
            stop_server
          end
        end
      end

      @server.mount_proc "/" do |request, response|
        if request.path == "/"
          response.body = html

          unless options[:server]
            @server.stop
          end
        else
          say "Ignoring reuest: #{request.path}"
          response.status = 404
        end
      end

      begin
        Launchy.open "http://localhost:#{port}/"
        @server.start
      ensure
        unless options[:server]
          stop_server
        end
      end
    end

    private

    def stop_server
      say "Shutting down server..."
      @server.shutdown
    end

    def html
      if options[:server]
        build_html filename
      else
        @html
      end
    end

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
