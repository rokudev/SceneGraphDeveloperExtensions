' ********** Copyright 2017 Roku Corp.  All Rights Reserved. **********

'This is the main entry point to the channel scene.
'This function will be called by library when channel is ready to be shown.
sub show(args as Object)
    m.grid = CreateObject("roSGNode", "GridView")
    m.grid.setFields({
        style: "standard"
        posterShape: "16x9"
    })
    content = CreateObject("roSGNode", "ContentNode")
    content.addfields({
        HandlerConfigGrid: {
            name: "CGRoot"
        }


    })

    m.grid.ObserveField("rowItemSelected","OnGridItemSelected")

    m.grid.content = content

    'this will trigger job to show this screen
    m.top.ComponentController.callFunc("show", {
        view: m.grid
    })
end sub


sub OnGridItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.getdata()
    rowContent = grid.content.getChild(selectedIndex[0])

    detailsScreen = ShowDetailsScreen(rowContent, selectedIndex[1])
    detailsScreen.ObserveField("wasClosed", "OnDetailsWasClosed")
end sub

sub OnDetailsWasClosed(event as Object)
    details = event.GetRoSGNode()
    m.grid.jumpToRowItem = [m.grid.rowItemFocused[0], details.itemFocused]
end sub
