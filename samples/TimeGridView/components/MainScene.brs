' Copyright (c) 2019 Roku, Inc. All rights reserved.

' This is the main entry point to the channel scene.
' This function will be called by SGDEX when channel is ready to be shown.
sub Show(args as Object)
    ' create our TimeGridView
    grid = CreateObject("roSGNode", "TimeGridView")

    ' put a handler config on the root node of the tree
    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
        HandlerConfigTimeGrid: {
            name: "CHRoot"
        }
    })

    ' set content to the view
    grid.content = content

    ' this will trigger job to show this screen
    m.top.ComponentController.CallFunc("show", {
        view: grid
    })

    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if

    m.top.signalBeacon("AppLaunchComplete")
end sub

sub Input(args as object)
    ' handle roInput event deep linking
    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if
end sub
