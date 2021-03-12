' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub Show(args as Object)
    grid = CreateObject("roSGNode", "GridView")

    ' setup UI of view
    grid.SetFields({
        posterShape: "16x9"
    })

    ' This is root content that describes how to populate rest of rows
    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
        HandlerConfigGrid: {
            name: "CHRoot"
        }
    })
    grid.ObserveField("rowItemSelected", "OnGridItemSelected")
    grid.content = content

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

sub OnGridItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.GetData()
    row = grid.content.GetChild(selectedIndex[0])
    detailsView = ShowDetailsView(row, selectedIndex[1])
end sub
