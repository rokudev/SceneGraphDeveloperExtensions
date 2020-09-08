' Copyright (c) 2019 Roku, Inc. All rights reserved.

sub init()
end sub

' NowPLayingNode steals the focus when it is initialized
' and closes channel if user pressed back on it
' to avoid closing of the channel we should have this workaround in place
function onKeyEvent(key as String, press as Boolean) as Boolean
    parent = m.top.GetParent()
    if parent <> invalid then
        parent.setFocus(true)
    end if
    if key = "back" then return true

    return false
end function