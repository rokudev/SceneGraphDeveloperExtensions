' Copyright (c) 2019-2021 Roku, Inc. All rights reserved.

sub OnWidthChange()
    posterWidth = 8.0
    posterLeft = m.top.findNode("posterLeft")
    posterRight = m.top.findNode("posterRight")
    focusedPosterLeft = m.top.findNode("focusedPosterLeft")
    focusedPosterRight = m.top.findNode("focusedPosterRight")
    background = m.top.findNode("background")
    backgroundFocused = m.top.findNode("backgroundFocused")
    backgroundGroup = m.top.findNode("backgroundGroup")

    posterLeft.width = posterWidth
    posterRight.width = posterWidth
    focusedPosterLeft.width = posterWidth
    focusedPosterRight.width = posterWidth

    backgroundWidth = Cdbl(m.top.width) - Cdbl(posterLeft.width) * 2.0
    background.width = backgroundWidth
    backgroundFocused.width = backgroundWidth

    backgroundGroup.translation = [posterLeft.width, 0]

    posterRightTransl = background.width + posterLeft.width
    posterRight.translation = [posterRightTransl, 0]
    focusedPosterRight.translation = [posterRightTransl, 0]
end sub

sub OnHeightChange()
    posterHeight = m.top.height + 0.5
    m.top.findNode("posterLeft").height = posterHeight
    m.top.findNode("posterRight").height = posterHeight
    m.top.findNode("focusedPosterLeft").height = posterHeight
    m.top.findNode("focusedPosterRight").height = posterHeight

    m.top.findNode("background").height = posterHeight
    m.top.findNode("backgroundFocused").height = posterHeight
end sub

sub OnFocusPercentChange(event as Object)
    focusPercent = event.GetData()

    m.top.findNode("backgroundFocused").opacity = focusPercent
    m.top.findNode("focusedPosterLeft").opacity = focusPercent
    m.top.findNode("focusedPosterRight").opacity = focusPercent
end sub

sub showFootprint(event as Object)
    isFootprint = event.GetData()
    focusPercent = 0.0 ' default value (do not show footprint)
    if isFootprint
        focusPercent = 0.3
    end if

    m.top.findNode("backgroundFocused").opacity = focusPercent
    m.top.findNode("focusedPosterLeft").opacity = focusPercent
    m.top.findNode("focusedPosterRight").opacity = focusPercent
end sub