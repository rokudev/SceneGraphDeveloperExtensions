' Copyright (c) 2020-2021 Roku, Inc. All rights reserved.

sub updateLayout()
    width = m.top.width
    height = m.top.height
    if width > 0 and height > 0
        poster = m.top.FindNode("poster")
        focus = m.top.FindNode("focus")
        layout = m.top.FindNode("layout")
        horizSpacing = 20
        vertSpacing = 5
        itemSpacing = 10

        focus.width = width
        focus.height = height
        layout.translation = [horizSpacing, height/2]

        parent = Utils_getParentbyIndex(1, m.top)
        if parent <> invalid and parent.posterShape <> invalid
            poster.shape = parent.posterShape
        end if
        posterHeight = height - vertSpacing*2
        poster.maxHeight = posterHeight

        freeSpace = (width - horizSpacing*2 - itemSpacing*2 - poster.width)
        m.top.FindNode("title").maxWidth = Cint(freeSpace*0.62)
        m.top.FindNode("sizeLabel").width = Cint(freeSpace*0.38)
    end if
end sub

sub onItemFocusChanged()
    itemHasFocus = (m.top.listHasFocus = true and m.top.focusPercent > 0.9)
    title = m.top.FindNode("title")
    sizeLabel = m.top.FindNode("sizeLabel")
    focus = m.top.FindNode("focus")
    if itemHasFocus
        title.color = "0x000000"
        title.repeatCount = -1 ' enable scrolling
        sizeLabel.color = "0x000000"
    else ' item without focus
        ' check if list lost focus
        if m.top.listHasFocus = false
            focus.opacity = 0
        end if
        title.color = "0xffffff"
        title.repeatCount = 0 ' disable scrolling
        sizeLabel.color = "0xffffff"
    end if
end sub

sub itemContentChanged()
    itemContent = m.top.itemContent
    if itemContent <> invalid
        m.top.FindNode("poster").uri = itemContent.hdposterurl
        m.top.FindNode("title").text = itemContent.title
        m.top.FindNode("sizeLabel").text = itemContent.SHORTDESCRIPTIONLINE2
    end if
end sub
