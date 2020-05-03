' CustomTimeGrid is used to know if user press down right or left remote button
' and does not release it
function OnKeyEvent(key as String, press as Boolean) as Boolean
    handled = false

    m.top.isScrolling = press and (key = "right" or key = "left")

    return handled
end function
