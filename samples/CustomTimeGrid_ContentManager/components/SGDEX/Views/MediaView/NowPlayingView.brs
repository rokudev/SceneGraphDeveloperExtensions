' Copyright (c) 2019 Roku, Inc. All rights reserved.

sub init()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    parent = m.top.GetParent()
    if parent <> invalid then 
        parent.setFocus(true)
    end if
    return false
end function