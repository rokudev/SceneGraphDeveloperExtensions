' Copyright (c) 2019 Roku, Inc. All rights reserved.

' README:
' MediaView is a SGDEX component to play video items or playlists
' In channel developer create MediaView,
' set content - it is a playlist, has childs with items
' to configure starting item, there is jumpToItem field see OnJumpToItem field
' and to configure to play - set control to "play"
' there is possibility to set "buffering" control
'   video = CreateObject("roSGNode", "MediaView")
'   video.content = content
'   video.jumpToItem = index
'   video.control = "play"

sub Init()
    ' Reset default value to avoid issues with auto-translation of default value specified in xml file
    m.top.mode = "video"

    ' Initiate the view setup to run the Content Manager before the view has been shown 
    ' to make preloading work properly
    m.top.GetScene().ComponentController.callFunc("setup", {view: m.top})

    m.buttonBar = m.top.getScene().buttonBar
    m.isButtonBarVisible = m.buttonBar.visible
    m.top.ObserveField("media", "OnMediaChanged")
    m.top.ObserveField("RafTask", "OnRafTaskChanged")
    m.top.ObserveField("endcardView", "OnEndcardViewChanged")
    m.top.ObserveField("posterShape", "OnResetPosterShape")
end sub

sub OnEndcardViewChanged()
    if m.top.endcardView <> invalid and m.top.endcardView.isSameNode(m.prevEndcardView) = false and m.lastThemeAttributes <> invalid
        endcardTheme = m.lastThemeAttributes
        sceneTheme = m.top.getScene().actualThemeParameters
        if sceneTheme <> invalid and sceneTheme.endcardView <> invalid
            endcardTheme.Append(sceneTheme.endcardView)
        end if
        m.top.endcardView.updateTheme = endcardTheme
    end if
    m.prevEndcardView = m.top.endcardView
end sub

sub OnMediaChanged(event as Object)
    if m.top.media <> invalid and m.top.media.isSameNode(m.prevMedia) = false
        ' if overhang height was not set through theme then
        ' change default overhang height to content area safe zone
        if m.lastThemeAttributes <> invalid and m.isButtonBarVisible
            if m.lastThemeAttributes.overhangHeight = invalid
                m.overhangHeight = m.top.overhang.height
                if m.top.mode = "audio"
                    m.top.overhang.height = m.defaultOverhangHeight
                else
                    m.top.overhang.height = m.contentAreaSafeZoneYPosition
                end if
            end if
        end if
        
        if m.lastThemeAttributes <> invalid
            SGDEX_SetTheme(m.lastThemeAttributes)
        end if

        SGDEX_UpdateViewUI()
    end if
    m.prevMedia = m.top.media
end sub

sub OnRafTaskChanged()
    if m.top.RafTask <> invalid and m.top.RafTask.isSameNode(m.prevRafTask) = false
        m.top.RafTask.ObserveField("renderNode","OnRAFRenderNodeChanged")
    end if
    m.prevRafTask = m.top.RafTask
end sub

sub OnRAFRenderNodeChanged()
    if m.top.RafTask <> Invalid
        m.top.RafTask.UnobserveField("renderNode")
        if isCSASEnabled() and m.lastThemeAttributes <> Invalid
            SetThemeToRAFRenderNode()
        end if
    end if
end sub

function isCSASEnabled() as Boolean
    return (m.top.currentRAFHandler <> invalid and m.top.currentRAFHandler.useCSAS = true)
end function

sub OnResetPosterShape(event as Object)
    if m.top.npn <> invalid
        poster = m.top.npn.findNode("poster")
        poster.shape = event.getData()
        SGDEX_UpdateViewUI()
    end if
end sub

' ************* Theme functions *************

