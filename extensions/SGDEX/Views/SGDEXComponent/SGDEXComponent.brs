' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    ?"SGDEX: create new view: "m.top.subtype()
    m.themeDebug = false

    ' viewOffsetY can be overriden in init of each view
    ' to change the spacing between overhang and content for specific cases
    m.viewOffsetY = 25
    m.viewOffsetX = 20
    m.defaultOverhangHeight = 115

    ' Minimum Y offset from top edge of the screen to content
    m.buttonBarSafeZoneYPosition = 36 ' 720 * 0.05
    m.contentAreaSafeZoneYPosition = 72 ' 720 * 0.10

    m.top.overhang = m.top.FindNode("overhang")
    m.top.overhang.ObserveField("height", "SGDEX_OnOverhangHeightChange")
    m.top.getScene().ObserveField("theme", "SGDEX_GlobalThemeObserver")
    m.top.getScene().ObserveField("updateTheme", "SGDEX_GlobalUpdateThemeObserver")
    m.top.getScene().buttonBar.ObserveField("visible", "SGDEX_OnButtonBarVisibleChange")
    m.top.getScene().buttonBar.ObserveField("overlay", "SGDEX_OnButtonBarVisibleChange")

    m.top.viewContentGroup = m.top.FindNode("viewContentGroup")

    m.top.ObserveField("wasShown", "OnViewWasShown")

    uiResolution = CreateObject("roDeviceinfo").GetUIResolution()

    m.backgroundRectangle = m.top.FindNode("backgroundRectangle")
    m.backgroundRectangle.width = uiResolution.width
    m.backgroundRectangle.height = uiResolution.height

    m.backgroundImage = m.top.FindNode("backgroundImage")
    m.backgroundImage.width = uiResolution.width
    m.backgroundImage.height = uiResolution.height

    SGDEX_InternalBuildAndSetTheme(m.top.theme, m.top.getScene().actualThemeParameters)
end sub

sub OnViewWasShown()
    SGDEX_OnButtonBarVisibleChange()
end sub

sub SGDEX_OnOverhangHeightChange()
    fullSizeViews = {
        "MediaView": "",
        "SlideShowView": "",
        "EndcardView": ""
    }
    buttonBar = m.top.getScene().buttonBar
    overhang = m.top.findNode("overhang")
    autoHideHint = buttonBar.findNode("autohidehint")
    buttonBarRectangle = buttonBar.findNode("backgroundRectangle")
    buttonBarList = buttonBar.findNode("buttonBarLayout")
    buttonsRowList = buttonBar.findNode("buttonsRowList")

    buttonBarYSpacing = buttonBarList.itemSpacings[0] * 2 + buttonsRowList.itemSpacing[1] - 2

    buttonBarListX = buttonBarList.translation[0]

    if buttonBar.alignment = "left" and buttonBar.visible = true
        ' Calculating visible buttons on buttonBar to switch animation
        ' The vertical BB uses floating focus when there are not enough buttons to wrap
        ' and uses fixed focus once the set of buttons gets big enough to wrap.
        if buttonsRowList.content <> invalid
            buttonsCount = buttonsRowList.content.getChildCount()
            itemHeight = buttonsRowList.itemSize[1]
            if overhang.height = 0
                safeZone = (720 - m.contentAreaSafeZoneYPosition*2)
            else
                safeZone = (720 - overhang.height - m.contentAreaSafeZoneYPosition)
            end if
            if buttonsCount > 0 and safeZone > 0
                visibleNumRows = CInt(safeZone / (itemHeight + 10))
                if buttonsCount >= visibleNumRows
                    buttonsRowList.vertFocusAnimationStyle="fixedFocusWrap"
                else
                    buttonsRowList.vertFocusAnimationStyle="floatingFocus"
                end if
                buttonsRowList.numRows = visibleNumRows
            end if
        end if
        ' Resize ButtonBar to fill gap appeared because of disabled overhang
        ' ButtonBar will be resized if overhang height is default or equal to 0 OR if overlay mode is enabled
        if fullSizeViews[m.top.subtype()] = "" and (overhang.height = m.contentAreaSafeZoneYPosition or overhang.height = 0) and buttonBar.translation[1] <> 0
            if m.top.hasField("mode") and m.top.mode = "audio"
                buttonBar.translation = [0, m.defaultOverhangHeight]
                buttonBarList.translation = [buttonBarListX, 0]
                height = (buttonBarRectangle.height/2) - m.defaultOverhangHeight
                autoHideHint.translation = [autoHideHint.translation[0],height]
            else
                buttonBar.translation = [0,0]
                buttonBarList.translation = [buttonBarListX,m.defaultOverhangHeight]
                autoHideHint.translation = [autoHideHint.translation[0],buttonBarRectangle.height/2]
            end if
        else if buttonBar.overlay
            buttonBar.translation = [0,0]
            ' aligning buttonsRowList to 72px
            buttonBarList.translation = [buttonBarListX, m.contentAreaSafeZoneYPosition - buttonBarYSpacing]
            autoHideHint.translation = [autoHideHint.translation[0], buttonBarRectangle.height/2]
        else
            ' restoring translation
            buttonBarList.translation = [buttonBarListX,0]
            ' moving autoHideHint down if overhang height overlap it
            if overhang.height > (autohideHint.boundingRect()["y"] + (autohideHint.boundingRect()["height"]))
                autohideHint.translation = [autohideHint.translation[0], autohideHint.boundingRect()["height"]/2]
            else
                height = (buttonBarRectangle.height/2) - overhang.height
                autoHideHint.translation = [autohideHint.translation[0], height]
            end if
        end if
    end if
