$.setTimeout = (t, fn) -> setTimeout fn, t
$.setInterval = (t, fn) -> setInterval fn, t

$.fn.slideDuration = ->
    parseInt(@data("duration") || "0", 10)

class Prez
    DEFAULT_OPTIONS =
        useHash: true
        duration: 0
        slideElementStyle: "hide"

    constructor: (options) ->
        @options = $.extend {}, DEFAULT_OPTIONS, options
        @window = options.window
        @document = @window.document
        @document.write $("#slides-document").text()
        @document.close()
        @options.beforeStart?(@)
        @start()

    start: ->
        changeToHashSlide = =>
            return false unless @options.useHash
            hash = @document.location.hash.replace /^#/, ""
            match = /^(\d+)-(\d+)$/.exec hash

            if match
                slide = parseInt match[1], 10
                element = parseInt match[2], 10
                selector = ".prez-slide[data-slide='#{slide}']"

                if element > 0
                    selector = "#{selector} .prez-element[data-slide-element='#{element}']"

                if $(selector, @document).length > 0
                    @changeSlideTo slide, element
                    return true

            false

        slideElementClass = "#{@options.slideElementStyle}-style"

        $(".prez-slide", @document).each (i) ->
            $(@).attr "data-slide", "#{i + 1}"

            $(@).find(".prez-element").each (j) ->
                $(@).attr "data-slide-element", "#{j + 1}"
                $(@).addClass("hidden #{slideElementClass}")

        @startTime = Date.now()
        @changeSlideTo 1 unless changeToHashSlide()
        $(@window).on "hashchange", changeToHashSlide
        $(@document).on "keydown", Prez.handlers.keyDown


    slideStarted: ($slide) ->
        @slideStartTime = Date.now()
        @slideDuration = $slide.slideDuration()

        # When unspecified, the slide duration is an even amount based
        # on the remaining slides that don't have a specific duration
        if @slideDuration <= 0
            $remainingUntimed = $slide.nextAll(".prez-slide").filter -> $(@).slideDuration() <= 0
            @slideDuration = @remainingPresentationSeconds() / ($remainingUntimed.size() + 1)

            if @slideDuration < 0
                @slideDuration = 0

    changeSlideTo: (nextValue, nextElement = 0) ->
        $next = $ ".prez-slide[data-slide='#{nextValue}']", @document
        return false if $next.size() == 0

        if nextValue != @currentSlide()
            $(".prez-slide", @document).hide()
            $next.show()
            @slideStarted $next

        if nextElement == 0
            $next.find(".prez-element").addClass("hidden").removeClass("visible")
        else if @currentElement() > nextElement
            for i in [@currentElement()..(nextElement + 1)]
                $next.find(".prez-element[data-slide-element='#{i}']").addClass("hidden").removeClass("visible")
        else if @currentElement() < nextElement
            for i in [(@currentElement() + 1)..nextElement]
                $next.find(".prez-element[data-slide-element='#{i}']").removeClass("hidden").addClass("visible")

        # Hack to fix Chrome sometimes not rendering opacity changes,
        # thanks to http://stackoverflow.com/a/8840703/122
        if @options.slideElementStyle == "opacity"
            $next.hide().show(0)

        @options.slideChanged? $next, nextValue, nextElement
        true

    currentSlide: ->
        return null if $(".prez-slide:visible", @document).size() == 0
        parseInt $(".prez-slide:visible", @document).data("slide"), 10

    currentElement: ->
        return null if @currentSlide() == null
        return 0 if $(".prez-slide:visible .prez-element.visible", @document).size() == 0
        parseInt $(".prez-slide:visible .prez-element.visible:last", @document).data("slide-element"), 10

    countSlideElements: (slide) ->
        $slide = $(".prez-slide[data-slide='#{slide}']", @document)
        return 0 if $slide.size() == 0
        $slide.find(".prez-element").size()

    countSlides: ->
        $(".prez-slide", @document).size()

    changeSlideBy: (amount) ->
        slide = @currentSlide()
        element = @currentElement()
        nextSlide = slide
        nextElement = element

        for _ in [1..Math.abs(amount)]
            if amount > 0
                if nextElement >= @countSlideElements(nextSlide)
                    nextSlide++
                    nextElement = 0
                else
                    nextElement++
            else
                if nextElement <= 0
                    nextSlide--
                    nextElement = @countSlideElements nextSlide
                else
                    nextElement--

        if @changeSlideTo(nextSlide, nextElement) && @options.useHash
            @document.location.hash = "#{nextSlide}-#{nextElement}"

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
            seconds = Prez.current.remainingPresentationSeconds()
            $(".prez-total-duration").toggleClass("prez-danger-time", seconds <= 60 && seconds >= 0)
            $(".prez-total-duration").toggleClass("prez-over-time", seconds < 0)
            $(".prez-current-slide-duration").text Prez.current.remainingSlideTime()
            seconds = Prez.current.remainingSlideSeconds()
            $(".prez-current-slide-duration").toggleClass("prez-danger-time", seconds <= 3 && seconds >= 0)
            $(".prez-current-slide-duration").toggleClass("prez-over-time", seconds < 0)

            if Math.floor(Date.now() / 250) % 2 == 0
                $(".prez-danger-time").hide()
            else
                $(".prez-danger-time").show()

            # Ensure transitions stay shown
            $(".prez-total-duration:not(.prez-danger-time)").show()
            $(".prez-current-slide-duration:not(.prez-danger-time)").show()

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
        slideElementStyle: "opacity"

    Prez.current = new Prez
        duration: Prez.timeToSeconds($("#prez-duration").val())
        window: window.open("", "prez", "width=640,height=480")
        slideChanged: ($slide, slideNumber, elementNumber) ->
            notes = $slide.find(".prez-notes").html() || ""
            $("#slide-notes").html notes
            $(".current-slide-number:not(select)").text $slide.data("slide")
            $("select.current-slide-number").val $slide.data("slide")
            Prez.handlers.timeChange()
            iframePrez.changeSlideTo slideNumber, elementNumber
        beforeStart: (prez) ->
            $("select.current-slide-number").empty()

            for i in [1..prez.countSlides()]
                $("select.current-slide-number").append """<option value="#{i}">#{i}</option>"""

    $(".total-slides").text Prez.current.countSlides()
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

$(document).on "change", "select.current-slide-number", (e) ->
    Prez.current?.changeSlideTo parseInt($(@).val(), 10)
    $(@).blur()

$(window).bind "beforeunload", ->
    Prez.current?.end()

$(document).on "keydown", Prez.handlers.keyDown
$.setInterval 50, Prez.handlers.timeChange

$ ->
    $("#in-window-not-implemented-modal").modal show: false
