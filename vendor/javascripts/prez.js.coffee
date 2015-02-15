changeSlideTo = (nextValue) ->
    $next = $(".slide[data-slide='#{nextValue}']")
    return false if $next.size() == 0
    $(".slide").hide()
    $next.show()
    true

$(document).on "click", ".next-slide, .prev-slide", (e) ->
    e.preventDefault()
    current = parseInt $(".slide:visible").data("slide"), 10
    nextValue = current

    if $(this).is(".next-slide")
        nextValue += 1
    else
        nextValue -= 1

    if changeSlideTo(nextValue)
        document.location.hash = nextValue

changeToHashSlide = ->
    hash = document.location.hash.replace /^#/, ""

    if /^\d+$/.test(hash) && $(".slide[data-slide='#{hash}']").length > 0
        changeSlideTo hash
        true
    else
        false

$ ->
    $(".slide").each (i) -> $(this).attr "data-slide", "#{i + 1}"
    changeSlideTo 1 unless changeToHashSlide()
    $(window).on "hashchange", -> changeToHashSlide()