end sub

sub SGDEX_OnButtonBarVisibleChange()
    buttonBar = m.top.getScene().buttonBar
    if buttonBar <> invalid and m.top.visible then
        SGDEX_UpdateBaseViewUI()
    end if
end sub


' Default logic to adjust place zone with content according to
' overhang and buttonbar height
' each view may have specific logic according to button bar presence
' it may implemented in SGDEX_UpdateViewUI
sub SGDEX_UpdateBaseViewUI()
    buttonBar = m.top.getScene().buttonBar
    isButtonBarVisible = buttonBar.visible
    isButtonBarOverlay = buttonBar.overlay
    overhang = m.top.findNode("overhang")
    overhangHeight = overhang.height
    if not overhang.visible
        overhangHeight = 0
    end if

    viewContentOffsetY = overhangHeight + m.viewOffsetY
    viewContentOffsetX = 0

    if isButtonBarVisible
        buttonBar.translation = [0, overhangHeight]
        if not isButtonBarOverlay
            if buttonBar.alignment = "top"
                viewContentOffsetY += buttonBar.findNode("backgroundRectangle").height
            else if buttonBar.alignment = "left"
                viewContentOffsetX += buttonBar.findNode("backgroundRectangle").width + m.viewOffsetX
            end if
        end if
        SGDEX_OnOverhangHeightChange()
    end if

    ' if viewContentOffsetY + overhangHeight > m.defaultOverhangHeight
    '     viewContentOffsetY += overhangHeight - m.defaultOverhangHeight
    ' end if

    if viewContentOffsetY < m.contentAreaSafeZoneYPosition
        viewContentOffsetY = m.contentAreaSafeZoneYPosition
    end if

    m.top.viewContentGroup.translation = [viewContentOffsetX, viewContentOffsetY]

    SGDEX_UpdateViewUI()
end sub


' Each view may have specific UI adjustments depends on button bar and overhang
' to implement so, need to override this function
sub SGDEX_UpdateViewUI()
end sub


'this function will return view key to retrieve it from global theme map
function SGDEX_GetViewType() as String
    return "global"
end function

sub SGDEX_SetTheme(theme as Object)
    ? "INFO: implement SGDEX_SetTheme(theme as AA) to set theme to your view"
end sub

sub SGDEX_ViewUpdateThemeObserver(event as Object)
    if m.themeDebug then ? "SGDEX_ViewUpdateThemeObserver"
    theme = {}

    data = event.GetData()
    if m.themeDebug then ? "data="event.GetData()
    theme.Append(data)
    SGDEX_InternalSetTheme(theme, true)
end sub

sub SGDEX_GlobalUpdateThemeObserver(event as Object)
    if m.themeDebug then ? "SGDEX_GlobalUpdateThemeObserver"
    newTheme = event.GetData()
    newSceneTheme = {}
    globalTheme = m.top.getScene().actualThemeParameters
    if globalTheme <> invalid then
        newSceneTheme.append(globalTheme)
        for each key in newSceneTheme
            themeSet = newSceneTheme[key]
            newThemeSet = newTheme[key]
            if GetInterface(themeSet, "ifAssociativeArray") <> invalid and GetInterface(newThemeSet, "ifAssociativeArray") <> invalid then
                themeSet.append(newThemeSet)
            end if
        end for

    end if
    for each key in newTheme
        if newSceneTheme[key] = invalid then newSceneTheme[key] = newTheme[key]
    end for

    m.top.getScene().actualThemeParameters = newSceneTheme
    SGDEX_InternalBuildAndSetTheme(invalid, newTheme)
