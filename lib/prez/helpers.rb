require "cgi"
require "prez/assets"
require "prez/error"

module Prez
  module Helpers
    protected

    def reset_helpers!
      @duration = nil
    end

    def duration(value)
      if @duration
        raise Prez::Error.new("The duration helper can only be called once!")
      end

      if value.kind_of?(String) && value.split(":").size > 3
        raise Prez::Eror.new("Only hours:minutes:seconds are supported for the duration!")
      end

      @duration = value
      nil
    end

    def duration_amount
      return if @duration.nil? || @duration.to_i <= 0

      # Ensure it is an integer first... then we can normalize based
      # on standard times (ie, no 70 seconds, or 100 minutes)
      if @duration.kind_of? String
        @duration = @duration.split ":"
        @duration.map! &:to_i
        value = @duration.pop || 0
        value += (@duration.pop || 0) * 60
        value += (@duration.pop || 0) * 60 * 60
        @duration = value
      end

      # Ensure we don't have a floating point number
      @duration = @duration.to_i
      seconds = @duration % 60
      minutes = (@duration / 60) % 60
      hours = @duration / 60 / 60

      if hours > 0
        "%d:%02d:%02d" % [hours, minutes, seconds]
      elsif minutes > 0
        "%2d:%02d" % [minutes, seconds]
      else
        seconds.to_s
      end
    end

    def html_escape(value = nil, &block)
      if block
        value = capture &block
      end

      value = CGI.escape_html value

      if block
        concat value
      else
        value
      end
    end

    def capture()
      buf = ""
      old_buffer = @output_buffer
      @output_buffer = buf
      yield
      buf.to_s
    ensure
      @output_buffer = old_buffer
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

      if options[:duration]
        duration_attribute = %{ data-duration="#{options[:duration]}"}
      end

      concat %{<div class="#{classes.join " "}"#{duration_attribute}>}
      yield
      concat %{</div>}
    end

    def element(options = {})
      tag = options.fetch :tag, :div
      concat %{<#{tag} class="prez-element">}
      yield
      concat %{</#{tag}>}
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
