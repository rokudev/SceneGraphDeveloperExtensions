' Copyright (c) 2019 Roku, Inc. All rights reserved.

sub init()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    key = LCase(key) ' safety check

    if press and key = "back"
        m.top.backButtonPressed = true
        return true
    end if
    return false
end function
