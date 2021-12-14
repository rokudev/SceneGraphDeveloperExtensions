' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

sub Init()
    ' Cache custom UI bits to m for convenience
    m.contentButtonBar = m.top.FindNode("contentButtonBar")
    m.backgroundRec = m.top.FindNode("background")

    m.animation = m.top.FindNode("animation")
    m.backgroundWidthInterpolator = m.top.FindNode("backgroundWidthInterpolator")
    m.buttonBarWidthInterpolator = m.top.FindNode("buttonBarWidthInterpolator")
    
    ' Observe button bar focusedChild changes to handle the show/hide animation
    m.top.ObserveFieldScoped("focusedChild", "OnFocusedChildChanged")
end sub

 ' Callback function for handling focus change to show/hide the button bar
sub OnFocusedChildChanged(event as Object)
    focusedChild = event.GetData()

    ' check if button bar gained focus by checking its focusedChild
    if focusedChild = invalid
        ' focusedChild is invalid which means button bar has just lost the focus
        ' start shrink animation
        m.backgroundWidthInterpolator.keyValue = [m.backgroundRec.width, 0]
        m.buttonBarWidthInterpolator.keyValue = [m.contentButtonBar.itemSize, [108, 52]]
        m.animation.control = "start"
        
        currentView = m.top.GetScene().ComponentController.currentView
        if currentView <> invalid and not currentView.IsInFocusChain()
            ' shortcut the animation as this is the case when the user exited to the previous
            ' view from the button bar and we need button bar to have proper size by the moment
            ' when the previous view has been displayed
            m.animation.control = "finish"
        end if
    else if focusedChild.subtype() = "Rectangle" and m.backgroundRec.width = 0
        ' focusedChild is button bar rectangle with zero width (collapsed) which means
        ' button bar has just gained focus - start expand animation
        m.backgroundWidthInterpolator.keyValue = [m.backgroundRec.width, 252]
        m.buttonBarWidthInterpolator.keyValue = [m.contentButtonBar.itemSize, [252, 52]]
        m.animation.control = "start"
    end if
end sub