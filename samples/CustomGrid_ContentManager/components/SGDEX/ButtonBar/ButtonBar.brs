' Copyright (c) 2021 Roku, Inc. All rights reserved.

sub init()
    m.top.theme = {}

    ' autohide nodes
    m.autoHideHint = m.top.findNode("autoHideHint")
    m.autoHideArrow = m.top.findNode("autoHideArrow")
    m.hintTitle = m.top.findNode("hintTitle")
    m.backgroundRectangle = m.top.findNode("backgroundRectangle")

    ' button bar nodes
    m.buttonsRowList = m.top.findNode("buttonsRowList")
    m.buttonBarLayout = m.top.findNode("buttonBarLayout")
    m.maskGroup = m.top.findNode("maskGroup")
    m.clippingGroup = m.top.findNode("clippingGroup")
    m.buttonBarArrow = m.top.findNode("buttonBarArrow")

    m.top.ObserveField("translation", "OnTranslationChanged")
    m.top.ObserveField("visible", "OnVisibleChanged")
    m.top.ObserveField("overlay", "OnVisibleChanged")
    m.top.ObserveField("updateTheme", "OnUpdateThemeChanged")
    m.top.ObserveField("content", "OnContentSet")
    m.top.ObserveField("focusedChild", "OnFocusChange")
    m.buttonsRowList.ObserveField("rowItemFocused", "OnItemFocused")
    m.buttonsRowList.ObserveField("rowItemSelected", "OnItemSelected")

    ' button bar constants
    m.backgroundWidth = 110
    m.defaultWidth = 55
    m.buttonHeight = 55
    m.backgroundMargin = 20
    m.autoHideVertTransl = 10
    m.defaultOverhangHeight = 115
    m.backgroundRectangle.height = m.buttonHeight + m.backgroundMargin * 2

    ' button bar internal fields
    m.debug = false
end sub

sub OnVisibleChanged()
    if m.top.visible
        OnTranslationChanged()
    end if
end sub

sub OnTranslationChanged()
    currentView = m.top.GetScene().componentController.currentView
    if currentView = invalid or currentView.overhang = invalid then return
    overhang = currentView.overhang
    
    buttonBarYSpacing = m.buttonBarLayout.itemSpacings[0] * 2 + m.buttonsRowList.itemSpacing[1] - 2
    buttonBarListX = m.buttonBarLayout.translation[0]
    contentAreaSafeZoneYPosition = 72 ' 720 * 0.10

    if m.top.alignment = "left" and m.top.visible = true
        ' Calculating visible buttons on buttonBar to switch animation
        ' The vertical BB uses floating focus when there are not enough buttons to wrap
        ' and uses fixed focus once the set of buttons gets big enough to wrap.
        if m.buttonsRowList.content <> invalid
            buttonsCount = m.buttonsRowList.content.getChildCount()
            itemHeight = m.buttonsRowList.itemSize[1]
            if overhang.height = 0
                safeZone = (720 - contentAreaSafeZoneYPosition*2)
            else
                safeZone = (720 - overhang.height - contentAreaSafeZoneYPosition)
            end if
            if buttonsCount > 0 and safeZone > 0
                visibleNumRows = CInt(safeZone / (itemHeight + 10))
                if buttonsCount >= visibleNumRows
                    m.buttonsRowList.vertFocusAnimationStyle="fixedFocusWrap"
                else
                    m.buttonsRowList.vertFocusAnimationStyle="floatingFocus"
                end if
                m.buttonsRowList.numRows = visibleNumRows
            end if
        end if
        
        if IsFullSizeView(currentView) 
            if not m.top.overlay 
                m.buttonBarLayout.translation = [buttonBarListX, m.defaultOverhangHeight]
            end if
            m.autoHideHint.translation = [m.autoHideHint.translation[0], m.backgroundRectangle.height/2]
        else if m.top.overlay
            ' aligning buttonsRowList to 72px
            m.buttonBarLayout.translation = [buttonBarListX, contentAreaSafeZoneYPosition - buttonBarYSpacing]
            m.autoHideHint.translation = [m.autoHideHint.translation[0], m.backgroundRectangle.height/2]
        else
            ' restoring translation
            m.buttonBarLayout.translation = [buttonBarListX,0]
            ' moving autoHideHint down if overhang height overlap it
            if overhang.height > (m.autoHideHint.boundingRect()["y"] + (m.autoHideHint.boundingRect()["height"]))
                m.autoHideHint.translation = [m.autoHideHint.translation[0], m.autoHideHint.boundingRect()["height"]/2]
            else
                height = (m.backgroundRectangle.height/2) - overhang.height
                m.autoHideHint.translation = [m.autoHideHint.translation[0], height]
            end if
        end if
    end if
end sub

