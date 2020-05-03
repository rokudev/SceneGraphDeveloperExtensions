' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' This is the main entry point to the channel scene.
' This function will be called by library when channel is ready to be shown.
sub show(args as Object)
    customView = CreateObject("roSGNode","CustomZoomRowList")

    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        HandlerConfigGrid: {
            name: "CHRoot"
        }
    }, true)

    customView.content = content

    m.top.ComponentController.callFunc("show", {
        view: customView
    })
    
    m.top.signalBeacon("AppLaunchComplete")
end sub
