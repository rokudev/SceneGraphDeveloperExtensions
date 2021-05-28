' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

sub Init()
    ' Cache children to m for work with them in observers
    m.playBar = m.top.FindNode("playBar")
    m.progressBar = m.top.FindNode("progress")
    m.progressWell = m.top.FindNode("progressWell")
    m.progressLabel = m.top.FindNode("progressLabel")
    m.title = m.top.FindNode("title")
    m.poster = m.top.FindNode("poster")
    m.description = m.top.FindNode("description")

    ' Set Observes for m.top interfaces from the view fields
    m.top.ObserveFieldScoped("position","OnPositionChanged")
    m.top.ObserveFieldScoped("currentItem", "OnCurrentItemChanged")
end sub

' Callback function to update data on the HUD
sub OnCurrentItemChanged(event as Object)
    currentItem = event.getData()
    if currentItem <> invalid
        ' For audio mode show poster at the middle
        if m.top.mode = "audio"
            m.poster.uri = currentItem.hdPosterUrl
        end if
        ' Updating texts for description and title label
        m.title.text = currentItem.title
        m.description.text = currentItem.description
        ' Hide a play bar to avoid showing empty
        m.playBar.visible = false
        m.progressLabel.visible = false
    end if
end sub

' Callback function to update data on the playbar
sub OnPositionChanged(event as Object)
    p = event.getData()
    ' Do not show a playbar when we don't have a duration of playback
    if m.top.duration = 0
        m.playBar.visible = false
        m.progressLabel.visible = false
    else
        m.playBar.visible = true
        m.progressLabel.visible = true
        ' Update a position on the time label
        m.progressLabel.text = p.ToStr() + " of " +  m.top.duration.ToStr() + " seconds"
        ' Calculate a position changing for increase the width of filling rectangle to show the current position of playback
        progress = p / m.top.duration
        if progress >= 1 then progress = 1
        w = m.progressWell.width * progress
        if w < 2 then w = 2
        m.progressBar.width = w
    end if
end sub