' Copyright (c) 2018-2021 Roku, Inc. All rights reserved.

sub Init()
    m.top.FindNode("title").font.size = 20
    m.top.FindNode("description").font.size = 16

    parent = Utils_getParentbyIndex(1, m.top)
    parent.ObserveField("itemSize", "OnParentItemSizeChanged")
end sub

sub itemContentChanged()
    itemContent = m.top.itemContent
    parent = Utils_getParentbyIndex(1, m.top)
    
    poster = m.top.FindNode("poster")
    title = m.top.FindNode("title")
    description = m.top.FindNode("description")

    if itemContent <> invalid
        poster.uri = itemContent.hdPosterUrl
        title.text = itemContent.title
        description.text = itemContent.description
    end if

    if parent <> invalid
        if parent.itemTitleColor <> invalid
            title.color = parent.itemTitleColor
        end if
        if parent.itemDescriptionColor <> invalid
            description.color = parent.itemDescriptionColor
        end if
        if parent.posterShape <> invalid
            poster.shape = parent.posterShape
        end if
        'adjust description and title width according to posterShape
        width = parent.itemSize[0] - poster.width - 10
        title.width = width
        description.width = width
    end if
end sub

function OnParentItemSizeChanged(event as Object)
    ' respect parent item size change to accomodate title and description
    ' labels accordingly
    itemSize = event.GetData()
    if itemSize <> invalid
        poster = m.top.FindNode("poster")
        title = m.top.FindNode("title")
        description = m.top.FindNode("description")
 
        width = itemSize[0] - poster.width - 10
        title.width = width
        description.width = width
    end if
end function