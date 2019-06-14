' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

'This is logic for video playback
function OpenVideoPlayer(content as Object, index as Integer, isContentList as Boolean) as Object
    video = CreateObject("roSGNode", "VideoView")
    content.AddFields({
            HandlerConfigEndcard: {
            name: "CGEndcard"
            fields: {
                param: "Supre cinema"
                currentItemContent: content
            }
        }
    })
    video.content = content
    video.jumpToItem = index
    video.isContentList = isContentList
    video.control = "play"
    m.isEndcardShown = true

    video.currentItem.AddFields({
            HandlerConfigEndcard: {
            name: "CGEndcard"
            fields: {
                param: "Supre cinema"
                currentItemContent: content
            }
        }
    })
    m.top.ComponentController.CallFunc("show", {
        view: video
    })
    return video
end function

function OpenVideoPlayerItem(contentItem as Object) as Object
    video = CreateObject("roSGNode", "VideoView")
    video.content = contentItem
    video.isContentList = false
    video.control = "play"
    m.isEndcardShown = true
    m.top.ComponentController.CallFunc("show", {
        view: video
    })
    return video
end function
