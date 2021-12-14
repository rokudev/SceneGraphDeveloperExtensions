' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub init()
    m.visibleArea = m.top.FindNode("visibleArea")
    m.layout = m.top.FindNode("layout")
    m.keyboard = m.top.FindNode("keyboard")
    m.layoutKeyboard = m.top.FindNode("layoutKeyboard")
    m.noResultsLabel = m.top.FindNode("noResultsLabel")
    m.noResultsLabelGroup = m.top.FindNode("noResultsLabelGroup")
    m.spinner = m.top.FindNode("spinner")
    m.spinnerGroup = m.top.FindNode("spinnerGroup")
    m.spinner.uri = "pkg:/components/SGDEX/Images/loader.png"

    m.slidingAnimation = m.top.FindNode("slidingAnimation")
    m.slidingInterpolator = m.top.FindNode("slidingInterpolator")

    ' internal variables
    m.Handler_ConfigField = "HandlerConfigSearch"
    m.isClearContent = true
    m.lastFocusedNode = m.keyboard

    ' limit the render zone so keyboard won't overlap the overhang
    ' when user navigates to grid
    m.visibleArea.clippingRect = [-15, -15, 1280, 720]
    ' set constants for sliding the layout up and down
    m.layoutBaseY = 2
    ' move SearchView layout under the overhang
    m.layout.translation = [0, m.layoutBaseY]
    m.top.viewContentGroup.appendChild(m.visibleArea)


    ' set up observers
    m.top.ObserveFieldScoped("content", "OnContentChanged")
    m.keyboard.ObserveFieldScoped("text", "OnKeyboardTextChanged")
    m.top.ObserveFieldScoped("focusedChild", "OnFocuseChange")

    ' set specific to this view global theme attributes
    if m.LastThemeAttributes <> invalid then
        SGDEX_SetTheme(m.LastThemeAttributes)
    end if

    ' set default values
    m.top.posterShape = "16x9"
    m.noResultsLabel.text = m.top.noResultsLabelText
end sub

sub OnFocuseChange(event as Object)
    if m.top.IsInFocusChain() and not m.lastFocusedNode.isInFocusChain()
        m.lastFocusedNode.SetFocus(true)
    end if
end sub

' callback to the showSpinner field
' which will be triggered from the content manager
' when it starts and stops loading of the content
sub OnShowSpinnerChange()
    HideNoResultsLabel()
    if m.top.showSpinner
        m.spinner.visible = true
        m.spinner.control = "start"
    else
        m.spinner.visible = false
        m.spinner.control = "stop"
        ' content manager was executed in this place, check if content was retrieved
        isContentLoaded = m.top.content <> invalid and m.top.content.GetChildCount() > 0
        ' assume that search does not have results if content is not loaded
        ' and it's not a clear content which means that user wants to clear grid with results
        if m.top.showNoResultsLabel and not isContentLoaded and not m.isClearContent then ShowNoResultsLabel()
    end if
end sub

sub OnContentChanged()
    content = m.top.content
    if content <> invalid
        ' content is resetting each time user wants to perform search
        ' or clear grid with results
        HideNoResultsLabel()
        if content.GetChildCount() > 0
            RebuildGridNode()
        else
            m.isClearContent = not content.HasField(m.Handler_ConfigField)
            if m.gridNode <> invalid then RemoveGridNode()
        end if
    else ' setting invalid content will clear the view
        HideNoResultsLabel()
        if m.gridNode <> invalid then RemoveGridNode()
    end if
end sub

sub OnNoResultsTextChanged()
    m.noResultsLabel.text = m.top.noResultsLabelText
end sub

sub OnHintTextSet()
    if m.keyboard <> invalid
        m.keyboard.textEditBox.hintText = m.top.hintText
    end if
end sub

sub OnKeyboardTextChanged(event as Object)
    ' set search query
    m.top.query = event.GetData()
end sub

sub RebuildGridNode()
    configuration = GetGridConfiguration()
    if configuration <> invalid
        CreateNewOrUpdateGridNode(configuration.node, configuration.fields)
    end if
end sub

