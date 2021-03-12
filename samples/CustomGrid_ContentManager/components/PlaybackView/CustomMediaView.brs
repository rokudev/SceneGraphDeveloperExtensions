' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

sub Init()
    ' Cache custom UI bits to m to work with them in the scope of callbacks
    m.customUI = m.top.FindNode("customUI")
    proxyVideo = m.top.FindNode("contentMedia")

    m.spinner = m.top.FindNode("spinner")
    m.spinnerLayout = m.top.FindNode("spinnerLayout")

    ' Create a timer to hide CustomUI
    m.HUDtimer = m.top.CreateChild("Timer")
    m.HUDtimer.repeat = false
    m.HUDtimer.duration = 2
    m.HUDtimer.ObserveFieldScoped("fire", "OnHUDTimerFireChanged")

    ' Disable default Video node UI using proxy node, 
    ' as enableUI field is not availablle in the top fields of the view
    proxyVideo.enableUI = false

    ' Set Callbacks for m.top fields from the view
    m.top.ObserveFieldScoped("state", "OnStateChanged")
    m.top.ObserveFieldScoped("duration", "OnDurationChanged")
    m.top.ObserveFieldScoped("position", "OnPositionChanged")
    m.top.ObserveFieldScoped("currentItem", "OnCurrentItemChanged")
    m.top.ObserveFieldScoped("mode", "OnModeChanged")

    ' Set Callbacks for trickplayPosition field of the proxy node,
    ' as there are no related m.top view fields
    proxyVideo.ObserveFieldScoped("trickplayPosition", "OnTrickplayPositionChanged")
end sub

' Callback function to handle a position change
sub OnPositionChanged(event as Object)
    m.customUI.position = event.getData()
end sub

' Callback function to handle a trickplay position change on the ProxyNode when user in rewind mode
sub OnTrickplayPositionChanged(event as Object)
    m.customUI.position = event.getData()
end sub

' Callback function to handle currentItem to update data at the HUD
sub OnCurrentItemChanged(event as Object)
    m.customUI.currentItem = event.getData()
end sub

' Callback function to handle a duration change
sub OnDurationChanged(event as Object)
    m.customUI.duration = event.getData()
end sub

' Callback function to handle a media mode change to always show a CustomUI in audio mode
sub OnModeChanged(event as Object)
    mode = event.getData()
    m.customUI.mode = mode
    if mode = "audio" 
        ' Always show a custom UI for audio mode
        m.customUI.visible = true
    end if
end sub

' Hide and show spinner and custom UI depend on the playback state
sub OnStateChanged(event as Object)
    state = event.getData()
    if state = "playing" 
        ' Hide a spinner and custom UI only for video mode
        ShowSpinner(false)
        if m.top.mode = "video"
            m.customUI.visible = false
            m.HUDtimer.control = "stop"
        end if
    else if state = "paused" 
        ' Show a custom UI only when the mode is a video
        if m.top.mode = "video"
            m.customUI.visible = true
        end if
    else if state = "finished" or state="buffering" or state="none" 
        ' Show the spinner to avoid empty black screen
        ShowSpinner(true)
    end if
end sub

' Show or hide a spinner depend on the flag
sub ShowSpinner(isVisible as Boolean)
    ' Check whether is a spinner currently shown to avoid overlap existing spinner
    if m.spinnerLayout.visible <> isVisible
        m.spinnerLayout.visible = isVisible
        if isVisible
            m.spinner.control = "start"
        else
            m.spinner.control = "stop"
        end if
    end if
end sub

' Callback function from m.HUDTimer to hide a HUD after 2 secondі 
sub OnHUDTimerFireChanged(event as Object)
    m.customUI.visible = false
end sub

' Overridden onKeyEvent() function to handle a key pressing
function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press and m.top.mode = "video" 
        ' Show or hide a custom UI depend on the key pressed
        if key = "down" and not m.customUI.visible 
           ' Show a custom UI for 2 seconds
            m.customUI.visible = true
            m.HUDtimer.control = "start"
        else if key = "up" and m.customUI.visible 
           ' Hide a custom UI and stop a timer when user press a up key
            m.customUI.visible = false
            m.HUDtimer.control = "stop"
        end if
    else if m.top.mode = "audio"
        if key = "left"
            m.top.seek = m.top.position - 5
        else if key = "right"
            m.top.seek = m.top.position + 5
        end if
    end if
    return handled
end function