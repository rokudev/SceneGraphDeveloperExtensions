' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

function OnItemContentChanged()
    if m.top.itemContent <> invalid
        m.top.FindNode("titleLabel").text = m.top.itemContent.title
        m.top.FindNode("icon").uri = m.top.itemContent.iconUri
        m.top.GetParent().ObserveFieldScoped("itemSize", "OnItemSizeChanged")
    end if
end function

sub OnGridFocusChanged(event as Object)
    isGridHasFocus = event.GetData()
    focusedItemHint = m.top.FindNode("focusedItemHint")
    if isGridHasFocus
        focusedItemHint.color="0x9e0bb5"
    else
        focusedItemHint.color="0xe3e3e3"
    end if
end sub

sub OnItemSizeChanged(event as Object)
    itemSize = event.GetData()
    if itemSize <> invalid
        m.top.FindNode("focusedBackground").width = itemSize[0]
        m.top.FindNode("focusedBackground").height = itemSize[1]
        m.top.FindNode("focusedItemHint").height = itemSize[1]
        m.top.FindNode("titleLabel").width = itemSize[0]
    end if
end sub

sub OnHeightChanged()
    m.top.FindNode("focusedBackground").height = m.top.height
    m.top.FindNode("focusedItemHint").height = m.top.height
end sub

sub OnWidthChanged()
    m.top.FindNode("focusedBackground").width = m.top.width
end sub

sub OnFocusPercentChanged(event as Object)
    opacity = event.GetData()
    if m.top.gridHasFocus
        m.top.FindNode("focusedItemHint").opacity = opacity
        m.top.FindNode("focusedBackground").opacity = opacity
    end if
end sub