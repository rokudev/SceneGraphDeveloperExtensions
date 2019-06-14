' Copyright (c) 2019 Roku, Inc. All rights reserved.

sub Init()
    m.title = m.top.findNode("title")
    m.poster = m.top.findNode("poster")
    m.poster.ObserveField("loadStatus", "OnPosterLoadStatusChanged")

    m.top.ObserveField("content","OnContentSet")
    m.top.ObserveField("width","OnLayoutChanged")
    m.top.ObserveField("height","OnLayoutChanged")

    m.horizontalMargin = 5
    m.verticalMargin = 7
    m.title.translation = [m.horizontalMargin, m.verticalMargin]
    m.poster.translation = [m.horizontalMargin, m.verticalMargin]
end sub

sub OnContentSet()
    content = m.top.content
    if content <> invalid
        m.title.text = content.title
        posterUrl = content.HDSMALLICONURL
        if posterUrl = invalid or posterUrl = "" then posterUrl = content.HDPOSTERURL
        m.poster.uri = posterUrl
    end if
end sub

sub OnLayoutChanged(event as Object)
    renderingWidth = m.top.width - m.horizontalMargin * 2
    renderingHeight = m.top.height - m.verticalMargin * 2

    m.poster.width = renderingWidth
    m.poster.height = renderingHeight
    m.poster.loadWidth = renderingWidth
    m.poster.loadheight = renderingHeight
    m.title.width = renderingWidth
    m.title.height = renderingHeight
end sub

sub OnPosterLoadStatusChanged(event as Object)
    loadStatus = event.getData()
    if loadStatus = "ready"
        m.title.visible = false
    end if
end sub
