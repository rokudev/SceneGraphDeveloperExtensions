' Copyright (c) 2020 Roku, Inc. All rights reserved.

sub Init()
    m.poster = m.top.FindNode("poster")
    m.title = m.top.FindNode("title")

    m.top.ObserveFieldScoped("height", "OnHeightChaged")
    m.top.ObserveFieldScoped("width", "OnWidthChanged")
    m.top.ObserveFieldScoped("rowFocusPercent", "OnRowFocusPercentChanged")

    m.focusedItemTextColor = "0x000000ff"
    m.unfocusedItemTextColor = "0xffffffff"
    m.focusedItemFrameColor = "0xa0a0a0ff"
    updateAndApplyTheme()
end sub

sub OnRowFocusPercentChanged(event as Object)
    focus = event.getData()
    updateAndApplyTheme()
    if focus > 0.9
        m.title.color = m.focusedItemTextColor
        m.title.font = "font:SmallBoldSystemFont"
        m.poster.opacity = focus
        m.poster.blendColor = m.focusedItemFrameColor
    else
        m.title.color = m.unfocusedItemTextColor
        m.title.font = "font:SmallSystemFont"
        m.poster.opacity = focus
    end if
end sub

sub OnHeightChaged(event as Object)
    height = event.getData()
    if height <> invalid and height > 0
        m.poster.height = height
    end if
end sub

sub OnWidthChanged(event as Object)
    width = event.getData()
    if width <> invalid and width > 0
        m.poster.width = width
        m.title.width = width
    end if
end sub


sub itemContentChanged(event as Object)
    content = event.getData()

    if content <> invalid
        m.title.text = content.title
    end if
end sub

sub updateAndApplyTheme()
    m.parent = Utils_getParentbyIndex(5, m.top)
    if m.parent <> invalid
        theme = m.parent.theme
        if theme <> invalid and theme.Count() > 0
            if theme.DoesExist("buttonsfocusRingColor")
                m.focusedItemFrameColor = theme.LookupCI("buttonsFocusRingColor")
            end if
            if theme.DoesExist("textColor")
                m.focusedItemTextColor = theme.LookupCI("textColor")
                m.unfocusedItemTextColor = theme.LookupCI("textColor")
            end if
            if theme.DoesExist("buttonsFocusedColor")
                m.focusedItemTextColor = theme.LookupCI("buttonsFocusedColor")
            end if
            if theme.DoesExist("buttonsUnFocusedColor")
                m.unfocusedItemTextColor = theme.LookupCI("buttonsUnfocusedColor")
            end if
        end if

        if m.top.rowFocusPercent > 0.9
            m.title.color = m.focusedItemTextColor
            m.title.font = "font:SmallBoldSystemFont"
            m.poster.opacity = m.top.rowFocusPercent
            m.poster.blendColor = m.focusedItemFrameColor
        else
            m.title.color = m.unfocusedItemTextColor
            m.title.font = "font:SmallSystemFont"
            m.poster.opacity = m.top.rowFocusPercent
        end if
    end if
end sub