sub SGDEX_SetTheme(theme as Object)
    SGDEX_setThemeFieldstoNode(m.top, {
        TextColor: {
            media: [
                {
                    trickPlayBar:  [
                        "textColor"
                        "thumbBlendColor"
                        "trackBlendColor"
                        "currentTimeMarkerBlendColor"
                    ]
                    retrievingBar: [
                        "trackBlendColor"
                    ]
                    bufferingBar: [
                        "trackBlendColor"
                    ]
                }
                "bufferingTextColor",
                "retrievingTextColor"
            ]
        }
        progressBarColor: {
            media: [{
                trickPlayBar:  [
                    "filledBarBlendColor"
                ]
                retrievingBar: [
                    "filledBarBlendColor"
                ]
                bufferingBar: [
                    "filledBarBlendColor"
                ]
            }]
        }
    }, theme)

    themeAttributes = {
        ' trickplay Bar customization
        trickPlayBarTextColor:                      { media: { trickPlayBar: "textColor" } }
        trickPlayBarTrackImageUri:                  { media: { trickPlayBar: "trackImageUri" } }
        trickPlayBarTrackBlendColor:                { media: { trickPlayBar: "trackBlendColor" } }
        trickPlayBarThumbBlendColor:                { media: { trickPlayBar: "thumbBlendColor" } }
        trickPlayBarFilledBarImageUri:              { media: { trickPlayBar: "filledBarImageUri" } }
        trickPlayBarFilledBarBlendColor:            { media: { trickPlayBar: "filledBarBlendColor" } }
        trickPlayBarCurrentTimeMarkerBlendColor:    { media: { trickPlayBar: "currentTimeMarkerBlendColor" } }

        ' Buffering Bar customization
        bufferingTextColor:                         { media: "bufferingTextColor" }
        bufferingBarEmptyBarImageUri:               { media: { bufferingBar: "emptyBarImageUri" } }
        bufferingBarFilledBarImageUri:              { media: { bufferingBar: "filledBarImageUri" } }
        bufferingBarTrackImageUri:                  { media: { bufferingBar: "trackImageUri" } }

        bufferingBarTrackBlendColor:                { media: { bufferingBar: "trackBlendColor" } }
        bufferingBarEmptyBarBlendColor:             { media: { bufferingBar: "emptyBarBlendColor" } }
        bufferingBarFilledBarBlendColor:            { media: { bufferingBar: "filledBarBlendColor" } }

        ' Retrieving Bar customization
        retrievingTextColor:                        { media: "retrievingTextColor" }
        retrievingBarEmptyBarImageUri:              { media: { retrievingBar: "emptyBarImageUri" } }
        retrievingBarFilledBarImageUri:             { media: { retrievingBar: "filledBarImageUri" } }
        retrievingBarTrackImageUri:                 { media: { retrievingBar: "trackImageUri" } }

        retrievingBarTrackBlendColor:               { media: { retrievingBar: "trackBlendColor" } }
        retrievingBarEmptyBarBlendColor:            { media: { retrievingBar: "emptyBarBlendColor" } }
        retrievingBarFilledBarBlendColor:           { media: { retrievingBar: "filledBarBlendColor" } }

        ' BIF customization
        focusRingColor:                             { media: { bifDisplay: "frameBgBlendColor" } }
    }

    ' RDE-2876: Workaround to prevent user from  unintentionally changing clock color
    ' when setting explicitly trickPlayBarTextColor and retrievingTextColor fields
    if theme.textColor = invalid and (theme.trickPlayBarTextColor <> invalid or theme.retrievingTextColor <> invalid)
        SGDEX_setThemeFieldstoNode(m.top, themeAttributes, {
            trickPlayBarTextColor: "0xffffff"
            retrievingTextColor: "0xffffff"
        })
    end if

    ' sharing theme attributes with NowPlayingView
    if m.lastThemeAttributes <> invalid and m.top.npn <> invalid
        npnTheme = m.lastThemeAttributes
        sceneTheme = m.top.getScene().actualThemeParameters
        if sceneTheme <> invalid and sceneTheme.NowPlayingView <> invalid
            npnTheme.Append(sceneTheme.NowPlayingView)
        end if
        m.top.npn.theme = npnTheme
    end if
    SGDEX_setThemeFieldstoNode(m.top, themeAttributes, theme)
end sub

