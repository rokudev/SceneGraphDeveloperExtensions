' This is logic for video playback
function OpenVideoPlayer(content, index) as Object
    video = CreateObject("roSGNode", "VideoView")

    video.content = content
    video.jumpToItem = index
    video.control = "play"

    m.top.ComponentController.callFunc("show", {
        view: video
    })

    return video
end function
