require "cgi"
require "prez/assets"
require "prez/error"

module Prez
  module Helpers
    protected

    def html_escape(value)
      CGI.escape_html value
    end

    def slide(options = {})
      classes = ["prez-slide"]
      align = options.fetch :align, :center

      case align
      when :left
        classes << "left-aligned"
      when :right
        classes << "right-aligned"
      when :center
        # Nothing needed
      else
        raise Prez::Error.new("Invalid slide align: #{align.inspect}")
      end

      concat %{<div class="#{classes.join " "}">}
      yield
      concat %{</div>}
    end

    def notes
      concat %{<div class="prez-notes">}
      yield
      concat %{</div>}
    end

    def image(name, options = {})
      Prez::Assets.image name, options
    rescue Prez::Files::MissingError
      raise Prez::Error.new("Could not find image file: '#{name}'")
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
