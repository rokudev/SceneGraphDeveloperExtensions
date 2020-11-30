' Copyright (c) 2020 Roku, Inc. All rights reserved.

sub Init()
    m.focus = m.top.FindNode("focus")
    m.layout = m.top.FindNode("layout")
    m.poster = m.top.FindNode("poster")
    m.title = m.top.FindNode("title")
    m.sizeLabel = m.top.FindNode("sizeLabel")

    m.horizSpacing = 20
    m.vertSpacing = 5
    m.itemSpacing = 10

    m.layout.itemSpacings = [m.itemSpacing]
end sub

sub updateLayout()
    width = m.top.width
    height = m.top.height
    if width > 0 and height > 0
        m.focus.width = width
        m.focus.height = height
        m.layout.translation = [m.horizSpacing, height/2]

        parent = Utils_getParentbyIndex(1, m.top)
        if parent <> invalid and parent.posterShape <> invalid
            m.poster.shape = parent.posterShape
        end if
        posterHeight = height - m.vertSpacing*2
        m.poster.maxHeight = posterHeight

        freeSpace = (width - m.horizSpacing*2 - m.itemSpacing*2 - m.poster.width)
        m.title.maxWidth = Cint(freeSpace*0.62)
        m.sizeLabel.width = Cint(freeSpace*0.38)
    end if
end sub

sub onItemFocusChanged()
    itemHasFocus = (m.top.listHasFocus = true and m.top.focusPercent > 0.9)
    if itemHasFocus
        m.title.color = "0x000000"
        m.title.repeatCount = -1 ' enable scrolling
        m.sizeLabel.color = "0x000000"
    else ' item without focus
        ' check if list lost focus
        if m.top.listHasFocus = false
            m.focus.opacity = 0
        end if
        m.title.color = "0xffffff"
        m.title.repeatCount = 0 ' disable scrolling
        m.sizeLabel.color = "0xffffff"
    end if
end sub

sub itemContentChanged()
    itemContent = m.top.itemContent
    if itemContent <> invalid
        m.poster.uri = itemContent.hdposterurl
        m.title.text = itemContent.title
        m.sizeLabel.text = itemContent.SHORTDESCRIPTIONLINE2
    end if
end sub