sub OnContentSet()
    content = m.top.content
    if m.buttonsRowList <> invalid
        isNewContent = m.buttonsRowList.content = invalid or content = invalid or not m.buttonsRowList.content.IsSameNode(content)
        if isNewContent
            if content = invalid
                m.buttonsRowList.content = invalid
            else if content.GetChildCount() > 0
                SetButtonBarContent(content)
            else
                ' observe for additional content children changes
                ' in order to re-align button bar layout
                content.ObserveFieldScoped("change", "OnContentChange")
            end if
        end if
    end if
end sub

sub OnContentChange(event as Object)
    content = event.GetRoSGNode()
    if content.GetChildCount() > 0
        SetButtonBarContent(content)
    end if
end sub

sub SetButtonBarContent(content as Object)
    m.top.GetScene().ObserveField("theme", "OnGlobalThemeChange")
    m.top.GetScene().ObserveField("updateTheme", "OnGlobalUpdateThemeChange")
    OnGlobalThemeChange()
    ' adjust content to show appropriate button sizes based on passed content
    newContent = AdjustButtonBarContent(content)
    if newContent <> invalid
        AlignButtonBar()
        buttonsCount = newContent.GetChildCount()
        if m.top.alignment = "top"
            m.buttonsRowList.numRows = 1
            m.buttonsRowList.numColumns = buttonsCount
        else if m.top.alignment = "left"
            ' Calculating visible buttons on buttonBar to switch animation
            ' The vertical BB uses floating focus when there are not enough buttons to wrap
            ' and uses fixed focus once the set of buttons gets big enough to wrap.
            safeZone = (720 - m.defaultOverhangHeight - 72)
            numRows = Cint(safeZone / m.buttonHeight)
            if buttonsCount >= numRows
                m.buttonsRowList.vertFocusAnimationStyle="fixedFocusWrap"
            else
                m.buttonsRowList.vertFocusAnimationStyle="floatingFocus"
            end if
            m.buttonsRowList.numRows = numRows
            m.buttonsRowList.numColumns = 1
        end if
        ' retrieve autohide title hint
        m.hintTitle.text = newContent.title
        ' content model should be aligned with RowList's one
        m.buttonsRowList.content = newContent

        if m.top.jumpToItem > 0 then OnJumpToItem() ' to be able set jumpToItem before setting content
    end if
end sub

' Retrieve index from the RowList's 2-element array
sub OnItemFocused(event as Object)
    rowItemFocused = event.GetData()
    if m.top.alignment = "top"
        m.top.itemFocused = rowItemFocused[1]
    else if m.top.alignment = "left"
        m.top.itemFocused = rowItemFocused[0]
    end if

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
    if m.top.alignment = "top"
        itemSelected = rowItemSelected[1]
    else if m.top.alignment = "left"
        itemSelected = rowItemSelected[0]
    end if
    isSelectionFootprint = m.top.enableFootprint = true and m.top.footprintStyle = "selection"
    if isSelectionFootprint then HandleFootprintSelection(itemSelected)
    m.top.itemSelected = itemSelected
end sub

' This function handles footprint selection by
' adding itemSelected field to RowList content node.
' It gives us opportunity to notify ButtonBarItemComponent about selection.
sub HandleFootprintSelection(itemSelected as Integer)
    ' to remove footprint from prev button when new one is selected
    if m.lastPressedButton <> invalid and m.lastPressedButton <> itemSelected
        lastPressedContentNode = GetButtonByIndex(m.lastPressedButton)
        if lastPressedContentNode <> invalid
            lastPressedContentNode.Update({
                itemSelected: false
            }, true)
        end if
    end if

    contentNode = GetButtonByIndex(itemSelected)
    if contentNode <> invalid
        contentNode.Update({
            itemSelected: true
        }, true)
        m.lastPressedButton = itemSelected
    end if
end sub

' helper function to get content node specified by the index in the list
' will return correct item based on alignment
function GetButtonByIndex(index as Integer) as Object
    item = invalid
    rowListContent = m.buttonsRowList.content
    if rowListContent <> invalid
        if m.top.alignment = "top"
            item = rowListContent.GetChild(0).GetChild(index)
        else if m.top.alignment = "left"
            item = rowListContent.GetChild(index).GetChild(0)
        end if
    end if
    return item
end function

sub OnJumpToItem()
    itemIndex = m.top.jumpToItem
    m.lastPressedButton = invalid
    if m.top.alignment = "top"
        m.buttonsRowList.jumpToRowItem = [0, itemIndex]
    else if m.top.alignment = "left"
        m.buttonsRowList.jumpToRowItem = [itemIndex, 0]
    end if
end sub

