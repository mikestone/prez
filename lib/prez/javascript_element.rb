module Prez
  class JavascriptElement
    def self.next_id
      @next_id ||= 0
      @next_id += 1
    end

    def initialize(up, down)
      @id = Prez::JavascriptElement.next_id
      @up_js = up
      @down_js = down
    end

    def to_s
      <<-EOF
        <script>
          window.elementJs = window.elementJs || {};

          window.elementJs.up#{@id} = function($) {
            #{@up_js}
          };

          window.elementJs.down#{@id} = function($) {
            #{@down_js}
          };
        </script>
        <span class="prez-element" data-element-js data-element-js-up="up#{@id}" data-element-js-down="down#{@id}"></span>
      EOF
    end
  end
end
