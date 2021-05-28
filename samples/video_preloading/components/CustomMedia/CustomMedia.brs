' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

sub Init()
    ' Cache custom UI bits to m for convenience
    m.endcardView = m.top.FindNode("endcardLayout")
    m.nextItemLabel = m.endcardView.FindNode("nextItemLabel")
    m.nextItemPoster = m.endcardView.FindNode("nextItemPoster")
    m.buttonGroup = m.endcardView.FindNode("buttonGroup")

    ' Populate custom endcard buttons
    m.buttonGroup.buttons = ["Play next", "Play again"]

    ' Set callback for endcard button selection
    m.buttonGroup.ObserveFieldScoped("buttonSelected", "OnEndcardButtonSelected")
    
    ' Set callback for handling endcard layout visibility change to update
    ' the custom endcard UI. SGDEX will trigger the endcards layout visibility
    ' behind the scenes when needed.
    m.endcardView.ObserveFieldScoped("visible", "OnEndcardsVisibleChanged")

    ' Set callback for handling focusedChild change on the custom endcard layout
    ' to set focus to the endcard buttons once the endcard gains UI focus
    ' (this is triggered by the SGDEX behind the scenes)
    m.endcardView.ObserveFieldScoped("focusedChild", "OnEndcardFocusedChildChange")
end sub

 ' Callback function for handling endcard layout visibility change to update
 ' the custom endcard UI.
sub OnEndcardsVisibleChanged(event as Object)
    visible = event.GetData()
    if visible = true
        ' get the next item of the playlist and parse info to update UI elements
        nextItem = m.top.content.GetChild(m.top.currentIndex)
        if nextItem <> invalid
            ' update endcard next item title and poster
            m.nextItemLabel.text = "Up Next: " + nextItem.title
            m.nextItemPoster.uri = nextItem.hdPosterUrl
        else
            ' close the media view if there is no next item to show
            m.top.close = true
        end if
    end if
end sub

' Callback function for handling endcard button selection
sub OnEndcardButtonSelected(event as Object)
    ' get selected button index from the event
    itemSelected = event.getData()    
    
    ' process button by its index
    if itemSelected = 0 'Play next
        ' just initiate playback, it'll start the next video in the playlist
        m.top.control = "play"
        ' hide the endcard layout
        m.endcardView.visible = false
    else if itemSelected = 1 'Play again
        ' jump to the previous item to start content from the beginning
        m.top.jumpToItem = m.top.currentIndex - 1
        ' initiate the playback
        m.top.control = "play"
        ' and hide the endcard layout
        m.endcardView.visible = false
    end if
end sub

' Callback for handling focusedChild change on the custom endcard layout
' to set focus to the endcard buttons once the endcard gains UI focus
sub OnEndcardFocusedChildChange(event as Object)
    ' endcards layout gained the focus but its buttons are not in focus yet?
    if m.endcardView.IsInFocusChain() and m.buttonGroup.HasFocus() = false and m.buttonGroup.IsInFocusChain() = false
        ' set focus to the endcard buttons
        m.buttonGroup.SetFocus(true)
    end if
end sub