' define button bar size based on content
function AdjustButtonBarContent(content as Object)
    maxButtonWidth = 0
    m.buttonBarWidth = 0
    m.buttonBarHeight = 0
    contentCopy = content.clone(true)

    ' use to calculate actual text width using boundingRect()
    dummyLabel = CreateObject("roSGNode", "Label")
    for each buttonContent in contentCopy.GetChildren(-1, 0)
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
            contentCopy.removeChild(buttonContent)
            buttonContent.Update({
                HDItemWidth: 0
            }, true)
        end if

        if buttonContent.HDItemWidth = invalid
            w = 0

            ' calculate text width
            dummyLabel.text = buttonContent.title
            boundingRect = dummyLabel.boundingRect()
            if boundingRect <> invalid and boundingRect.width <> invalid
                w = boundingRect.width
            end if

            if isPoster then w += 32.0 ' make sure if we have enough width for poster

            buttonContent.Update({
                HDItemWidth: w + 60.0 ' to compensate for the padding in the LayoutGroup
            }, true)
        end if

        if buttonContent.HDItemWidth > maxButtonWidth then maxButtonWidth = buttonContent.HDItemWidth
        m.buttonBarWidth += buttonContent.HDItemWidth
        m.buttonBarHeight += m.buttonHeight
    end for

    ' copy metadata to root content node
    newContent = contentCopy.clone(false)
    if m.top.alignment = "top"
        ' set button bar width with item spacings
        m.buttonBarWidth += (content.GetChildCount() * m.buttonsRowList.rowItemSpacing[0][0]) + 1
        ' adjust content tree to set to RowList
        rowContent = newContent.CreateChild("ContentNode")
        rowContent.AppendChildren(contentCopy.GetChildren(-1, 0))
    else if m.top.alignment = "left"
        m.buttonBarWidth = maxButtonWidth
        for each buttonContent in contentCopy.GetChildren(-1, 0)
            rowContent = newContent.CreateChild("ContentNode")
            rowContent.AppendChild(buttonContent)
        end for
    end if

    return newContent
end function

sub AlignButtonBar()
    buttonBarX = 107
    if m.top.alignment = "top"
        ' adjust animation to the type of buttonBar (few items or more items)
        popUpInterpolator = m.top.findNode("popUpInterpolator")
        fadeOutInterpolator = m.top.findNode("fadeOutInterpolator")
        m.buttonBarLayout.layoutDirection="horiz"
        m.backgroundRectangle.height = m.buttonHeight + m.backgroundMargin*2
        m.backgroundRectangle.width = 1280
        buttonBarY = CInt(m.buttonHeight/2 + m.backgroundMargin)
        centerX = m.backgroundRectangle.width / 2
        m.buttonBarLayout.vertAlignment = "center"
        if m.buttonBarWidth > 980
            ' handle design when buttonBar is bigger than allowed
            m.buttonBarWidth = 980
            m.maskGroup.maskuri = "pkg:/components/SGDEX/Images/ButtonBar/gradient_black-transparent.png"
            m.buttonBarLayout.horizAlignment = "left"
            m.buttonBarLayout.translation = [buttonBarX, buttonBarY]
            m.buttonBarArrow.visible = true
        else
            m.maskGroup.maskuri = ""
            m.buttonBarLayout.horizAlignment = "center"
            arrowWidth = m.buttonBarArrow.width
            m.buttonBarLayout.translation = [centerX + arrowWidth, buttonBarY]
            m.buttonBarArrow.visible = false
        end if
        m.autoHideArrow.uri="pkg:/components/SGDEX/Images/ButtonBar/ic_arrow_up.png"
        m.autoHideArrow.height = 12
        m.autoHideArrow.width = 25
        m.autoHideHint.translation = [centerX, m.autoHideVertTransl]
        m.autoHideHint.rotation = 0

        m.clippingGroup.clippingRect = [0, 0, m.backgroundRectangle.width, m.backgroundRectangle.height]
        popUpInterpolator.keyValue = [[0, -m.backgroundRectangle.height], [0, 0]]
        fadeOutInterpolator.keyValue = [[0, 0], [0, -m.backgroundRectangle.height]]

        ' RDE-6815: this will ensure the buttons are centered vertically within the ButtonBar
        m.buttonsRowList.itemSpacing = [0, 0]
    else if m.top.alignment = "left"
        popUpInterpolator = m.top.findNode("popUpInterpolator")
        fadeOutInterpolator = m.top.findNode("fadeOutInterpolator")
        m.buttonBarLayout.layoutDirection = "vert"
        m.buttonBarLayout.vertAlignment = "top"
        m.buttonBarLayout.horizAlignment = "left"
        m.backgroundWidth = m.buttonBarWidth + m.backgroundMargin*2 + buttonBarX
        if m.top.autoHide
            m.backgroundRectangle.width = 107
        else
            m.backgroundRectangle.width = m.backgroundWidth
        end if
        m.backgroundRectangle.height = 720
        m.buttonBarArrow.visible = false

        if m.buttonBarHeight > 430
            m.maskGroup.maskuri = "pkg:/components/SGDEX/Images/ButtonBar/gradient_black-transparent-vertical.png"
            m.maskGroup.maskOffset = [50, 0]
            m.maskGroup.masksize=[0, 1400]
        else
            m.maskGroup.maskuri = ""
        end if

        m.autoHideArrow.uri="pkg:/components/SGDEX/Images/ButtonBar/ic_arrow_up.png"
        m.autoHideArrow.height = 12
        m.autoHideArrow.width = 25
        ' initial position set
        height = ((m.backgroundRectangle.height/2) - m.defaultOverhangHeight)
        m.autoHideHint.translation = [buttonBarX/2,height]
        ' rotate autoHideHint 90 degrees clockwise
        m.autoHideHint.rotation = 1.570796

        m.buttonBarLayout.translation = [buttonBarX, 0]
        m.clippingGroup.clippingRect = [0, 0, m.backgroundWidth, m.backgroundRectangle.height]
        popUpInterpolator.keyValue = [[-m.backgroundWidth, 0], [0, 0]]
        fadeOutInterpolator.keyValue = [[0, 0], [-m.backgroundWidth, 0]]

        m.buttonsRowList.itemSpacing = [0, 10] ' RDE-6815
    end if

    m.buttonsRowList.itemSize = [m.buttonBarWidth, m.buttonHeight]
    m.buttonsRowList.rowItemSize = [m.buttonBarWidth, m.buttonHeight]

    'need to forced SGDEX_OnButtonBarVisibleChange() function for update current view with current alignment
    visible = m.top.visible
    m.top.visible = false
    m.top.visible = visible
