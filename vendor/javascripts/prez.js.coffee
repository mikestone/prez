class Prez
    changeSlideTo: (nextValue) ->
        $next = $(".slide[data-slide='#{nextValue}']")
        return false if $next.size() == 0
        $(".slide").hide()
        $next.show()
        true

    changeSlideBy: (amount) ->
        current = parseInt $(".slide:visible").data("slide"), 10
        nextValue = current + amount

        if @changeSlideTo(nextValue)
            document.location.hash = nextValue

    start: ->
        changeToHashSlide = =>
            hash = document.location.hash.replace /^#/, ""

            if /^\d+$/.test(hash) && $(".slide[data-slide='#{hash}']").length > 0
                @changeSlideTo hash
                true
            else
                false

        $(".slide").each (i) -> $(@).attr "data-slide", "#{i + 1}"
        @changeSlideTo 1 unless changeToHashSlide()
        $(window).on "hashchange", changeToHashSlide

    end: ->
        window.close()

    nextSlide: -> @changeSlideBy 1
    prevSlide: -> @changeSlideBy -1

window.prez = new Prez()
