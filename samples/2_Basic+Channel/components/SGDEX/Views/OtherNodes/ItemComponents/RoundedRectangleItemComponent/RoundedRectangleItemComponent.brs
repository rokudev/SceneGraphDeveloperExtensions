' Copyright (c) 2019 Roku, Inc. All rights reserved.

sub init()
    m.posterLeft = m.top.findNode("posterLeft")
    m.posterRight = m.top.findNode("posterRight")
    m.focusedPosterLeft = m.top.findNode("focusedPosterLeft")
    m.focusedPosterRight = m.top.findNode("focusedPosterRight")

    m.background = m.top.findNode("background")
    m.backgroundFocused = m.top.findNode("backgroundFocused")
    m.backgroundGroup = m.top.findNode("backgroundGroup")

    m.top.ObserveFieldScoped("width", "OnWidthChange")
    m.top.ObserveFieldScoped("height", "OnHeightChange")
    m.top.ObserveFieldScoped("focusPercent", "OnFocusPercentChange")
    m.top.ObserveFieldScoped("showFootprint", "showFootprint")
end sub

sub OnWidthChange()
    posterWidth = 8
    m.posterLeft.width = posterWidth
    m.posterRight.width = posterWidth
    m.focusedPosterLeft.width = posterWidth
    m.focusedPosterRight.width = posterWidth

    backgroundWidth = m.top.width - m.posterLeft.width * 2
    m.background.width = backgroundWidth
    m.backgroundFocused.width = backgroundWidth

    m.backgroundGroup.translation = [m.posterLeft.width, 0]

    posterRightTransl = m.background.width + m.posterLeft.width
    m.posterRight.translation = [posterRightTransl, 0]
    m.focusedPosterRight.translation = [posterRightTransl, 0]
end sub

sub OnHeightChange()
    posterHeight = m.top.height + 0.5
    m.posterLeft.height = posterHeight
    m.posterRight.height = posterHeight
    m.focusedPosterLeft.height = posterHeight
    m.focusedPosterRight.height = posterHeight

    m.background.height = m.top.height
    m.backgroundFocused.height = m.top.height
end sub

sub OnFocusPercentChange(event as Object)
    focusPercent = event.GetData()

    m.backgroundFocused.opacity = focusPercent
    m.focusedPosterLeft.opacity = focusPercent
    m.focusedPosterRight.opacity = focusPercent
end sub

sub showFootprint(event as Object)
    isFootprint = event.GetData()
    focusPercent = 0.0 ' default value (do not show footprint)
    if isFootprint
        focusPercent = 0.3
    end if

    m.backgroundFocused.opacity = focusPercent
    m.focusedPosterLeft.opacity = focusPercent
    m.focusedPosterRight.opacity = focusPercent
end sub