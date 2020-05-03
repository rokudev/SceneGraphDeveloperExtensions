' Copyright (c) 2019 Roku, Inc. All rights reserved.

sub init()
    m.top.theme = {}

    ' wrap roFontRegistry in Task to prevent creating MAIN|TASK-only component on RENDER thread
    m.fontResolver = CreateObject("roSGNode", "GetDefaultFontTask")
    m.fontResolver.ObserveField("oneCharWidth", "OnOneCharWidthSet")
    m.fontResolver.control = "run"

    ' autohide nodes
    m.autoHideHint = m.top.findNode("autoHideHint")
    m.hintTitle = m.top.findNode("hintTitle")
    m.backgroundRectangle = m.top.findNode("backgroundRectangle")

    ' button bar nodes
    m.buttonsRowList = m.top.findNode("buttonsRowList")
    m.buttonBarLayout = m.top.findNode("buttonBarLayout")
    m.maskGroup = m.top.findNode("maskGroup")
    m.clippingGroup = m.top.findNode("clippingGroup")
    m.buttonBarArrow = m.top.findNode("buttonBarArrow")

    m.top.ObserveField("updateTheme", "OnUpdateThemeChanged")
    m.top.ObserveField("content", "OnContentSet")
    m.top.ObserveField("focusedChild", "OnFocusChange")
    m.buttonsRowList.ObserveField("rowItemFocused", "OnItemFocused")
    m.buttonsRowList.ObserveField("rowItemSelected", "OnItemSelected")

    ' button bar constants
    m.defaultWidth = 55
    m.buttonHeight = 55
    m.backgroundMargin = 20
    m.autoHideVertTransl = 15
    m.backgroundRectangle.height = m.buttonHeight + m.backgroundMargin*2

    ' button bar internal fields
    m.Handler_ConfigField = "handlerConfigButtonBar"
    m.debug = false
end sub

sub OnContentSet()
    content = m.top.content
    if m.buttonsRowList <> invalid
        isNewContent = m.buttonsRowList.content = invalid or content = invalid or not m.buttonsRowList.content.IsSameNode(content)
        if isNewContent
            if content = invalid
                m.buttonsRowList.content = invalid
            else if content[m.Handler_ConfigField] <> invalid
                RetrieveContentFromCH(content)
            else
                SetButtonBarContent(content)
            end if
        end if
    end if
end sub

sub RetrieveContentFromCH(content as Object)
    config = content[m.Handler_ConfigField]
    callback = {
        config: config
        needToRetry: true

        onReceive: sub(data)
            if data <> invalid and data.GetChildCount() > 0
                SetButtonBarContent(data)
            else
                m.onError(data)
            end if
        end sub

        onError: sub(data)
            if m.needToRetry
                ' retry only once
                m.needToRetry = false
                GetContentData(m, m.config, GetGlobalAA().top.content)
            end if
        end sub
    }
    GetContentData(callback, config, m.top.content)
    content[m.Handler_ConfigField] = invalid
end sub

sub SetButtonBarContent(content as Object)
    m.top.GetScene().ObserveField("theme", "OnGlobalThemeChange")
    m.top.GetScene().ObserveField("updateTheme", "OnGlobalUpdateThemeChange")
    OnGlobalThemeChange()
    ' adjust content to show appropriate button sizes based on passed content
    newContent = AdjustButtonBar(content)
    if newContent <> invalid
        buttonsCount = newContent.GetChildCount()
        m.buttonsRowList.numColumns = buttonsCount
        ' retrieve autohide title hint
        m.hintTitle.text = newContent.title
        ' content model should be aligned with RowList's one
        rowContent = CreateObject("roSGNode", "ContentNode")
        rowContent.AppendChild(newContent)
        m.buttonsRowList.content = rowContent

        if m.top.jumpToItem > 0 then OnJumpToItem() ' to be able set jumpToItem before setting content
    end if
end sub

' Retrieve index from the RowList's 2-element array
sub OnItemFocused(event as Object)
    rowItemFocused = event.GetData()
    m.top.itemFocused = rowItemFocused[1]

    isSelectionFootprint = m.top.enableFootprint = true and m.top.footprintStyle = "selection"
    isFirstFocus = m.lastPressedButton = invalid and m.top.itemFocused >= 0
    isJumpToItem = m.top.jumpToItem >= 0 and m.top.jumpToItem = m.top.itemFocused
    if isSelectionFootprint and isFirstFocus and isJumpToItem
        ' if m.lastPressedButton isn't initialized yet
        ' then mark correct "active" button as last pressed
        m.lastPressedButton = m.top.itemFocused
        HandleFootprintSelection(m.lastPressedButton)
    end if
