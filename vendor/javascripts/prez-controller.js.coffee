class Prez
    DEFAULT_OPTIONS =
        useHash: true

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
        @changeSlideTo 1 unless changeToHashSlide()
        $(@window).on "hashchange", changeToHashSlide
        $(@document).on "keydown", Prez.handlers.keyDown

    changeSlideTo: (nextValue) ->
        $next = $ ".prez-slide[data-slide='#{nextValue}']", @document
        return false if $next.size() == 0
        $(".prez-slide", @document).hide()
        $next.show()
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

$(document).on "click", "#new-window", (e) ->
    return if Prez.current

    callback = =>
        if $(this).is(".active")
            $("#new-window #launch-message").text "Launch in new window"
            $("#new-window .glyphicon").addClass("glyphicon-new-window").removeClass("glyphicon-unchecked")
        else
            $("#new-window #launch-message").text "Launch in this window"
            $("#new-window .glyphicon").removeClass("glyphicon-new-window").addClass("glyphicon-unchecked")

    setTimeout callback, 1

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
        window: window.open("", "prez", "width=640,height=480")
        slideChanged: ($slide, slideNumber) ->
            notes = $slide.find(".prez-notes").html() || ""
            $("#slide-notes").html notes
            $(".current-slide-number").text $slide.data("slide")
            iframePrez.changeSlideTo slideNumber

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

$ ->
    $("#in-window-not-implemented-modal").modal show: false
