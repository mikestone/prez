require "base64"
require "prez/error"
require "prez/files"
require "sass"

module Sass::Script::Functions
  def twbs_font_path(path)
    assert_type path, :String
    path = path.value.sub /[?#].*/, ""
    font_data = Base64.encode64 Prez::Files.contents(path, "font")
    font_data.gsub! "\n", ""
    extension = path[/\.([^.]*)$/, 1]

    case extension
    when "eot"
      font_type = "application/vnd.ms-fontobject"
    when "svg"
      font_type = "image/svg+xml"
    when "ttf"
      font_type = "font/ttf"
    when "woff"
      font_type = "application/font-woff"
    when "woff2"
      font_type = "application/font-woff2"
    else
      raise Prez::Error.new("Unknown font extension '#{extension}'")
    end

    Sass::Script::Value::String.new("data:#{font_type};base64,#{font_data}")
  rescue Prez::Files::MissingError => e
    raise Prez::Error.new("Could not find font: '#{path}'")
  end

  def twbs_image_path(path)
    Sass::Script::Value::String.new("ARGLE BARGLE IMAGE #{path.inspect}")
  end

  declare :twbs_font_path, [:path]
  declare :twbs_image_path, [:path]
end
