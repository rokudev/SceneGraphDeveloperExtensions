' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

function ShowDetailsView(content as Object, index as Integer) as Object
    ' Create a DetailsView object and set the content and selected item
    m.details = CreateObject("roSGNode", "DetailsView")
    m.details.SetFields({
        content: content
        jumpToItem: index
    })
    
    ' Set Callback for DetailsView fields
    m.details.ObserveField("itemLoaded", "OnDetailsItemLoaded")
    m.details.ObserveField("currentItem","OnDetailsContentSet")
    m.details.ObserveField("buttonSelected", "OnButtonSelected")

    ' Push the DetailsView object to the stack to show it on the screen
    m.top.ComponentController.CallFunc("show", {
        view: m.details
    })

    return m.details
end function

' Callback function to handle a result of the loading content
' once the handler finished work update the buttons on the screen
sub OnDetailsContentSet(event as Object)
    content = event.GetData()
    if (content <> invalid)
        btnsContent = CreateObject("roSGNode", "ContentNode")
        streamUrl = content.url
        if (streamUrl <> invalid and streamUrl <> "")
            btnsContent.Update({ children: [{ title: "Play" }] })
        else
            btnsContent.Update({ children: [{ title: "Loading..." }] })
        end if

        ' update the buttons on the screen
        details = event.GetRoSGNode()
        details.buttons = btnsContent
    end if
end sub

sub OnDetailsItemLoaded()
    ' create a media view so we can start preloading content
    ' we won't show this view until the user selects the "Play" button on the DetailsView
    if m.useCustomEndcard = true
        ' create the custom media view with the custom endcard layout
        m.video = CreateObject("roSGNode", "CustomMedia")
    else
        ' create the native MediaView having native endcard layout
        m.video = CreateObject("roSGNode", "MediaView")
    end if
    m.video.ObserveFieldScoped("wasClosed", "OnVideoWasClosed")

    ' we'll use this observer to print the state of the MediaView to the console
    ' this let's us see when prebuffering starts
    m.video.ObserveField("state", "OnVideoState")

    ' preloading also works while endcards are displayed
    m.video.alwaysShowEndcards = true

    m.video.content = m.details.content
    m.video.jumpToItem = m.details.itemFocused

    ' turn on preloading
    ' it's off by default for backward compatibility
    m.video.preloadContent = true
end sub

sub OnButtonSelected(event as Object)
    ' the media view already exists and has been preloading content
    ' all we do now is push it onto the view stack
    m.video.control = "play"
    m.top.ComponentController.CallFunc("show", {
        view: m.video
    })
end sub

sub OnVideoState(event)
  ? "OnVideoState " + m.video.state
end sub

sub OnVideoWasClosed()
    m.details.jumpToItem = m.video.currentIndex ' update the focuse item at the DetailsView
    m.video = invalid ' clear played video node
    OnDetailsItemLoaded() ' start buffering new one
end sub