end sub

'Functions for setting initial theme
sub SGDEX_GlobalThemeObserver(event as Object)
    if m.themeDebug then ? "SGDEX_GlobalThemeObserver"
    newTheme = event.GetData()
    m.top.getScene().actualThemeParameters = newTheme
    SGDEX_InternalBuildAndSetTheme(m.top.theme, newTheme)
end sub

sub SGDEX_ViewThemeObserver(event as Object)
    theme = {}
    if m.top.getScene().theme <> invalid then theme.Append(m.top.getScene().theme)
    theme.Append(event.GetData())
    SGDEX_InternalBuildAndSetTheme(m.top.theme, theme)
end sub


'Function for building theme params for view from global and view specific field
sub SGDEX_InternalBuildAndSetTheme(viewTheme as Object, newTheme as Object, isUpdate = false as Boolean)
    if GetInterface(newTheme, "ifAssociativeArray") <> invalid then
        viewKey = SGDEX_GetViewType()
        theme = {}

        theme.Append(SGDEX_GetViewSpecificTheme(viewKey, newTheme)) ' Setting specific theme attributes, e.g. for endcard
        if GetInterface(newTheme["global"], "ifAssociativeArray") <> invalid then theme.Append(newTheme["global"])
        if GetInterface(newTheme[viewKey], "ifAssociativeArray") <> invalid then theme.Append(newTheme[viewKey])
        if GetInterface(viewTheme, "ifAssociativeArray") <> invalid then theme.Append(viewTheme)
        SGDEX_InternalSetTheme(theme, isUpdate)

        buttonBar = m.top.getScene().buttonBar
        if buttonBar <> invalid
            SGDEX_UpdateBaseViewUI()
        end if
    end if
end sub

'function for setting all required theme attributes to all nodes
sub SGDEX_InternalSetTheme(theme as Object, isUpdate = false as Boolean)
    if m.LastThemeAttributes <> invalid and isUpdate then
        m.LastThemeAttributes.Append(theme)
    else
        m.LastThemeAttributes = theme
    end if
    SGDEX_SetOverhangTheme(theme)
    SGDEX_SetBackgroundTheme(theme)

    SGDEX_SetTheme(theme)
end sub

sub SGDEX_SetOverhangTheme(theme)
    overhang = m.top.overhang
    if overhang <> invalid then
        SGDEX_setThemeFieldstoNode(m.top, {
            TextColor: {
                overhang: [
                    "titleColor"
                    "clockColor"
                    "optionsColor"
                    "optionsDimColor"
                    "optionsIconColor"
                    "optionsIconDimColor"
                ]
            }
        }, theme)

        overhangThemeAttributes = {
            'Main attribute
            Overhangtitle:                   "title"
            OverhangshowClock:               "showClock"
            OverhangshowOptions:             "showOptions"
            OverhangoptionsAvailable:        "optionsAvailable"
            Overhangvisible:                 "visible"
            OverhangtitleColor:              "titleColor"
            OverhangLogoUri:                 "logoUri"
            OverhangbackgroundUri:           "backgroundUri"
            OverhangoptionsText:             "optionsText"
            Overhangheight:                  "height"
            OverhangBackgroundColor:         "color"

            'Additional attributes, no need to document these
            OverhangclockColor:              "clockColor"
            OverhangclockText:               "clockText"
            OverhangleftDividerUri:          "leftDividerUri"
            OverhangleftDividerVertOffset:   "leftDividerVertOffset"
            OverhanglogoBaselineOffset:      "logoBaselineOffset"
            OverhangOptionsColor:            "optionsColor"
            OverhangOptionsDimColor:         "optionsDimColor"
            OverhangOptionsIconColor:        "optionsIconColor"
            OverhangOptionsIconDimColor:     "optionsIconDimColor"
            OverhangOptionsMaxWidth:         "optionsMaxWidth"
            OverhangrightDividerUri:         "rightDividerUri"
            OverhangrightDividerVertOffset:  "rightDividerVertOffset"
            OverhangrightLogoBaselineOffset: "rightLogoBaselineOffset"
            Overhangtranslation:             "translation"
        }

        ' RDE-2697: work around a FW issue where setting showOptions changes the overhang height unexpectedly
        if theme.OverhangshowOptions = false
            if theme.OverhanglogoBaselineOffset = invalid
                theme.OverhanglogoBaselineOffset = 13
            else
                theme.OverhanglogoBaselineOffset += 13
            end if
        end if

        for each key in theme
            if overhangThemeAttributes[key] <> invalid then
                field = overhangThemeAttributes[key]
                value = theme[key]
                SGDEX_SetThemeAttribute(overhang, field, value, "")
            end if
        end for
    end if
