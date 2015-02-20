require "thor/error"
require "thor/shell/color"

module Prez
  class Error < Thor::Error
    def initialize(msg)
      super colorize(msg)
    end

    private

    def colorize(msg)
      Thor::Shell::Color.new.set_color msg, :red, :bold
    end
  end
end
