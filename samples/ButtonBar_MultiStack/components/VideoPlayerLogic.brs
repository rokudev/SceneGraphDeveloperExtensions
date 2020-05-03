' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

function OpenVideoPlayerItem(contentItem as Object) as Object
    m.top.buttonBar.visible = false ' hide button bar on MediaView

    ' Create MediaView Object and set its fields
    video = CreateObject("roSGNode", "MediaView")
    video.ObserveField("wasClosed", "OnMediaViewWasClosed")

    video.content = contentItem
    video.isContentList = false
    ' Set it to start playing, it wont begin playback until show() is called
    video.control = "play"
    ' Show the media view
    m.top.ComponentController.CallFunc("show", {
        view: video
    })
    return video
end function

sub OnMediaViewWasClosed()
    ' Because ButtonBar is a global component,
    ' we need to restore its visibility to show back on previous view
    m.top.buttonBar.visible = true
end sub
