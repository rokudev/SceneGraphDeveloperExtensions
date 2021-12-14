' Copyright (c) 2020-2021 Roku, Inc. All rights reserved.

sub OnRowFocusPercentChanged(event as Object)
    focus = event.getData()
    updateAndApplyTheme()
    title = m.top.FindNode("title")
    poster = m.top.FindNode("poster")
    if focus > 0.9
        title.color = m.top.focusedItemTextColor
        title.font = "font:SmallBoldSystemFont"
        poster.opacity = focus
        poster.blendColor = m.top.focusedItemFrameColor
    else
        title.color = m.top.unfocusedItemTextColor
        title.font = "font:SmallSystemFont"
        poster.opacity = focus
    end if
end sub

sub OnHeightChaged(event as Object)
    height = event.getData()
    if height <> invalid and height > 0
        m.top.FindNode("poster").height = height
    end if
end sub

sub OnWidthChanged(event as Object)
    width = event.getData()
    if width <> invalid and width > 0
        m.top.FindNode("poster").width = width
        m.top.FindNode("title").width = (width - 40)
    end if
end sub


sub itemContentChanged(event as Object)
    content = event.getData()

    if content <> invalid
        m.top.FindNode("title").text = content.title
    end if
end sub

sub updateAndApplyTheme()
    parent = Utils_getParentbyIndex(5, m.top)
    if parent <> invalid
        theme = parent.theme
        if theme <> invalid and theme.Count() > 0
            if theme.DoesExist("buttonsfocusRingColor")
                m.top.focusedItemFrameColor = theme.LookupCI("buttonsFocusRingColor")
            end if
            if theme.DoesExist("textColor")
                m.top.focusedItemTextColor = theme.LookupCI("textColor")
                m.top.unfocusedItemTextColor = theme.LookupCI("textColor")
            end if
            if theme.DoesExist("buttonsFocusedColor")
                m.top.focusedItemTextColor = theme.LookupCI("buttonsFocusedColor")
            end if
            if theme.DoesExist("buttonsUnFocusedColor")
                m.top.unfocusedItemTextColor = theme.LookupCI("buttonsUnfocusedColor")
            end if
        end if

        title = m.top.FindNode("title")
        poster = m.top.FindNode("poster")
        if m.top.rowFocusPercent > 0.9
            title.color = m.top.focusedItemTextColor
            title.font = "font:SmallBoldSystemFont"
            poster.opacity = m.top.rowFocusPercent
            poster.blendColor = m.top.focusedItemFrameColor
        else
            title.color = m.top.unfocusedItemTextColor
            title.font = "font:SmallSystemFont"
            poster.opacity = m.top.rowFocusPercent
        end if
    end if
end sub
