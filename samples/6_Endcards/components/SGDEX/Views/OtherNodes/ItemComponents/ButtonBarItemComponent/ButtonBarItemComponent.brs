' Copyright (c) 2019 Roku, Inc. All rights reserved.

sub init()
    m.label = m.top.findNode("title")
    m.poster = m.top.findNode("poster")
    m.posterTitleGroup = m.top.findNode("posterTitleGroup")

    m.roundedRectangle = m.top.findNode("roundedRectangle")

    m.buttonBar = m.top.GetScene().buttonBar
    m.enableFootprint = m.buttonBar.enableFootprint
    m.footprintStyle = m.buttonBar.footprintStyle
    m.buttonBar.ObserveFieldScoped("theme", "SaveColors")
    SaveColors()
    m.buttonBar.ObserveFieldScoped("enableFootprint", "OnEnableFootprintChange")

    m.top.ObserveFieldScoped("focusPercent", "HandleFocus")
    m.top.ObserveFieldScoped("itemHasFocus", "HandleFocus")
    m.top.ObserveFieldScoped("rowListHasFocus", "HandleFocus")

    m.isItemSelected = false ' catch press interaction
    ' Item component constants
    m.padding = 15 ' for m.posterTitleGroup
end sub

sub OnContentSet()
    content = m.top.itemContent
    if content <> invalid
        m.poster.uri = content.hdPosterUrl
        m.label.text = content.title
        alignPosterLabelSizes(m.poster.uri, m.label.text)
        HandleItemSelection(content.itemSelected)
    end if
end sub

sub HandleItemSelection(isItemSelected as Object)
    if isItemSelected <> invalid
        m.isItemSelected = isItemSelected
        if isItemSelected = false
            UnfocusButton(0.0)
        end if
    end if
end sub

sub OnWidthChange()
    m.roundedRectangle.width = m.top.width
end sub

sub OnHeightChange()
    m.roundedRectangle.height = m.top.height

    m.poster.height = m.top.height
    m.poster.width = m.top.height
    m.label.height = m.top.height

    if m.top.height > 200
        m.padding = m.padding * 2
        m.posterTitleGroup.itemSpacings = [m.padding]
    end if
end sub

sub alignPosterLabelSizes(posterUri as String, labelText as String)
    if isnonemptystr(posterUri) and isnonemptystr(labelText)
        ' both poster and label were set
        setTitleLabelStyle(m.top.width - m.poster.width, m.top.height)
    else if isnonemptystr(labelText)
        ' only label
        m.poster.width = 0
        setTitleLabelStyle(m.top.width, m.top.height)
    end if
end sub

sub setTitleLabelStyle(width as Integer, height as Integer)
    if height > 0 and width > 0
        m.label.translation = [m.padding, m.padding]
        m.label.width = width - m.padding * 2
    end if
end sub

sub SaveColors()
    theme = m.buttonBar.theme

    if theme.buttonColor <> invalid
        m.buttonColor = theme.buttonColor
    else
        m.buttonColor = "0x434247"
    end if

    if theme.buttonTextColor <> invalid
        m.buttonTextColor = theme.buttonTextColor
    else if theme.textColor <> invalid
        m.buttonTextColor = theme.textColor
    else
        m.buttonTextColor = "0xffffff"
    end if

    if theme.focusedButtonColor <> invalid
        m.focusedButtonColor = theme.focusedButtonColor
    else if theme.focusRingColor <> invalid
        m.focusedButtonColor = theme.focusRingColor
    else
        m.focusedButtonColor = "0xffffff"
    end if

    if theme.focusedButtonTextColor <> invalid
        m.focusedButtonTextColor = theme.focusedButtonTextColor
    else if theme.textColor <> invalid
        m.focusedButtonTextColor = theme.textColor
    else
        m.focusedButtonTextColor = "0x000000"
    end if

    if theme.footprintButtonColor <> invalid
        m.footprintButtonColor = theme.footprintButtonColor
    else
        m.footprintButtonColor = "0xffffff73"
    end if

    if theme.footprintButtonTextColor <> invalid
        m.footprintButtonTextColor = theme.footprintButtonTextColor
    else if theme.textColor <> invalid
        m.footprintButtonTextColor = theme.textColor
    else
        m.footprintButtonTextColor = "0xffffff"
    end if
    ResetColors()
end sub

sub ResetColors()
    m.roundedRectangle.backgroundColor = m.buttonColor
    m.roundedRectangle.backgroundFocusedColor = m.focusedButtonColor
    m.label.color = m.buttonTextColor
    if m.top.focusPercent > 0.9 and m.enableFootprint
        m.roundedRectangle.backgroundFocusedColor = m.footprintButtonColor
        m.roundedRectangle.backgroundColor = m.footprintButtonColor
        m.label.color = m.footprintButtonTextColor
        m.roundedRectangle.showFootprint = true
    end if
end sub

sub OnEnableFootprintChange(event as Object)
    m.enableFootprint = event.GetData()
    HandleFocus()
end sub

sub HandleFocus()
    focusPercent = m.top.focusPercent

    rowListHasFocus = m.top.rowListHasFocus
    itemHasFocus = m.top.itemHasFocus
    itemFocused = focusPercent > 0.9
    if rowListHasFocus ' when navigating withing button bar
        if itemFocused
            FocusButton(focusPercent)
        else
            if m.footprintStyle = "selection" and m.isItemSelected
                ShowFootprint()
            else
                UnfocusButton(focusPercent)
            end if
        end if
    else ' when navigating between BB and view
        if m.enableFootprint
            if m.footprintStyle = "selection" and m.isItemSelected
                ShowFootprint()
            else if focusPercent > 0.9
                ShowFootprint()
            else
                UnfocusButton(0.0)
            end if
        else
            UnfocusButton(0.0)
        end if
    end if
end sub

' pass focusPercent as param because this function
' is called multiple times with changing of component focusPercent
' this allows to perform smooth animation when navigating within BB
sub FocusButton(focusPercent as Float)
    m.roundedRectangle.focusPercent = focusPercent
    m.roundedRectangle.backgroundFocusedColor = m.focusedButtonColor
    m.roundedRectangle.backgroundColor = m.focusedButtonColor
    m.label.color = m.focusedButtonTextColor
end sub

sub UnfocusButton(focusPercent as Float)
    m.roundedRectangle.focusPercent = focusPercent
    m.roundedRectangle.backgroundColor = m.buttonColor
    m.label.color = m.buttonTextColor
end sub

sub ShowFootprint()
    m.roundedRectangle.backgroundFocusedColor = m.footprintButtonColor
    m.roundedRectangle.backgroundColor = m.footprintButtonColor
    m.label.color = m.footprintButtonTextColor
    m.roundedRectangle.showFootprint = true
end sub
