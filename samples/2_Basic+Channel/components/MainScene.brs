' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub Show(args as Object)
    m.grid = CreateObject("roSGNode", "GridView")
    m.grid.SetFields({
        style: "standard"
        posterShape: "16x9"
    })
    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
        HandlerConfigGrid: {
            name: "RootHandler"
        }
    })
    m.grid.content = content
    m.grid.ObserveField("rowItemSelected", "OnGridItemSelected")

    m.top.ComponentController.CallFunc("show", {
        view: m.grid
    })

    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if

    m.top.signalBeacon("AppLaunchComplete")
end sub

sub OnGridItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.GetData()
    rowContent = grid.content.GetChild(selectedIndex[0])
    detailsView = ShowDetailsView(rowContent, selectedIndex[1])
    detailsView.ObserveField("wasClosed", "OnDetailsWasClosed")
end sub

sub OnDetailsWasClosed(event as Object)
    details = event.GetRoSGNode()
    m.grid.jumpToRowItem = [m.grid.rowItemFocused[0], details.itemFocused]
end sub

sub Input(args as object)
    ' handle roInput event deep linking
    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if
end sub