sub CreateNewOrUpdateGridNode(componentName = "" as String, fields = {} as Object)
    observers = GetGridObservers()

    if componentName.Len() > 0 and m.gridNode <> invalid and m.gridNode.Subtype() <> componentName
        ' remove previous node and observers
        RemoveGridNode()
    end if

    ' If node don't created or removed then create new grid node
    if m.gridNode = invalid
        m.gridNode = m.layout.CreateChild(componentName)
        m.gridNode.AddField("itemTextColorLine1", "color", true)
        m.gridNode.AddField("itemTextColorLine2", "color", true)
        m.gridNode.AddField("itemBackgroundColor", "string", true)
        m.gridNode.AddField("shortDescriptionLine1Align", "string", false)
        m.gridNode.AddField("shortDescriptionLine2Align", "string", false)
        m.gridNode.AddField("itemTextBackgroundColor", "string", true)

        if m.LastThemeAttributes <> invalid then
            SGDEX_SetTheme(m.LastThemeAttributes)
        end if
        if m.gridNode <> invalid
            for each field in observers
                m.gridNode.ObserveFieldScoped(field, observers[field])
            end for
            if m.top.content <> invalid then m.gridNode.content = m.top.content
        end if
    end if

    if m.gridNode <> invalid and fields <> invalid
        m.gridNode.SetFields(fields)
    end if
end sub

function GetGridConfiguration() as Object
    buttonBar = m.top.GetScene().buttonBar
    ' Base row list configuration fields
    rowItemAspectRatio = GetRowsAspectRatio()
    rowListRowsHeight = GetRowsHeight()
    xRowTranslation = 125
    'need to adjust grid translation when we have left aligned button bar
    if buttonBar <> invalid
        if buttonBar.visible = true and buttonBar.overlay = false and buttonBar.alignment = "left"
            xRowTranslation = 0
        end if
    end if

    rowListTranslation = [xRowTranslation, 0]
    zoomRowListHeight = 720 - rowListTranslation[1]

    rowListRowWidth = 1280 - xRowTranslation * 2
    rowListHeroRowHeight = 280
    rowTitleHeight = 30
    defaultItemSpacing = [20, 35 + rowTitleHeight]

    showRowCounter = true
    showRowLabel = true

    ' Custom UI components
    rowFocusAnimationStyle = "fixedFocusWrap"
    itemComponentName = "StandardGridItemComponent"
    rowTitleComponentName = "DefaultRowTitleComponent"

    if buttonBar <> invalid and buttonBar.visible = true and buttonBar.overlay = false and buttonBar.alignment = "left"
        if rowListRowWidth >= 1000
            rowListRowWidth = 1280 - (GetButtonBarWidth() + 125 + m.viewOffsetX)
        end if
    end if

    config = {
        node: "ZoomRowList"
        fields: {
            itemComponentName: itemComponentName
            wrap: false
            rowWidth: rowListRowWidth
            translation: rowListTranslation

            rowZoomHeight: rowListRowsHeight
            rowItemZoomHeight: rowListRowsHeight
            rowHeight: rowListRowsHeight
            rowItemHeight: rowListRowsHeight

            ' focusLimit is a special field to specify the height of the
            ' zoomRowList area where the focus can be
            focusLimit: rowListRowsHeight[0] - 1

            spacingAfterRow: defaultItemSpacing[1]
            spacingAfterRowItem: defaultItemSpacing[0]

            rowItemYOffset: rowTitleHeight
            rowItemZoomYOffset: rowTitleHeight
            rowItemAspectRatio: rowItemAspectRatio

            ' To make row counter to be placed symmetrically from right edge
            rowCounterOffset: [[rowListRowWidth, 0]]

            showRowCounter: showRowCounter
            showRowTitle: showRowLabel
        }
    }

    return config
end function

function GetRowsHeight() as Object
    landscapeItemHeight = 92
    squareItemHeight = 146
    portraitItemHeight = 150
    topMargin = 45 ' label height + spacing

    ' set specific height for each row if developer set rowPosterShapes
    rowPosterShapes = m.top.rowPosterShapes
    if rowPosterShapes <> invalid and rowPosterShapes.Count() > 0
        rowHeights = []
        for each shape in rowPosterShapes
            if shape = "square"
                rowHeights.Push(squareItemHeight + topMargin)
            else if shape = "portrait"
                rowHeights.Push(portraitItemHeight + topMargin)
            else
                rowHeights.Push(landscapeItemHeight + topMargin)
            end if
        end for
        ' set default height for all not specified rows
        rowHeights.Push(landscapeItemHeight + topMargin)
        return rowHeights
    end if

    if m.top.posterShape = "portrait" then
        return [portraitItemHeight + topMargin]
    else
        return [landscapeItemHeight + topMargin]
    end if