end sub

sub SGDEX_SetBackgroundTheme(theme as Object)
    colorTheme = {}
    if GetInterface(theme.backgroundImageURI, "ifString") <> invalid
        ' don't use backgroundColor for blending color as it's used for other Views
        ' so developers don't want it to be applied to this View
        colorTheme = { backgroundImageURI: { backgroundImage: "uri" } }
        m.backgroundImage.visible = true
        m.backgroundRectangle.visible = false
    else if GetInterface(theme.backgroundColor, "ifString") <> invalid
        colorTheme = { backgroundColor: { backgroundRectangle: "color" } }
        m.backgroundImage.visible = false
        m.backgroundRectangle.visible = true
    end if
    SGDEX_setThemeFieldstoNode(m, colorTheme, theme)
end sub

' Function returns all theme attributes specified especially for this view
' For example:
' m.top.theme = {
'     mediaView: {
'          textColor: "0xFFFFFF"
'     }
' }
function SGDEX_GetViewSpecificTheme(viewKey as String, newTheme as Object) as Object
    viewTheme = {}

    if viewKey = "endcardView"
        if newTheme["videoView"] <> invalid then viewTheme.Append(newTheme["videoView"]) ' Sharing videoView theme attributes with endcardView.
        if newTheme["mediaView"] <> invalid then viewTheme.Append(newTheme["mediaView"]) ' Sharing mediaView theme attributes with endcardView.
    else if viewKey = "mediaView"
        if newTheme["videoView"] <> invalid then viewTheme.Append(newTheme["videoView"]) ' Sharing videoView theme attributes with mediaView.
    end if
    if newTheme[viewKey] <> invalid then viewTheme.Append(newTheme[viewKey])
    return viewTheme
end function

'This function is used to set theme attributes to nodes
'It support advanced setup of theming config
'Example


'map = {
'    >>> 'Theme attribute name
'    genericColor: {
'        'for each attribute in video node set "genericColor" value
'        video: [
'            "bufferingTextColor",
'            "retrievingTextColor"

'           >>> for internal fields of video also set this value
'            {
'                trickPlayBar: [
'                    "textColor"
'                    "thumbBlendColor"
'                ]
'            }
'        ]
'
'    }
'
'
'    bufferingTextColor:             { video: "bufferingTextColor" }
'
'    textColor:                      { video: { trickPlayBar: "textColor" } }
'    currentTimeMarkerBlendColor:    "currentTimeMarkerBlendColor"
'
'}


'@param node - root AA or node for searching sub nodes
'@param map - developer defined config for theme
'@param theme - theme that should be set

sub SGDEX_setThemeFieldstoNode(node, map, theme)
    for each field in map
        attribute = map[field]
        if theme.DoesExist(field) then
            value = theme[field]
            if GetInterface(attribute, "ifAssociativeArray") <> invalid then
                SGDEX_SetValueToAllNodes(node, attribute, value)
            else
                SGDEX_SetThemeAttribute(node, field, value, "")
            end if
        end if
    end for
end sub

sub SGDEX_SetValueToAllNodes(node, attributes, value)
    if node <> invalid then
        for each key in attributes
            properField = attributes[key]
            if GetInterface(properField, "ifAssociativeArray") <> invalid then
                SGDEX_SetValueToAllNodes(node[key], properField, value)
            else if GetInterface(properField, "ifArray") <> invalid
                for each arrayField in properField
                    if GetInterface(arrayField, "ifAssociativeArray") <> invalid then
                        SGDEX_SetValueToAllNodes(node[key], arrayField, value)
                    else if node[key] <> invalid
                        SGDEX_SetThemeAttribute(node[key], arrayField, value, "")
                    end if
                end for
            else if node[key] <> invalid
                SGDEX_SetThemeAttribute(node[key], properField, value, "")
            end if
        end for
    end if
end sub

sub SGDEX_SetThemeAttribute(node, field as String, value as Object, defaultValue = invalid)
    properValue = defaultValue
    if value <> invalid then
        properValue = value
    end if

    if m.themeDebug then ? "SGDEX_SetThemeAttribute, field="field" , value=["properValue"]"
    node[field] = properValue
end sub

function GetViewXPadding()
    return 126
end function