end sub

sub OnAutoHideChange(event as Object)
    autoHide = event.GetData()
    buttonBarPopUp = m.top.findNode("buttonBarPopUp")
    buttonBarFadeOut = m.top.findNode("buttonBarFadeOut")
    if m.top.content <> invalid and m.top.content.GetChildCount() > 0
        AlignButtonBar()
    end if
    if autoHide
        m.top.visible = true
        m.autoHideHint.visible = true
        m.backgroundRectangle.visible = false
        buttonBarFadeOut.control = "start"
        buttonBarPopUp.control = "stop"
    else
        m.autoHideHint.visible = false
        m.backgroundRectangle.visible = true
        buttonBarFadeOut.control = "stop"
        buttonBarPopUp.control = "start"
    end if
end sub

sub OnAlignmentChanged(event as Object)
    if m.top.content <> invalid
        SetButtonBarContent(m.top.content)
        OnFocusChange()
    end if
end sub

' Sets focus to RowList when ButtonBar component is focused
sub OnFocusChange()
    ' animation nodes
    buttonBarPopUp = m.top.findNode("buttonBarPopUp")
    buttonBarFadeOut = m.top.findNode("buttonBarFadeOut")

    if m.buttonsRowList <> invalid
        if m.top.footprintStyle = "selection" and m.lastPressedButton <> invalid
            if m.top.alignment = "top"
                m.top.jumpToItem = m.lastPressedButton
            else if m.top.alignment = "left" and not m.top.isInFocusChain()
                m.top.jumpToItem = m.lastPressedButton
            end if
        end if

        if m.top.isInFocusChain() and m.top.hasFocus()
            m.buttonsRowList.SetFocus(true)
            if m.top.autoHide
                translation = m.backgroundRectangle.translation
                if m.top.alignment = "top"
                    translation[1] = -m.backgroundRectangle.height
                else if m.top.alignment = "left"
                    if m.backgroundRectangle.width <> m.backgroundWidth
                        m.backgroundRectangle.width = m.backgroundWidth
                        visible = m.top.visible
                        m.top.visible = false
                        m.top.visible = visible
                    end if
                    translation[0] = -m.backgroundRectangle.width
                end if
                m.backgroundRectangle.translation = translation
                m.backgroundRectangle.visible = true
                buttonBarFadeOut.control = "stop"
                buttonBarPopUp.control = "start"
            end if
        else if not m.top.isInFocusChain() and m.top.autoHide
            if m.top.alignment = "left" and m.backgroundRectangle.width = m.backgroundWidth
                m.backgroundRectangle.width = 107
                visible = m.top.visible
                m.top.visible = false
                m.top.visible = visible
            end if
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
    resolveGlobalThemeAttributes(theme)
end sub

sub OnGlobalUpdateThemeChange()
    theme = m.top.GetScene().updateTheme
    resolveGlobalThemeAttributes(theme)
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
