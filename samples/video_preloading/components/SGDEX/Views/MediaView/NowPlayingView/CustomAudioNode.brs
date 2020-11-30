sub init()
    m.top.clippingRect = [0, 600, 1280, 720]
end sub

function OnKeyEvent(key as String, press as Boolean) as Boolean
    key = LCase(key) ' safety check
    handled = false
    if press
        if key = "left" or key = "right" or key = "ok" or key = "up" or key = "down"
            m.top.keyPressed = key
            handled = true
            if key = "up"
                buttons = m.top.GetParent().buttons 
                if not (buttons <> invalid and buttons.GetChildCount() > 0)
                    handled = false     
                end if    
            end if    
        end if
    end if
    return handled
end function
