' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

sub Show(args as Object)
    ' Create a GridView object and setup UI of view
    grid = CreateObject("roSGNode", "GridView") 
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
    grid.content = content

    ' Set Callback to the rowItemSelected field to handle a result of seleceted item
    grid.ObserveField("rowItemSelected", "OnGridItemSelected")

    ' Push the GridView object to the stack to show on the screen
    m.top.ComponentController.CallFunc("show", {
        view: grid
    })
    
    ' Handle a launch deep linking arguments 
    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if

    ' Fire an AppLaunchComplete beacon as it required for channel application 
    m.top.signalBeacon("AppLaunchComplete")
end sub

sub Input(args as object)
    ' handle roInput event deep linking
    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if
end sub

' Callback function to handle a result of selection item from grid
' If user selects and item from the first row of the grid we will be using
' the native endcard for playback, otherwise - the custom endcard
sub OnGridItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.GetData()
    row = grid.content.GetChild(selectedIndex[0])
    
    ' assume usage of the custom endcard for further playback
    ' if that was an item not from the 1st row
    m.useCustomEndcard = selectedIndex[0] <> 0
    
    ' open the DetailsView
    ShowDetailsView(row, selectedIndex[1])
end sub
