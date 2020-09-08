' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub Init()
    m.timegrid = m.top.FindNode("contentTimeGrid")
    m.title = m.top.FindNode("title")
    m.description = m.top.FindNode("description")
    m.poster = m.top.FindNode("poster")

    ' By observing the programFocused field, we can react to the user
    ' navigating around the TimeGrid. in this sample, the observer function
    ' updates the metadata on the top half of the screen
    m.timegrid.ObserveField("programFocused", "OnProgramFocused")

    currentTime = CreateObject("roDateTime")

    ' Setup some initial field values on the TimeGrid
    m.timegrid.Update({
        contentStartTime: currentTime.AsSeconds()
        leftEdgeTargetTime: currentTime.AsSeconds()
    }, true)
end sub

' This observer function is called as the user navigates around the TimeGrid
sub OnProgramFocused(event as Object)
    currentRowIndex = m.timegrid.channelFocused
    currentItemIndex = m.timegrid.programFocused

    row = invalid
    if m.timegrid.content <> invalid then
        row = m.timegrid.content.GetChild(currentRowIndex)
    end if

    if row <> invalid
        if currentItemIndex < 0 then currentItemIndex = 0

        ' update the metadata on the top half of the screen to reflect the focused program
        if m.timegrid.content.GetChild(currentRowIndex).GetChild(currentItemIndex) <> invalid
            m.title.text = m.timegrid.content.GetChild(currentRowIndex).GetChild(currentItemIndex).title
            m.description.text = m.timegrid.content.GetChild(currentRowIndex).GetChild(currentItemIndex).description

            ' The data in this sample does not include posters
            ' If you were working with data that included that data,
            ' this is one possible way you could update the poster
            ' poster =  m.timegrid.content.GetChild(currentRowIndex).GetChild(currentItemIndex).hdSmallIconUrl
            ' if poster <> "" then m.poster.uri = poster
        end if
    end if
end sub
