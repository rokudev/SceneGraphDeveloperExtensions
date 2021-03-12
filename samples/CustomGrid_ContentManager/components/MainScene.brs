' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

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
    customView.ObserveFieldScoped("rowItemSelected","OnRowItemSelected")
    m.top.ComponentController.callFunc("show", {
        view: customView
    })

    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if

    m.top.signalBeacon("AppLaunchComplete")
end sub

sub OnRowItemSelected(event as Object)
    item = event.getData()
    view = event.getRoSGNode()
    row = view.content.getChild(item[0])
    itemSelected = row.getChild(item[1])
    if itemSelected.title.Len() > 0 and (row.title = "Video" or row.title = "Audio")
        OpenMediaScreen(LCase(row.title), itemSelected)
    end if
end sub

sub Input(args as object)
    ' handle roInput event deep linking
    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if
end sub
