' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

function ShowDetailsView(content as Object, index as Integer) as Object
    details = CreateObject("roSGNode", "DetailsView")
    details.SetFields({
        content: content
        jumpToItem: index
    })
    details.ObserveField("currentItem","OnDetailsContentSet")
    details.ObserveField("buttonSelected", "OnButtonSelected")

    m.top.ComponentController.CallFunc("show", {
        view: details
    })

    return details
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

        ' create a video view so we can start preloading content
        ' we won't show this view until the user selects the "Play" button on the DetailsView
        m.video = CreateObject("roSGNode", "VideoView")

        ' we'll use this observer to print the state of the VideoView to the console
        ' this let's us see when prebuffering starts
        m.video.ObserveField("state", "OnVideoState")

        ' preloading also works while endcards are displayed
        m.video.alwaysShowEndcards = true

        m.video.content = details.content
        m.video.jumpToItem = details.itemFocused

        ' turn on preloading
        ' it's off by default for backward compatibility
        m.video.preloadContent = true
    end if
end sub

sub OnButtonSelected(event as Object)
    ' the video view already exists and has been preloading content
    ' all we do now is push it onto the view stack
    m.top.ComponentController.CallFunc("show", {
        view: m.video
    })
    m.video.control = "play"
end sub

sub OnVideoState(event)
  ? "OnVideoState " + m.video.state
end sub