sub SetThemeToRAFRenderNode()
    SGDEX_setThemeFieldstoNode(m.top.RAFTask, {
        TextColor: {
            renderNode: [
                {
                    trickPlayBar:  [
                        "textColor"
                        "thumbBlendColor"
                        "trackBlendColor"
                        "currentTimeMarkerBlendColor"
                    ]
                    retrievingBar: [
                        "trackBlendColor"
                    ]
                    bufferingBar: [
                        "trackBlendColor"
                    ]
                }
                "bufferingTextColor",
                "retrievingTextColor"
            ]
        }
        progressBarColor: {
            renderNode: [{
                trickPlayBar:  [
                    "filledBarBlendColor"
                ]
                retrievingBar: [
                    "filledBarBlendColor"
                ]
                bufferingBar: [
                    "filledBarBlendColor"
                ]
            }]
        }
    }, m.lastThemeAttributes)

    themeAttributes = {
        ' trickplay Bar customization
        trickPlayBarTextColor:                      { renderNode: { trickPlayBar: "textColor" } }
        trickPlayBarTrackImageUri:                  { renderNode: { trickPlayBar: "trackImageUri" } }
        trickPlayBarTrackBlendColor:                { renderNode: { trickPlayBar: "trackBlendColor" } }
        trickPlayBarThumbBlendColor:                { renderNode: { trickPlayBar: "thumbBlendColor" } }
        trickPlayBarFilledBarImageUri:              { renderNode: { trickPlayBar: "filledBarImageUri" } }
        trickPlayBarFilledBarBlendColor:            { renderNode: { trickPlayBar: "filledBarBlendColor" } }
        trickPlayBarCurrentTimeMarkerBlendColor:    { renderNode: { trickPlayBar: "currentTimeMarkerBlendColor" } }

        ' Buffering Bar customization
        bufferingTextColor:                         { renderNode: "bufferingTextColor" }
        bufferingBarEmptyBarImageUri:               { renderNode: { bufferingBar: "emptyBarImageUri" } }
        bufferingBarFilledBarImageUri:              { renderNode: { bufferingBar: "filledBarImageUri" } }
        bufferingBarTrackImageUri:                  { renderNode: { bufferingBar: "trackImageUri" } }

        bufferingBarTrackBlendColor:                { renderNode: { bufferingBar: "trackBlendColor" } }
        bufferingBarEmptyBarBlendColor:             { renderNode: { bufferingBar: "emptyBarBlendColor" } }
        bufferingBarFilledBarBlendColor:            { renderNode: { bufferingBar: "filledBarBlendColor" } }

        ' Retrieving Bar customization
        retrievingTextColor:                        { renderNode: "retrievingTextColor" }
        retrievingBarEmptyBarImageUri:              { renderNode: { retrievingBar: "emptyBarImageUri" } }
        retrievingBarFilledBarImageUri:             { renderNode: { retrievingBar: "filledBarImageUri" } }
        retrievingBarTrackImageUri:                 { renderNode: { retrievingBar: "trackImageUri" } }

        retrievingBarTrackBlendColor:               { renderNode: { retrievingBar: "trackBlendColor" } }
        retrievingBarEmptyBarBlendColor:            { renderNode: { retrievingBar: "emptyBarBlendColor" } }
        retrievingBarFilledBarBlendColor:           { renderNode: { retrievingBar: "filledBarBlendColor" } }

        ' BIF customization
        focusRingColor:                             { renderNode: { bifDisplay: "frameBgBlendColor" } }
    }

    SGDEX_setThemeFieldstoNode(m.top.RAFTask, themeAttributes, m.lastThemeAttributes)
end sub

function SGDEX_GetViewType() as String
    return "mediaView"
end function

