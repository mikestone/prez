require "cgi"
require "prez/assets"
require "thor/error"

module Prez
  module Helpers
    protected

    def html_escape(value)
      CGI.escape_html value
    end

    def slide
      concat %{<div class="slide">}
      yield
      concat %{</div>}
    end

    def javascript(name)
      Prez::Assets.javascript name
    rescue Prez::Files::MissingError
      raise Thor::Error.new(set_color("Could not find file: '#{name}.js'", :red, :bold))
    end

    def stylesheet(name)
      Prez::Assets.stylesheet name
    rescue Prez::Files::MissingError
      raise Thor::Error.new(set_color("Could not find file: '#{name}.css'", :red, :bold))
    end
  end
end
