' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub Show(args as Object)
    ' Create MediaView Object and set its fields
    video = CreateObject("roSGNode", "MediaView")
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        HandlerConfigMedia: {
            name: "VideoHandler"
        }
    },true)
    video.content = content
    video.isContentList = false
    ' Set it to start playing, it wont begin playback until show() is called
    video.control = "play"
    ' Show the media view
    m.top.ComponentController.CallFunc("show", {
        view: video
    })

    if args.contentId <> invalid and args.mediaType <> invalid
        ' Implement your deep linking logic. For more details, please see Roku_Recommends sample.
    end if

    m.top.signalBeacon("AppLaunchComplete")
end sub

sub Input(args as object)
    ' handle roInput event deep linking
    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if
end sub

