class PrezController
    constructor: ->
        @window = window.open "", "prez", "width=640,height=480"
        @window.document.write $("#slides-document").text()
        @window.prez.start()
        $("#pre-launch").hide()
        $("#post-launch").show()

        $(@window).bind "beforeunload", =>
            $("#post-launch").hide()
            $("#pre-launch").show()
            PrezController.current = null
            return undefined

    nextSlide: -> @window.prez.nextSlide()
    prevSlide: -> @window.prez.prevSlide()
    end: -> @window.prez.end()

$(document).on "click", ".next-slide", (e) ->
    e.preventDefault()
    PrezController.current?.nextSlide()

$(document).on "click", ".prev-slide", (e) ->
    e.preventDefault()
    PrezController.current?.prevSlide()

$(document).on "click", ".end-prez", (e) ->
    e.preventDefault()
    PrezController.current?.end()

$(document).on "click", "#launch", (e) ->
    e.preventDefault()
    return if PrezController.current
    PrezController.current = new PrezController()
