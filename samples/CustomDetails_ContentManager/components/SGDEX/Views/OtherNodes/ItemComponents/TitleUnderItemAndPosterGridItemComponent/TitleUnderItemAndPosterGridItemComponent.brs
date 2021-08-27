' Copyright (c) 2018-2021 Roku, Inc. All rights reserved.

sub onContentSet()
    content = m.top.itemContent
    poster = m.top.findNode("poster")
    title = m.top.findNode("title")
    if content <> invalid
        poster.uri = content.hdPosterUrl
        title.text = content.title
    end if
    
    parent = Utils_getParentbyIndex(3, m.top)
    if parent <> invalid AND parent.itemTextColorLine1 <> invalid
        title.color = parent.itemTextColorLine1
    end if
end sub

sub onWidthChange()
    poster = m.top.findNode("poster")
    poster.width = m.top.width
    poster.loadWidth = m.top.width
    setTitleLabelStyle(m.top.width,m.top.height)
end sub

sub onHeightChange()
    poster = m.top.findNode("poster")
    poster.height = m.top.height
    poster.loadHeight = m.top.height
    setTitleLabelStyle(m.top.width,m.top.height)
end sub

sub setTitleLabelStyle(width as Integer, height as Integer)
    if height > 0 and width > 0
        padding = 5
        font = "font:SmallSystemFont"
        if height > 200 ' big size
            padding = 10
            font = "font:MediumSystemFont"
        end if
        title = m.top.FindNode("title")
        title.translation = [padding,padding + 50]
        title.height      = height - padding * 2
        title.width       = width  - padding * 2
        title.font        = font
    end if
end sub
