' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

function ShowDetailsView(content as Object, index as Integer) as Object
    m.details = CreateObject("roSGNode", "DetailsView")
    m.details.SetFields({
        content: content
        jumpToItem: index
    })
    
    m.details.ObserveField("itemLoaded", "OnDetailsItemLoaded")
    m.details.ObserveField("currentItem","OnDetailsContentSet")
    m.details.ObserveField("buttonSelected", "OnButtonSelected")

    m.top.ComponentController.CallFunc("show", {
        view: m.details
    })

    return m.details
end function

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

        details = event.GetRoSGNode()
        details.buttons = btnsContent
    end if
end sub

sub OnDetailsItemLoaded()
    ' create a media view so we can start preloading content
    ' we won't show this view until the user selects the "Play" button on the DetailsView
    m.video = CreateObject("roSGNode", "MediaView")
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
    m.video = invalid ' clear played video node
    OnDetailsItemLoaded() ' start buffering new one
end sub
