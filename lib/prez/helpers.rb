require "cgi"
require "prez/assets"
require "prez/error"

module Prez
  module Helpers
    protected

    def html_escape(value)
      CGI.escape_html value
    end

    def slide
      concat %{<div class="prez-slide">}
      yield
      concat %{</div>}
    end

    def notes
      concat %{<div class="prez-notes">}
      yield
      concat %{</div>}
    end

    def javascript(name)
      Prez::Assets.javascript name
    rescue Prez::Files::MissingError
      raise Prez::Error.new("Could not find file: '#{name}.js'")
    end

    def stylesheet(name)
      Prez::Assets.stylesheet name
    rescue Prez::Files::MissingError
      raise Prez::Error.new("Could not find file: '#{name}.css'")
    end
  end
end