sub SGDEX_UpdateViewUI()
    if m.top.mode = "audio" and m.top.npn <> invalid
        buttons = m.top.npn.findNode("buttons")
        nowPlayingUIGroup = m.top.npn.findNode("nowPlayingUI")
        poster = nowPlayingUIGroup.findNode("poster")
		m.albumInfo = nowPlayingUIGroup.findNode("albumInfo")
        m.titleInfo = nowPlayingUIGroup.findNode("titleInfo")
        m.artistInfo = nowPlayingUIGroup.findNode("artistInfo")
        m.releaseInfo = nowPlayingUIGroup.findNode("releaseInfo")

        defaultWidth = 1024
        defaultButtonLength = 340
        buttonLength = defaultButtonLength
        posterWidth = poster.width
        if posterWidth > 300
            buttonLength = defaultWidth/2 - posterWidth/2 - 30
        else
            posterWidth = 300
        end if
        defaultButtonSize = [buttonLength, 48]

        buttonsTranslationX = nowPlayingUIGroup.boundingRect().x + nowPlayingUIGroup.boundingRect().width / 2 + posterWidth / 2 + 30
        buttons.itemSize = defaultButtonSize
        buttons.rowItemSize = [defaultButtonSize]
        buttons.translation = [buttonsTranslationX, buttons.translation[1]]

        if m.top.overhang <> invalid and m.top.overhang.visible
            overhangHeight = m.top.overhang.height
        else
            overhangHeight = 0
        end if

        if m.buttonBar.visible and m.buttonBar.overlay = false and m.buttonBar.alignment = "top"
            buttonBarHeight = GetButtonBarHeight()
        else
            buttonBarHeight = 0
        end if
        ' Moving of viewContentGroup should be avoided otherwise it will lead to UI issues
        m.top.viewContentGroup.translation = [m.top.viewContentGroup.translation[0], 0]
        componentsHeight = overhangHeight + buttonBarHeight + 30
        yOffset = componentsHeight - nowPlayingUIGroup.translation[1]
        if yOffset > 0
            nowPlayingUIGroup.translation = [nowPlayingUIGroup.translation[0], nowPlayingUIGroup.translation[1] + yOffset]
            buttons.translation = [buttons.translation[0], buttons.translation[1] + yOffset]
            nowPlayingUIGroupPosInfo = nowPlayingUIGroup.boundingRect()
            nowPlayingUIGroupYPosition = nowPlayingUIGroupPosInfo["y"]
            nowPlayingUIGroupHeight = nowPlayingUIGroupPosInfo["height"]

            ' adjust poster size based on overhang and buttonBar height adjust poster size based on overhang and buttonBar sizes 
            ' to avoid situation when npm UI gets out of the safe zone
            vertDiff = 720 - nowPlayingUIGroupYPosition - m.contentAreaSafeZoneYPosition - nowPlayingUIGroupHeight - yOffset
            if vertDiff < 0
                if vertDiff >= -150
                    poster.maxHeight = 300 + vertDiff
                    buttons.numRows = poster.height / buttons.itemSize[1] - 1
                else
                    poster.maxHeight = 150
                    buttons.numRows = 2
               end if
            end if
        else
             YValue = nowPlayingUIGroup.translation[1] + yOffset
             if YValue < m.contentAreaSafeZoneYPosition
                YValue = m.contentAreaSafeZoneYPosition
             end if
             nowPlayingUIGroup.translation = [nowPlayingUIGroup.translation[0], YValue]
             buttons.translation = [buttons.translation[0], YValue]
        end if

        if m.buttonBar.alignment = "left" and (m.buttonBar.visible = true and m.buttonBar.overlay = false)
            buttonBarWidth = GetButtonBarWidth()
            minWidth = 2*(poster.width/2 + 30 + defaultButtonSize[0]/2)
            defaultTranslation = [652, 140]
            buttonsTranslation = [832, 140]
            XtranslationDiff = buttonsTranslation[0] - defaultTranslation[0] + defaultButtonLength - buttonLength
            ' adjust labels width and buttons size to avoid situation when npm UI gets out of the safe zone
            if not m.buttonBar.isInFocusChain() and m.buttonBar.autoHide
                m.top.viewContentGroup.translation = [0,m.top.viewContentGroup.translation[1]]
                m.titleInfo.maxWidth = defaultWidth
                m.artistInfo.maxWidth = defaultWidth
                m.albumInfo.maxWidth = defaultWidth
                m.releaseInfo.maxWidth = defaultWidth
                nowPlayingUIGroup.translation = [defaultTranslation[0], nowPlayingUIGroup.translation[1]]
                buttons.translation = [defaultTranslation[0] + XtranslationDiff, buttons.translation[1]]
                buttons.itemSize = defaultButtonSize
                buttons.rowItemSize = [defaultButtonSize]
            else
                tranX = m.top.viewContentGroup.translation[0]
                m.top.viewContentGroup.translation = [0,m.top.viewContentGroup.translation[1]]
                xValue = nowPlayingUIGroup.boundingRect()["x"]
                xOffset = (buttonBarWidth + 10) - xValue
                widthDiff = defaultWidth - buttonBarWidth  + GetViewXPadding()
                newLength = widthDiff
                if minWidth > newLength
                    newLength = minWidth
                end if
                buttonLength = newLength/2 - posterWidth/2 - 30
                buttons.itemSize = [buttonLength, buttons.itemSize[1]]
                buttons.rowItemSize = [[buttonLength, buttons.itemSize[1]]]
                if xOffset > 0
                    m.titleInfo.maxWidth = newLength
                    m.artistInfo.maxWidth = newLength
                    m.albumInfo.maxWidth = newLength
                    m.releaseInfo.maxWidth = newLength
                    nowPlayingUIGroup.translation = [newLength/2 + tranX, nowPlayingUIGroup.translation[1]]
                    buttons.translation = [newLength/2 + tranX + XtranslationDiff, buttons.translation[1]]
                end if
            end if
        end if
    end if
end sub

sub customSuspend()
    print "Suspend"
end sub

sub customResume()
    'On Resume if the player is stopped then close the view
    'to go back to the previous screen
    stateNode = m.top.findNode("stateNode")
    if stateNode <> invalid and stateNode.state = "stopped"
        m.top.close = true
    end if
end sub