end function

function GetRowsAspectRatio() as Object
    styles = {
        "portrait": 3.0 / 4.0
        "4x3": 4.0 / 3.0
        "16x9": 16.0 / 9.0
        "square": 1.0
    }
    posterShape = m.top.posterShape
    if styles[posterShape] = invalid then posterShape = "16x9"

    ' if rowPosterShapes was set then set appropriate aspect ratio to rows
    rowPosterShapes = m.top.rowPosterShapes
    if rowPosterShapes <> invalid and rowPosterShapes.Count() > 0
        rowsAspectRatio = []
        for each shape in rowPosterShapes
            if styles[shape] <> invalid
                rowsAspectRatio.Push(styles[shape])
            else
                rowsAspectRatio.Push(styles[posterShape])
            end if
        end for
        rowsAspectRatio.Push(styles[posterShape]) ' set rest of rows to posterShape
        return rowsAspectRatio
    end if

    return [styles[posterShape]]
end function

sub SimulateAlias(event as Object)
    if m.gridNode <> invalid
        field = event.GetField()
        data = event.GetData()
        SetAliasData(field, data)
    end if
end sub

sub SetAliasData(field as String, data as Object)
    m.top[field] = data
    if m.gridNode <> invalid
        m.gridNode[field] = data
    end if
end sub

sub RemoveGridNode()
    observers = GetGridObservers()
    m.layout.RemoveChild(m.gridNode)
    for each field in observers
        m.gridNode.UnobserveFieldScoped(field)
    end for
    m.gridNode = invalid
end sub

function GetGridObservers()
    return {
        "rowItemFocused": "SimulateAlias"
        "rowItemSelected": "SimulateAlias"
    }
end function

sub ShowNoResultsLabel()
    m.noResultsLabel.visible = true
end sub

sub HideNoResultsLabel()
    m.noResultsLabel.visible = false
end sub

sub SGDEX_SetTheme(theme as Object)
    colorTheme = {
        TextColor: {
            gridNode: [
                "rowTitleColor"
                "rowCounterColor"
                "itemTextColorLine1"
                "itemTextColorLine2"
            ]
            keyboard: { textEditBox: "textColor" }
            noResultsLabel: "color"
        }
        focusRingColor: {
            gridNode: ["focusBitmapBlendColor"]
        }
    }
    SGDEX_setThemeFieldsToNode(m, colorTheme, theme)

    if theme.textBoxHintColor = invalid and (theme.textBoxTextColor <> invalid or theme.textColor <> invalid)
        ' setting keyboard textColor will change the hint color as well
        ' reset hint color if user does not set it explicitly
        theme.textBoxHintColor = "0xfefefe"
    end if
    keyboardThemeAttributes = {
        keyboardKeyColor: { keyboard: "keyColor" }
        keyboardFocusedKeyColor: { keyboard: "focusedKeyColor" }
        textBoxTextColor: { keyboard: { textEditBox: "textColor" } }
        textBoxHintColor: { keyboard: { textEditBox: "hintTextColor" } }
    }
    SGDEX_setThemeFieldsToNode(m, keyboardThemeAttributes, theme)

    gridThemeAttributes = {
        noResultsLabelColor: { noResultsLabel: "color" }
        rowLabelColor:       { gridNode: ["rowTitleColor", "rowCounterColor"] }
        focusRingColor:      { gridNode: "focusBitmapBlendColor" }
        focusFootprintColor: { gridNode: "focusFootprintBlendColor" }
        itemTextColorLine1:  { gridNode: "itemTextColorLine1" }
        itemTextColorLine2:  { gridNode: "itemTextColorLine2" }
        itemBackgroundColor:  { gridNode: "itemBackgroundColor" }
        itemTextBackgroundColor: { gridNode : "itemTextBackgroundColor"}
        shortDescriptionLine1Align:  { gridNode: "shortDescriptionLine1Align" }
        shortDescriptionLine2Align:  { gridNode: "shortDescriptionLine2Align" }
    }
    SGDEX_setThemeFieldsToNode(m, gridThemeAttributes, theme)
