' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub OpenVideoView(content as Object, index as Integer)
    video = CreateObject("roSGNode", "MediaView")
    video.content = content
    video.jumpToItem = index
    m.top.ComponentController.CallFunc("show", {
        view: video
    })
    video.control = "play"
end sub