end sub

' Retrieve index from the RowList's 2-element array
sub OnItemSelected(event as Object)
    rowItemSelected = event.GetData()
    itemSelected = rowItemSelected[1]
    isSelectionFootprint = m.top.enableFootprint = true and m.top.footprintStyle = "selection"
    if isSelectionFootprint then HandleFootprintSelection(itemSelected)
    m.top.itemSelected = itemSelected
end sub

' This function handles footprint selection by
' adding itemSelected field to RowList content node.
' It gives us opportunity to notify ButtonBarItemComponent about selection.
sub HandleFootprintSelection(itemSelected as Integer)
    rowListContent = m.buttonsRowList.content
    if rowListContent <> invalid
        ' to remove footprint from prev button when new one is selected
        if m.lastPressedButton <> invalid and m.lastPressedButton <> itemSelected
            lastPressedContentNode = rowListContent.GetChild(0).GetChild(m.lastPressedButton)
            lastPressedContentNode.Update({
                itemSelected: false
            }, true)
        end if

        contentNode = rowListContent.GetChild(0).GetChild(itemSelected)
        if contentNode <> invalid
            contentNode.Update({
                itemSelected: true
            }, true)
            m.lastPressedButton = itemSelected
        end if
    end if
end sub

sub OnJumpToItem()
    itemIndex = m.top.jumpToItem
    m.buttonsRowList.jumpToRowItem = [0, itemIndex]
end sub

' define button bar size based on content
function AdjustButtonBar(content as Object)
    ' wait until task will be finished
    if m.fontResolver.oneCharWidth = 0 then return invalid

    m.buttonBarWidth = 0
    newContent = content.clone(true)
    for each buttonContent in newContent.GetChildren(-1, 0)
        isPoster = isnonemptystr(buttonContent.hdPosterUrl)
        isTitle = isnonemptystr(buttonContent.title)

        ' adjust button size if only poster was set
        if isPoster and not isTitle
            ' if size was not set explicitly
            if buttonContent.HDItemWidth = invalid
                padding = 5
                ' set button size through the HDItemWidth field
                buttonContent.Update({
                    HDItemWidth: 62.0
                }, true)
            end if
        else if not isPoster and not isTitle ' empty button
            newContent.removeChild(buttonContent)
            buttonContent.Update({
                HDItemWidth: 0
            }, true)
        end if

        if buttonContent.HDItemWidth = invalid
            ' size buttons dynamically based on their title
            oneCharWidth = m.fontResolver.oneCharWidth
            w = Cdbl(m.fontResolver.oneCharWidth * buttonContent.title.len())

            if w < 50 then w = 50.0 ' buttons must be at least 50px wide to avoid visual problems

            buttonContent.Update({
                HDItemWidth: w + 30 ' to compensate for the padding in the LayoutGroup
            }, true)
        end if

        m.buttonBarWidth += buttonContent.HDItemWidth
    end for

    ' set button bar width with item spacings
    m.buttonBarWidth += (content.GetChildCount() * m.buttonsRowList.rowItemSpacing[0][0]) + 1
    AlignButtonBar(m.buttonBarWidth, m.buttonHeight)

    return newContent
end function

sub OnOneCharWidthSet(event as Object)
    oneCharWidth = event.GetData()
    if oneCharWidth > 0 and m.top.content <> invalid
        SetButtonBarContent(m.top.content)
    end if
end sub

