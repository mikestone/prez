require "base64"

module Prez
  class DataUri
    attr_reader :type, :contents

    def initialize(type, contents)
      @type = type
      @contents = Base64.encode64 contents
      @contents.gsub! "\n", ""
    end

    def to_s
      "data:#{type};base64,#{contents}"
    end
  end
end
