$.setTimeout = (t, fn) -> setTimeout fn, t
$.setInterval = (t, fn) -> setInterval fn, t

$.fn.slideDuration = ->
    parseInt(@data("duration") || "0", 10)

class Prez
    DEFAULT_OPTIONS =
        useHash: true
        duration: 0

    constructor: (options) ->
        @options = $.extend {}, DEFAULT_OPTIONS, options
        @window = options.window
        @document = @window.document
        @document.write $("#slides-document").text()
        @document.close()
        @start()

    start: ->
        changeToHashSlide = =>
            return false unless @options.useHash
            hash = @document.location.hash.replace /^#/, ""

            if /^\d+$/.test(hash) && $(".prez-slide[data-slide='#{hash}']", @document).length > 0
                @changeSlideTo hash
                true
            else
                false

        $(".prez-slide", @document).each (i) -> $(@).attr "data-slide", "#{i + 1}"
        @startTime = Date.now()
        @changeSlideTo 1 unless changeToHashSlide()
        $(@window).on "hashchange", changeToHashSlide
        $(@document).on "keydown", Prez.handlers.keyDown

    changeSlideTo: (nextValue) ->
        $next = $ ".prez-slide[data-slide='#{nextValue}']", @document
        return false if $next.size() == 0
        $(".prez-slide", @document).hide()
        $next.show()
        @slideStartTime = Date.now()
        @slideDuration = $next.slideDuration()

        # When unspecified, the slide duration is an even amount based
        # on the remaining slides that don't have a specific duration
        if @slideDuration <= 0
            $remainingUntimed = $next.nextAll(".prez-slide").filter -> $(@).slideDuration() <= 0
            @slideDuration = @remainingPresentationSeconds() / ($remainingUntimed.size() + 1)

            if @slideDuration < 0
                @slideDuration = 0

        @options.slideChanged? $next, nextValue
        true

    changeSlideBy: (amount) ->
        current = parseInt $(".prez-slide:visible", @document).data("slide"), 10
        nextValue = current + amount

        if @changeSlideTo(nextValue) && @options.useHash
            @document.location.hash = nextValue

    nextSlide: -> @changeSlideBy 1
    prevSlide: -> @changeSlideBy -1
    end: -> @window.close()

    remainingPresentationSeconds: ->
        Math.floor(@options.duration - ((Date.now() - @startTime) / 1000))

    remainingPresentationTime: ->
        Prez.secondsToTime @remainingPresentationSeconds(), Prez.timeLevels(@options.duration)

    remainingSlideSeconds: ->
        Math.floor(@slideDuration - ((Date.now() - @slideStartTime) / 1000))

    remainingSlideTime: ->
        Prez.secondsToTime @remainingSlideSeconds(), Prez.timeLevels(@slideDuration)

    @timeLevels: (s) ->
        if s >= (60 * 60)
            3
        else if s >= 60
            2
        else
            1

    @timeToSeconds: (t) ->
        values = t.split ":"
        result = parseInt(values.pop() || "0", 10)
        result += parseInt(values.pop() || "0", 10) * 60
        result += parseInt(values.pop() || "0", 10) * 60 * 60
        result

    @secondsToTime: (s, minLevels = 1) ->
        pad = (n, size) ->
            result = "#{n}"

            while result.length < size
                result = "0#{result}"

            result

        s = Math.floor s
        s = Math.abs s
        seconds = s % 60
        minutes = Math.floor(s / 60) % 60
        hours = Math.floor(s / 60 / 60)

        if hours > 0 || minLevels >= 3
            "#{hours}:#{pad minutes, 2}:#{pad seconds, 2}"
        else if minutes > 0 || minLevels == 2
            "#{minutes}:#{pad seconds, 2}"
        else
            "#{seconds}"

    KEY_ENTER = 13
    KEY_SPACE = 32
    KEY_LEFT = 37
    KEY_RIGHT = 39

    @handlers:
        keyDown: (e) ->
            return if $(e.target).is("button, input, textarea, select, option")

            switch e.which
                when KEY_LEFT
                    e.preventDefault()
                    Prez.current?.prevSlide()
                when KEY_ENTER, KEY_SPACE, KEY_RIGHT
                    e.preventDefault()
                    Prez.current?.nextSlide()

        timeChange: ->
            return unless Prez.current
            $(".prez-total-duration").text Prez.current.remainingPresentationTime()
            $(".prez-current-slide-duration").text Prez.current.remainingSlideTime()

$(document).on "click", "#new-window", (e) ->
    return if Prez.current

    $.setTimeout 1, =>
        if $(this).is(".active")
            $("#new-window #launch-message").text "Launch in new window"
            $("#new-window .glyphicon").addClass("glyphicon-new-window").removeClass("glyphicon-unchecked")
        else
            $("#new-window #launch-message").text "Launch in this window"
            $("#new-window .glyphicon").removeClass("glyphicon-new-window").addClass("glyphicon-unchecked")

$(document).on "click", "#launch", (e) ->
    e.preventDefault()
    return if Prez.current

    unless $("#new-window").is(".active")
        $("#in-window-not-implemented-modal").modal "show"
        return

    iframe = $("iframe")[0]

    iframe = if iframe.contentWindow
        iframe.contentWindow
    else if iframe.contentDocument.document
        iframe.contentDocument.document
    else
        iframe.contentDocument

    iframePrez = new Prez
        window: iframe
        useHash: false

    Prez.current = new Prez
        duration: Prez.timeToSeconds($("#prez-duration").val())
        window: window.open("", "prez", "width=640,height=480")
        slideChanged: ($slide, slideNumber) ->
            notes = $slide.find(".prez-notes").html() || ""
            $("#slide-notes").html notes
            $(".current-slide-number").text $slide.data("slide")
            Prez.handlers.timeChange()
            iframePrez.changeSlideTo slideNumber

    $(".total-slides").text $(".prez-slide", Prez.current.document).size()
    $("#pre-launch").hide()
    $("#post-launch").show()

    $(Prez.current.window).bind "beforeunload", ->
        $("#post-launch").hide()
        $("#pre-launch").show()
        Prez.current = null
        return undefined

$(document).on "click", ".next-slide", (e) ->
    e.preventDefault()
    Prez.current?.nextSlide()

$(document).on "click", ".prev-slide", (e) ->
    e.preventDefault()
    Prez.current?.prevSlide()

$(document).on "click", ".end-prez", (e) ->
    e.preventDefault()
    Prez.current?.end()

$(document).on "keydown", Prez.handlers.keyDown
$.setInterval 50, Prez.handlers.timeChange

$ ->
    $("#in-window-not-implemented-modal").modal show: false
