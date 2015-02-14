var changeSlideTo = function(nextValue) {
    var $next = $(".slide[data-slide='" + nextValue + "']");

    if ($next.size() == 0) {
        return false;
    }

    $(".slide").hide();
    $next.show();
    return true;
};

$(document).on("click", ".next-slide, .prev-slide", function() {
    var current = parseInt($(".slide:visible").data("slide"), 10);
    var nextValue = current;

    if ($(this).is(".next-slide")) {
        nextValue += 1;
    } else {
        nextValue -= 1;
    }

    if (changeSlideTo(nextValue)) {
        document.location.hash = nextValue;
    }

    return false;
});

var changeToHashSlide = function() {
    var hash = document.location.hash.replace(/^#/, "");

    if (/^\d+$/.test(hash) && $(".slide[data-slide='" + hash + "']").length > 0) {
        changeSlideTo(hash);
        return true;
    }

    return false;
};

$(function() {
    $(".slide").each(function(i) {
        $(this).attr("data-slide", "" + (i + 1));
    });

    if (!changeToHashSlide()) {
        changeSlideTo(1);
    }

    $(window).on("hashchange", function() {
        changeToHashSlide();
    });
});
