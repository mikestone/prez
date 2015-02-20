class Prez
    constructor: ->
        @window = window.open "", "prez", "width=640,height=480"
        @document = @window.document
        @document.write $("#slides-document").text()
        @start()
        $("#pre-launch").hide()
        $("#post-launch").show()

        $(@window).bind "beforeunload", ->
            $("#post-launch").hide()
            $("#pre-launch").show()
            Prez.current = null
            return undefined

    start: ->
        changeToHashSlide = =>
            hash = @document.location.hash.replace /^#/, ""

            if /^\d+$/.test(hash) && $(".prez-slide[data-slide='#{hash}']", @document).length > 0
                @changeSlideTo hash
                true
            else
                false

        $(".prez-slide", @document).each (i) -> $(@).attr "data-slide", "#{i + 1}"
        @changeSlideTo 1 unless changeToHashSlide()
        $(@window).on "hashchange", changeToHashSlide

    changeSlideTo: (nextValue) ->
        $next = $ ".prez-slide[data-slide='#{nextValue}']", @document
        return false if $next.size() == 0
        $(".prez-slide", @document).hide()
        $next.show()
        notes = $next.find(".prez-notes").html() || ""
        $("#slide-notes").html notes
        $(".current-slide-number").text $next.data("slide")
        true

    changeSlideBy: (amount) ->
        current = parseInt $(".prez-slide:visible", @document).data("slide"), 10
        nextValue = current + amount

        if @changeSlideTo(nextValue)
            @document.location.hash = nextValue

    nextSlide: -> @changeSlideBy 1
    prevSlide: -> @changeSlideBy -1
    end: -> @window.close()

$(document).on "click", ".next-slide", (e) ->
    e.preventDefault()
    Prez.current?.nextSlide()

$(document).on "click", ".prev-slide", (e) ->
    e.preventDefault()
    Prez.current?.prevSlide()

$(document).on "click", ".end-prez", (e) ->
    e.preventDefault()
    Prez.current?.end()

$(document).on "click", "#launch", (e) ->
    e.preventDefault()
    return if Prez.current
    Prez.current = new Prez()
