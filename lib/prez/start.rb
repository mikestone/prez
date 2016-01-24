require "launchy"
require "thor/actions"
require "thor/group"
require "webrick"

module Prez
  class Start < Thor::Group
    include Thor::Actions
    include Prez::Builder
    argument :name, type: :string, required: false, default: nil
    class_option :server, type: :boolean, desc: "Keep the server up for dynamic refreshes"

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
          say "Ignoring request: #{request.path}"
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

    def prez_name
      @prez_name = name || only_existing_prez
    end

    def only_existing_prez
      results = Dir.glob "*.prez"

      if results.empty?
        raise Prez::Error.new("No .prez files found!")
      elsif results.size > 1
        raise Prez::Error.new("More than one .prez file found!\nPlease specify which one you want to start.")
      end

      results.first
    end

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
