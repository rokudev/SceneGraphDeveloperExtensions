' Copyright (c) 2019-2021 Roku, Inc. All rights reserved.

sub init()
    scene = m.top.getScene()
    buttonBar = scene.buttonBar

    buttonBar.ObserveFieldScoped("theme", "SaveColors")
    scene.ObserveFieldScoped("theme", "SaveColors")
    SaveColors()
end sub

sub OnContentSet()
    content = m.top.itemContent
    label = m.top.findNode("title")
    poster =  m.top.findNode("poster")

    if content <> invalid
        m.top.isItemSelected = false
        poster.uri = content.hdPosterUrl
        label.text = content.title
        alignPosterLabelSizes(poster.uri, label.text)
        HandleItemSelection(content.itemSelected)
    end if
end sub

sub HandleItemSelection(isItemSelected as Object)
    if isItemSelected <> invalid
        m.top.isItemSelected = isItemSelected
        if isItemSelected = false
            UnfocusButton(0.0)
        end if
    end if
end sub

sub OnWidthChange()
    m.top.findNode("roundedRectangle").width = m.top.width
end sub

sub OnHeightChange()
    m.top.findNode("roundedRectangle").height = m.top.height

    poster = m.top.findNode("poster")
    poster.height = m.top.height
    poster.width = m.top.height
    m.top.findNode("title").height = m.top.height

    if m.top.height > 200
        m.top.padding = m.top.padding * 2
        m.top.findNode("posterTitleGroup").itemSpacings = [m.top.padding]
    end if
end sub

sub alignPosterLabelSizes(posterUri as String, labelText as String)
    poster = m.top.findNode("poster")
    if isnonemptystr(posterUri) and isnonemptystr(labelText)
        ' both poster and label were set
        setTitleLabelStyle(m.top.width - poster.width, m.top.height)
    else if isnonemptystr(labelText)
        ' only label
        poster.width = 0
        setTitleLabelStyle(m.top.width, m.top.height)
    end if
end sub

sub setTitleLabelStyle(width as Integer, height as Integer)
    if height > 0 and width > 0
        label = m.top.findNode("title")
        label.translation = [m.top.padding, m.top.padding]
        label.width = width - m.top.padding * 2
    end if
end sub

sub SaveColors()
    scene = m.top.GetScene()
    buttonBar = scene.buttonBar
    theme = {}

    if scene.theme <> invalid
        if scene.theme.global <> invalid then theme.Append(scene.theme.global)
        if scene.theme.buttonBar <> invalid then theme.Append(scene.theme.buttonBar)
    end if

    theme.Append(buttonBar.theme)

    if theme.buttonColor <> invalid
        m.top.buttonColor = theme.buttonColor
    end if

    if theme.buttonTextColor <> invalid
        m.top.buttonTextColor = theme.buttonTextColor
    else if theme.textColor <> invalid
        m.top.buttonTextColor = theme.textColor
    end if

    if theme.focusedButtonColor <> invalid
        m.top.focusedButtonColor = theme.focusedButtonColor
    else if theme.focusRingColor <> invalid
        m.top.focusedButtonColor = theme.focusRingColor
    end if

    if theme.focusedButtonTextColor <> invalid
        m.top.focusedButtonTextColor = theme.focusedButtonTextColor
    else if theme.textColor <> invalid
        m.top.focusedButtonTextColor = theme.textColor
    end if

    if theme.footprintButtonColor <> invalid
        m.top.footprintButtonColor = theme.footprintButtonColor
    end if

    if theme.footprintButtonTextColor <> invalid
        m.top.footprintButtonTextColor = theme.footprintButtonTextColor
    else if theme.textColor <> invalid
        m.top.footprintButtonTextColor = theme.textColor
    end if
    ResetColors()
end sub

sub ResetColors()
    roundedRectangle = m.top.findNode("roundedRectangle")
    label = m.top.findNode("title")
    enableFootprint = m.top.GetScene().buttonBar.enableFootprint

    roundedRectangle.backgroundColor = m.top.buttonColor
    roundedRectangle.backgroundFocusedColor = m.top.focusedButtonColor
    label.color = m.top.buttonTextColor
    if m.top.focusPercent > 0.9 and enableFootprint
        roundedRectangle.backgroundFocusedColor = m.top.footprintButtonColor
        roundedRectangle.backgroundColor = m.top.footprintButtonColor
        label.color = m.top.footprintButtonTextColor
        roundedRectangle.showFootprint = true
    end if
end sub

sub HandleFocus()
    rowListHasFocus = m.top.rowListHasFocus
    focusPercent = m.top.focusPercent
    
    buttonBar = m.top.GetScene().buttonBar
    if buttonBar = invalid then return

    enableFootprint = buttonBar.enableFootprint
    footprintStyle = buttonBar.footprintStyle

    if buttonBar.alignment = "left"
        focusPercent = m.top.rowFocusPercent
    end if
    if rowListHasFocus ' when navigating withing button bar
        itemFocused = focusPercent > 0.7

        if itemFocused
            FocusButton(focusPercent)
        else
            if footprintStyle = "selection" and m.top.isItemSelected
                ShowFootprint()
            else
                UnfocusButton(focusPercent)
            end if
        end if
    else ' when navigating between BB and view
        if enableFootprint
            if footprintStyle = "selection" and m.top.isItemSelected
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
    roundedRectangle = m.top.findNode("roundedRectangle")
    label = m.top.findNode("title")
    roundedRectangle.focusPercent = focusPercent
    roundedRectangle.backgroundFocusedColor = m.top.focusedButtonColor
    roundedRectangle.backgroundColor = m.top.focusedButtonColor
    label.color = m.top.focusedButtonTextColor
end sub

sub UnfocusButton(focusPercent as Float)
    roundedRectangle = m.top.findNode("roundedRectangle")
    label = m.top.findNode("title")
    roundedRectangle.focusPercent = focusPercent
    roundedRectangle.backgroundFocusedColor = m.top.buttonColor
    roundedRectangle.backgroundColor = m.top.buttonColor
    label.color = m.top.buttonTextColor
end sub

sub ShowFootprint()
    roundedRectangle = m.top.findNode("roundedRectangle")
    label = m.top.findNode("title")
    roundedRectangle.backgroundFocusedColor = m.top.footprintButtonColor
    roundedRectangle.backgroundColor = m.top.footprintButtonColor
    label.color = m.top.footprintButtonTextColor
    roundedRectangle.showFootprint = true
end sub
