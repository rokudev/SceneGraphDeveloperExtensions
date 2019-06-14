' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

' There are two functions depending on whether or not a focus index and isContentList are provided
function OpenVideoPlayer(content as Object, index as Integer, isContentList as Boolean) as Object
    ' Create VideoView Object and set its fields
    video = CreateObject("roSGNode", "VideoView")
    video.ObserveField("endcardItemSelected", "OnEndcardItemSelected")
    video.content = content
    video.jumpToItem = index
    video.isContentList = isContentList
    ' Show the video view
    m.top.ComponentController.CallFunc("show", {
        view: video
    })
    video.control = "play"
    return video
end function

function OpenVideoPlayerItem(contentItem as Object) as Object
    ' Create VideoView Object and set its fields
    video = CreateObject("roSGNode", "VideoView")
    contentItem.AddFields({
        HandlerConfigEndcard: {
            name: "EndcardHandler"
        }
    })
    video.content = contentItem
    video.isContentList = false
    video.ObserveField("endcardItemSelected", "OnEndcardItemSelected")
    ' Adding the endcard handler to the video
    ' Show the video view
    m.top.ComponentController.CallFunc("show", {
        view: video
    })
    ' Set it to start playing
    video.control = "play"
    return video
end function

sub OnEndcardItemSelected(event as Object)
    item = event.GetData()
    video = event.GetRoSGNode()
    video.UnobserveField("endcardItemSelected")
    video.close = true

    if item.url <> invalid
        video = OpenVideoPlayerItem(item)
        video.ObserveField("endcardItemSelected", "OnEndcardItemSelected")
    end if
    ' ? "OnEndcardItemSelected item == "; item
end sub
