' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub show(args as Object)
    m.grid = CreateObject("roSGNode", "GridView")
    m.grid.Update({
        style: "square"
        posterShape: "square"
    })
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        HandlerConfigGrid: {
            name: "CHRoot"
        }
    }, true)

    m.grid.overhang.showOptions = false

    m.grid.content = content

    m.grid.ObserveField("rowItemSelected","OnGridItemSelected")

    'this will trigger job to show this screen
    m.top.ComponentController.callFunc("show", {
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

sub OnGridItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.getdata()
    rowContent = grid.content.getChild(selectedIndex[0])
    itemContent = rowContent.GetChild(selectedIndex[1])
    detailsScreen = ShowDetailsScreen(rowContent, selectedIndex[1])
    detailsScreen.ObserveField("wasClosed", "OnDetailsWasClosed")
end sub

sub OnDetailsWasClosed(event as Object)
    details = event.GetRoSGNode()
    m.grid.jumpToRowItem = [m.grid.rowItemFocused[0], details.itemFocused]
end sub