end sub

function SGDEX_GetViewType() as String
    return "searchView"
end function

sub SlideLayout(startY as Integer, desiredY as Integer)
    m.slidingInterpolator.keyValue = [[0, startY], [0, desiredY]]
    m.slidingAnimation.control = "start"
end sub

function OnKeyEvent(key as String, press as Boolean) as Boolean
    handled = false

    if press
        if m.gridNode <> invalid ' sliding can happen only if there is grid on the screen
            if key = "down" and m.keyboard.IsInFocusChain()
                SlideLayout(m.layoutBaseY, m.layoutTopY)
                m.lastFocusedNode = m.gridNode
                m.gridNode.SetFocus(true)
                handled = true
            else if (key = "up" or key = "back") and m.gridNode.IsInFocusChain()
                SlideLayout(m.layoutTopY, m.layoutBaseY)
                m.lastFocusedNode = m.keyboard
                m.keyboard.SetFocus(true)
                m.top.rowItemFocused = [-1,-1]
                handled = true
            end if
        end if
    end if

    return handled
end function

sub SGDEX_UpdateViewUI()
    ' avoid triggering if view wasn't initialized
    if m.top.viewContentGroup.GetChildCount() = 0
        return
    end if

    buttonBar = m.top.GetScene().buttonBar
    if buttonBar <> invalid
        buttonBarBounds = GetButtonBarBounds()

        buttonBarHeight = buttonBarBounds.height
        buttonBarWidth = buttonBarBounds.width

        overhangHeight = m.top.overhang.height
        m.layoutTopY = (m.layoutBaseY - (buttonBarHeight + buttonBarHeight))

        if m.layoutKeyboard <> invalid then m.layoutKeyboard.translation = [640, 0]
        if m.gridNode <> invalid then RebuildGridNode()
        if m.noResultsLabelGroup <> invalid then m.noResultsLabelGroup.translation = [640, 430]
        if m.spinnerGroup <> invalid then m.spinnerGroup.translation = [640, 430]

        if buttonBar.visible = true and buttonBar.overlay = false
            if buttonBar.alignment = "left" and m.layoutKeyboard <> invalid
                bbPadding = 30
                if buttonBar.autoHide = true and buttonBar.IsInFocusChain() = false
                    bbPadding = 41
                end if

                spinnerWidth = 100
                safeZoneWidth = GetViewXPadding()
                keyboardWidth = 1280 - 2*safeZoneWidth
                ' this is width of area between button bar and right safe zone
                centeredAreaWidth = 1280 - buttonBarWidth - safeZoneWidth
                offset = (centeredAreaWidth - spinnerWidth) / 2 + bbPadding

                m.layoutKeyboard.translation = [offset, 0]
                m.layoutTopY = m.layoutBaseY - m.defaultOverhangHeight
                m.noResultsLabelGroup.translation = [offset, 430]
                m.spinnerGroup.translation = [offset, 430]

                if keyboardWidth > centeredAreaWidth
                    ' try to shrink keyboard to keep it in a safe zone
                    scaleRatio = centeredAreaWidth / keyboardWidth
                    if scaleRatio < 0.7
                        ' keep minimum scaling and disable centered alignment due to very wide button bar
                        scaleRatio = 0.7
                        m.layoutKeyboard.translation = [0, 0]
                        m.layoutKeyboard.horizAlignment = "left"
                    end if
                    if m.keyboard <> invalid
                        m.keyboard.scale = [scaleRatio, scaleRatio]
                    end if
                end if
            end if
        else
            m.layoutTopY = m.layoutBaseY - m.defaultOverhangHeight
            if m.keyboard <> invalid
                ' scale keyboard up to normal size
                m.keyboard.scale = [1.0, 1.0]
            end if
            if m.layoutKeyboard <> invalid
                ' restore original alignment
                m.layoutKeyboard.horizAlignment = "center"
            end if
        end if
    end if
end sub