sub AlignButtonBar(width as Float, height as Float)
    ' adjust animation to the type of buttonBar (few items or more items)
    popUpInterpolator = m.top.findNode("popUpInterpolator")
    fadeOutInterpolator = m.top.findNode("fadeOutInterpolator")

    buttonBarY = CInt(m.buttonHeight/2 + m.backgroundMargin)
    centerX = m.backgroundRectangle.width / 2

    if width > 980
        ' handle design when buttonBar is bigger than allowed
        width = 980
        m.maskGroup.maskuri = "pkg:/components/SGDEX/Images/ButtonBar/gradient_black-transparent.png"
        m.buttonBarLayout.horizAlignment = "left"
        m.buttonBarLayout.translation = [107, buttonBarY]
        m.buttonBarArrow.visible = true
    else
        m.maskGroup.maskuri = ""
        m.buttonBarLayout.horizAlignment = "center"
        arrowWidth = m.buttonBarArrow.width
        m.buttonBarLayout.translation = [centerX + arrowWidth, buttonBarY]
        m.buttonBarArrow.visible = false
    end if

    m.autoHideHint.translation = [centerX, m.autoHideVertTransl]

    m.clippingGroup.clippingRect = [0, 0, m.backgroundRectangle.width, m.backgroundRectangle.height]
    popUpInterpolator.keyValue = [[0, -m.backgroundRectangle.height], [0, 0]]
    fadeOutInterpolator.keyValue = [[0, 0], [0, -m.backgroundRectangle.height]]

    m.buttonsRowList.itemSize = [width, height]
    m.buttonsRowList.rowItemSize = [m.defaultWidth, height]
end sub

sub OnAutoHideChange(event as Object)
    autoHide = event.GetData()
    if autoHide
        m.top.visible = true
        m.autoHideHint.visible = true
        m.backgroundRectangle.visible = false
    else
        m.autoHideHint.visible = false
        m.backgroundRectangle.visible = true
    end if
end sub

' Sets focus to RowList when ButtonBar component is focused
sub OnFocusChange()
    ' animation nodes
    buttonBarPopUp = m.top.findNode("buttonBarPopUp")
    buttonBarFadeOut = m.top.findNode("buttonBarFadeOut")

    if m.buttonsRowList <> invalid
        if m.top.footprintStyle = "selection" and m.lastPressedButton <> invalid
            m.top.jumpToItem = m.lastPressedButton
        end if

        if m.top.isInFocusChain()
            m.buttonsRowList.SetFocus(true)
            if m.top.autoHide
                translation = m.backgroundRectangle.translation
                translation[1] = -m.backgroundRectangle.height
                m.backgroundRectangle.translation = translation
                m.backgroundRectangle.visible = true
                buttonBarFadeOut.control = "stop"
                buttonBarPopUp.control = "start"
            end if
        else if not m.top.isInFocusChain() and m.top.autoHide
            buttonBarPopUp.control = "stop"
            buttonBarFadeOut.control = "start"
        end if
    end if
end sub

sub OnUpdateThemeChanged(event as Object)
    newTheme = event.GetData()
    viewTheme = m.top.theme
    viewTheme.Append(newTheme)
    m.top.theme = viewTheme
end sub

sub OnGlobalThemeChange()
    theme = m.top.GetScene().actualThemeParameters
    m.top.theme = resolveGlobalThemeAttributes(theme)
end sub

sub OnGlobalUpdateThemeChange()
    theme = m.top.GetScene().updateTheme
    m.top.updateTheme = resolveGlobalThemeAttributes(theme)
end sub

function resolveGlobalThemeAttributes(newGlobalTheme as Object)
    viewTheme = {}
    if newGlobalTheme <> invalid
        if GetInterface(newGlobalTheme["global"], "ifAssociativeArray") <> invalid
            viewTheme.Append(newGlobalTheme["global"])
        end if
        if GetInterface(newGlobalTheme["buttonBar"], "ifAssociativeArray") <> invalid
            viewTheme.Append(newGlobalTheme["buttonBar"])
        end if
        ' add all old attributes
        if m.top.theme <> invalid then viewTheme.Append(m.top.theme)
        if m.top.updateTheme <> invalid then viewTheme.Append(m.top.updateTheme)
        resolveButtonBarTheme(viewTheme)
    end if
    return viewTheme
end function

sub resolveButtonBarTheme(theme as Object)
    if theme.hintTextColor <> invalid
        ' setting hintTextColor should be prioritised over textColor
        m.hintTitle.color = theme.hintTextColor
    else if theme.textColor <> invalid
        m.hintTitle.color = theme.textColor
    end if

    if theme.hintArrowColor <> invalid
        autoHideArrow = m.top.findNode("autoHideArrow")
        autoHideArrow.blendColor = theme.hintArrowColor
        m.buttonBarArrow.blendColor = theme.hintArrowColor
    end if

    if theme.backgroundColor <> invalid
        m.backgroundRectangle.color = theme.backgroundColor
    end if
end sub
