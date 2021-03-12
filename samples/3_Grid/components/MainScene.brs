' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub Show(args as Object)
    ' Create an GridView object and assign some fields
    m.grid = CreateObject("roSGNode", "GridView")
    m.grid.SetFields({
        style: "standard"
        posterShape: "16x9"
    })
    content = CreateObject("roSGNode", "ContentNode")
    ' This tells the GridView where to go to fetch the content
    content.AddFields({
        HandlerConfigGrid: {
            name: "GridHandler"
        }
    })
    m.grid.content = content
    ' This will run the content handler and show the Grid
    m.top.ComponentController.CallFunc("show", {
        view: m.grid
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

