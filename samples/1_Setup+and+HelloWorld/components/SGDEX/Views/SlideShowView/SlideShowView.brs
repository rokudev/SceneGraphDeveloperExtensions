' Copyright (c) 2019 Roku, Inc. All rights reserved.

sub Init()
    m.debug = false
    m.ContentManager_id = 0

    ' Obtain real display UI resolution for proper setting of loadWidth/loadHeight
    deviceInfo = CreateObject("roDeviceinfo")
    m.displayWidth = 1280
    m.displayHeight = 720
    if deviceInfo <> invalid
        uiResolution = deviceInfo.GetUIResolution()
        if uiResolution.width <> invalid and uiResolution.height <> invalid
            m.displayWidth = uiResolution.width
            m.displayHeight = uiResolution.height
        end if
    end if
    
    m.buttonBar = m.top.getScene().buttonBar
    m.isButtonBarVisible = m.buttonBar.visible
    m.renderOverContent = m.buttonBar.renderOverContent
    m.isAutoHideMode = m.buttonBar.autoHide

    m.shadeRectangle = m.top.findNode("shadeRectangle")
    m.shadeRectangle.opacity = 0.0
    m.shadeRectangle.width = 1280
    m.shadeRectangle.height = 720
    m.shadeRectangle.color = "0x000000"

    m.fadeAnimation = m.top.findNode("fadeAnimation")
    m.fadeInterpolator = m.top.findNode("fadeInterpolator")

    m.shadeAnimation = m.top.findNode("shadeAnimation")
    m.shadeAnimationInterp = m.top.findNode("shadeAnimationInterp")

    m.fadeIconAnimation = m.top.findNode("fadeIconAnimation")
    m.fadeIconPlayInterpolator = m.top.findNode("fadeIconPlayInterpolator")
    m.fadeIconPauseInterpolator = m.top.findNode("fadeIconPauseInterpolator")

    m.iconPlay = m.top.findNode("iconPlay")
    m.iconPause = m.top.findNode("iconPause")

    m.spinner = m.top.findNode("spinner")
    m.spinner.uri = "pkg:/components/SGDEX/Images/loader.png"

    m.background = m.top.findNode("background")
    m.backgroundImgPosition = m.top.findNode("backgroundImgPosition")
    m.mainImagePosition = m.top.findNode("mainImagePosition")

    m.hud = m.top.findNode("hud")
    m.hudTitle = m.top.findNode("hudTitle")
    m.hudText = m.top.findNode("hudText")

    m.slideTimer = m.top.findNode("slideTimer")
    m.slideTimer.ObserveFieldScoped("fire", "OnSlideTimerFireChanged")

    m.hudTimer = m.top.findNode("hudTimer")
    m.hudTimer.ObserveFieldScoped("fire", "OnHudTimerFireChanged")

    m.iconTimer = m.top.findNode("iconTimer")
    m.iconTimer.ObserveFieldScoped("fire", "OnIconTimerFireChanged")

    m.top.ObserveFieldScoped("wasShown", "OnWasShown")

    ' When view is closed and buttonBar was hidden by view we need to show it back
    m.top.ObserveField("wasClosed", "OnWasClosed")

    m.top.ObserveFieldScoped("content", "OnContentSet")

    m.top.ObserveFieldScoped("jumpToItem", "OnJumpToItemChanged")

    m.top.ObserveFieldScoped("control", "OnControlChanged")

    m.top.ObserveFieldScoped("focusedChild", "OnFocusedChildChange")

    m.currentContentNode = invalid
    m.hudTitleText = ""
    m.hudDescriptionText = ""
    overhangHeightTheme = invalid
    if m.LastThemeAttributes <> invalid then
        SGDEX_SetTheme(m.LastThemeAttributes)
        overhangHeightTheme = m.LastThemeAttributes.overhangHeight
    end if

    ' if overhang height was not set through theme then
    ' change default overhang height to content area safe zone
    if m.isButtonBarVisible and overhangHeightTheme = invalid
        m.top.overhang.height = m.contentAreaSafeZoneYPosition
    end if
end sub

sub OnContentSet()
    content = m.top.content

    if content <> invalid
        if (m.currentContentNode = invalid or not m.currentContentNode.IsSameNode(m.top.content))
            if m.top.isContentList
                if m.top.content.HandlerConfigSlideShow <> invalid and m.top.content.GetChildCount() = 0
                    ShowBusySpinner(true)
                    handlerConfig = m.top.content.HandlerConfigSlideShow
                    m.top.content.HandlerConfigSlideShow = invalid
                    callback = {
                        config: handlerConfig

                        onReceive: sub(data)
                            gthis = GetGlobalAA()
                            if data <> invalid and data.GetChildCount() > 0
                                ' replace data if needed
                                if not data.IsSameNode(gthis.top.content) then gthis.top.content = data
                                ' fire focus change that will redraw UI and tell developer which item is focused
                                gthis.top.jumpToItem = gthis.top.currentIndex
                            end if
                        end sub

                        onError: sub(data)
                            gthis = GetGlobalAA()
                            if gthis.top.content.HandlerConfigDetails <> invalid then
                                m.config = gthis.top.content.HandlerConfigDetails
                                gthis.top.content.HandlerConfigDetails = invalid
                            end if
                            m.contentHandler = GetContentData(m, m.config, gthis.top.content)
                        end sub
                    }
                    m.contentHandler = GetContentData(callback, handlerConfig, m.top.content)
                else
                    m.top.jumpToItem = m.top.currentIndex
                end if
            else
                handlerConfig = m.top.content.HandlerConfigSlideShow
                if handlerConfig <> invalid
                    ShowBusySpinner(true)
                    m.top.content.HandlerConfigSlideShow = invalid
                    LoadMoreContent(m.top.content, handlerConfig)
                end if
            end if
        end if
        m.currentContentNode = m.top.content
    end if
end sub

sub OnWasShown()
    if m.top.wasShown
        if m.backgroundImg <> invalid
            m.backgroundImg.visible = false
        end if
        m.top.jumpToItem = m.top.currentIndex

        if m.isButtonBarVisible and m.renderOverContent
            m.buttonBar.visible = true
        else
            m.buttonBar.visible = false
        end if
    end if
end sub

sub OnImageLoadStatusChanged(event as Object)
    status = event.GetData()
    if status = "loading"
        RunShadeAnimation(true)
    else if status = "ready"
        SetSizeForImage()
        m.hudTitle.text = m.hudTitleText
        m.hudText.text = m.hudDescriptionText
        RunShadeAnimation(false)
        RunTimer()
    else if status = "failed"
        index = m.top.currentIndex + 1
        if m.top.currentIndex <> index
            m.top.jumpToItem = index
        end if
    end if
end sub

sub OnControlChanged(event as Object)
    control = event.GetData()
    if m.top.isContentList
        if control = "play"
            m.fadeIconPauseInterpolator.keyValue = [m.iconPause.opacity, 0.0]
            m.fadeIconPlayInterpolator.keyValue = [m.iconPlay.opacity, 1.0]
            m.fadeIconAnimation.control = "start"
            m.iconTimer.control = "start"
            if IsContentLoaded()
                m.slideTimer.control = "start"
            end if
        else if control = "pause"
            m.fadeIconPlayInterpolator.keyValue = [m.iconPlay.opacity, 0.0]
            m.fadeIconPauseInterpolator.keyValue = [m.iconPause.opacity, 1.0]
            m.fadeIconAnimation.control = "start"
            m.iconTimer.control = "start"
            m.slideTimer.control = "stop"
        end if
    end if
end sub

sub OnJumpToItemChanged(event as Object)
    content = m.top.content
    if content <> invalid and m.top.isContentList
        jump = event.GetData()
        isJumpValid = jump >= 0 and content.GetChildCount() > jump
        if isJumpValid or not IsContentLoaded()
            m.top.currentIndex = jump
        else if m.top.loop
            if jump < 0
                m.top.currentIndex = content.GetChildCount() - 1
            else
                m.top.currentIndex = 0
            end if
        else if m.top.closeAfterLastSlide
            m.top.close = true
        end if
    end if
    UpdateContentToDisplay()
end sub

sub OnSlideTimerFireChanged(event as Object)
    index = m.top.currentIndex
    isLastItem = (m.top.content.GetChildCount() - 1 = index)
    needToClose = m.top.closeAfterLastSlide and (m.top.loop = false) and isLastItem
    if needToClose
        m.top.close = true
        return
    end if
    if m.top.isContentList
        m.top.jumpToItem = index + 1
    end if
end sub

sub OnHudTimerFireChanged(event as Object)
    m.hudTimer.control = "stop"
    m.fadeInterpolator.keyValue = [m.hud.opacity, 0.0]
    m.fadeAnimation.control = "start"

    if not m.renderOverContent and m.top.control = "play" and not m.buttonBar.IsInFocusChain()
        m.buttonBar.visible = false
    end if
end sub

sub OnIconTimerFireChanged()
    m.iconTimer.control = "stop"
    m.fadeIconPauseInterpolator.keyValue = [m.iconPause.opacity, 0.0]
    m.fadeIconPlayInterpolator.keyValue = [m.iconPlay.opacity, 0.0]
    m.fadeIconAnimation.control = "start"
end sub

sub ShowBusySpinner(shouldShow)
    if shouldShow then
        if not m.spinner.visible then
            m.spinner.visible = true
            m.spinner.control = "start"
        end if
    else
        m.spinner.visible = false
        m.spinner.control = "stop"
    end if
end sub

sub UpdateContentToDisplay()
    index = m.top.currentIndex
    contentNode = invalid
    preloadContentNode = invalid
    if m.top.content <> invalid and m.top.isContentList
        preloadContentNode = m.top.content.GetChild(index + 1)
        contentNode = m.top.content.GetChild(index)
    else
        contentNode = m.top.content
    end if
    if contentNode <> invalid
        handlerConfig = contentNode.HandlerConfigSlideShow
        if handlerConfig <> invalid
            contentNode.HandlerConfigSlideShow = invalid
            hasMore = handlerConfig.hasMore
            if hasMore = true
                needToLoadMoreItems = index > m.top.content.GetChildCount() - 3
                if needToLoadMoreItems = true
                    LoadMoreContent(m.top.content, handlerConfig)
                else
                    SetContentToDisplay(contentNode)
                end if
            else
                LoadMoreContent(contentNode, handlerConfig)
            end if
        else
            if preloadContentNode <> invalid
                SetPreloadImage(preloadContentNode)
            end if
            SetContentToDisplay(contentNode)
        end if
    end if
end sub

sub RunShadeAnimation(control as Boolean)
    if control = true
        m.shadeAnimationInterp.keyValue = [m.shadeRectangle.opacity, 0.5]
        m.shadeAnimation.control = "start"
    else
        m.shadeAnimationInterp.keyValue = [m.shadeRectangle.opacity, 0.0]
        m.shadeAnimation.control = "start"
    end if
end sub

sub RunTimer()
    if m.top.control = "play" then m.slideTimer.control = "start"
    hasNext = m.top.content.GetChildCount() - 1 > m.top.currentIndex
    if hasNext or m.top.loop
        if m.top.textOverlayVisible and m.hudTimer.duration > 0
            m.hudTimer.control = "start"
            if m.hud.opacity < 1 ' if the HUD isn't visible, show it
                m.fadeInterpolator.keyValue = [m.hud.opacity, 1.0]
                m.fadeAnimation.control = "start"
            end if
        else
            if m.hud.opacity > 0
                m.fadeInterpolator.keyValue = [m.hud.opacity, 0.0]
                m.fadeAnimation.control = "start"
            end if
        end if
    end if
end sub

sub SetSizeForImage()
    if m.mainImage <> invalid
        realHeight = m.mainImage.bitmapHeight
        realWidth = m.mainImage.bitmapWidth

        displayWidth = 1280
        displayHeight = 720

        currentWidth = 0
        currentHeight = 0

        mode = m.top.displayMode

        scaleWidth = displayWidth / realWidth
        scaleHeight = displayHeight / realHeight

        if mode = "no-scale"
            currentWidth = 0
            currentHeight = 0
        else if mode = "scale-to-fill"
            scale = Max(scaleWidth, scaleHeight)
            currentWidth = (realWidth * scale)
            currentHeight = (realHeight * scale)
        else if mode = "scale-to-fit"
            scale = Min(scaleWidth, scaleHeight)
            currentWidth = (realWidth * scale)
            currentHeight = (realHeight * scale)
        else if mode = "zoom-to-fill"
            currentWidth = displayWidth
            currentHeight = displayHeight
        end if
        m.mainImage.width = currentWidth
        m.mainImage.height = currentHeight
        if m.backgroundImg <> invalid
            m.backgroundImg.width = currentWidth
            m.backgroundImg.height = currentHeight
        end if
    end if
end sub

function Max(a as Dynamic, b as Dynamic)
    if a > b
        return a
    else
        return b
    end if
end function

function Min(a as Dynamic, b as Dynamic)
    if a > b
        return b
    else
        return a
    end if
end function

sub LoadMoreContent(content as Object, handlerConfig as Object)
    if handlerConfig <> invalid
        RunShadeAnimation(true)
        callback = {
            currentIndex: m.top.currentIndex
            config: handlerConfig
            content: content
            mAllowEmptyResponse: true

            OnReceive: function(data)
                gthis = GetGlobalAA()
                if data <> invalid and data.GetChildCount() > 0
                    gthis.top.content = data
                    gthis.top.jumpToItem = m.currentIndex
                else
                    if gthis.top.currentIndex = m.currentIndex
                        gthis.top.jumpToItem = m.currentIndex
                    else
                        gthis.top.jumpToItem = gthis.top.currentIndex
                    end if
                end if
            end function

            onError: function(data)
                gthis = GetGlobalAA()
                m.contentHandler = GetContentData(m, m.config, m.content)
            end function
        }
        m.contentHandler = GetContentData(callback, handlerConfig, content)
    end if
end sub

sub SetContentToDisplay(content as Object)
    ShowBusySpinner(false)
    if content <> invalid
        m.hudTitleText = content.title
        m.hudDescriptionText = content.description
        if content.hdPosterUrl <> invalid
            RemovePoster()
            CreatePoster()
            m.mainImage.uri = content.hdPosterUrl
        end if
    end if
end sub

sub CreatePoster()
    if m.mainImage = invalid
        m.mainImage = m.mainImagePosition.CreateChild("Poster")
        m.mainImage.loadDisplayMode = "limitSize"
        m.mainImage.loadWidth = m.displayWidth
        m.mainImage.loadHeight = m.displayHeight
        m.mainImage.ObserveFieldScoped("loadStatus", "OnImageLoadStatusChanged")
    end if
end sub

sub RemovePoster()
    if m.mainImage <> invalid
        m.mainImage.UnObserveFieldScoped("loadStatus")
        m.mainImagePosition.RemoveChild(m.mainImage)
        m.mainImage = invalid
    end if
end sub

sub SetPreloadImage(contentNode as Object)
    if contentNode <> invalid
        if m.backgroundImg = invalid
            m.backgroundImg = m.backgroundImgPosition.CreateChild("Poster")
            m.backgroundImg.visible = false
            m.backgroundImg.loadDisplayMode = "limitSize"
            m.backgroundImg.loadWidth = m.displayWidth
            m.backgroundImg.loadHeight = m.displayHeight
            m.backgroundImg.uri = contentNode.hdPosterUrl
        else
            m.backgroundImg.uri = contentNode.hdPosterUrl
        end if
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    key = lcase(key)
    if press
        if key = "ok"
            if m.top.textOverlayVisible and m.hudTimer.duration > 0
                if m.hud.opacity > 0
                    m.hudTimer.control = "stop"
                    m.fadeInterpolator.keyValue = [m.hud.opacity, 0.0]
                    m.fadeAnimation.control = "start"
                else
                    m.hudTimer.control = "start"
                    m.fadeInterpolator.keyValue = [m.hud.opacity, 1.0]
                    m.fadeAnimation.control = "start"
                end if
            end if
            handled = true
        else if key = "up"
            ' this field is to check for case when BB is hidden but should be
            ' displayed if it is focused
            isButtonBarAvailable = m.renderOverContent and m.isAutoHideMode
            if m.isButtonBarVisible and isButtonBarAvailable and m.buttonBar.alignment = "top"
                m.buttonBar.visible = true
            end if
        else if key = "back"
            ' this field is to check for case when BB is hidden but should be
            ' displayed if it is focused
            isButtonBarAvailable = m.renderOverContent and m.isAutoHideMode
            if m.isButtonBarVisible and isButtonBarAvailable
                m.buttonBar.visible = true
            end if
        else if key = "right"
            index = m.top.currentIndex + 1
            if m.top.currentIndex <> index and m.top.isContentList
                m.top.jumpToItem = index
            end if
            handled = true
        else if key = "left"
            index = m.top.currentIndex - 1
            if m.top.currentIndex <> index and m.top.isContentList
                m.top.jumpToItem = index
            end if
            handled = true
        else if key = "play"
            control = m.top.control
            if control = "play"
                m.top.control = "pause"
            else if control = "pause"
                m.top.control = "play"
            else if control = "none"
                m.top.control = "play"
            end if

            ' if top control paused then we in trick play mode
            ' otherwise we are not
            if m.top.control = "pause"
                HandleTrickPlayMode("stop")
            else if m.top.control = "play"
                HandleTrickPlayMode("play")
            end if
            handled = true
        end if
    end if
    return handled
end function

' This function control appearance of BB in trick play mode.
' It shows and hides when needed and when BB is in not in renderOverContent mode.
' Also we track if BB is focused to keep it on the screen while we still have BB interactions.
sub HandleTrickPlayMode(control as String)
    if not m.renderOverContent and m.isButtonBarVisible
        if control = "stop"
            m.buttonBar.visible = true
        else if m.hud.opacity = 0.0
            m.buttonBar.visible = false
        end if
    end if
end sub

' Return false if content handler is running
' Return true otherwise
function IsContentLoaded()
    isLoaded = true
    if m.contentHandler <> invalid and m.contentHandler.state = "run"
        ' if content handler is running the content is not loaded yet
        isLoaded = false
    end if
    return isLoaded
end function

sub OnFocusedChildChange()
    if m.top.wasShown and m.isButtonBarVisible
        if not m.renderOverContent and m.top.isInFocusChain() and m.top.control = "play"
            ' to hide auto hide hint from the screen
            m.buttonBar.visible = false
        else
            m.buttonBar.visible = true
        end if
    end if
end sub

sub OnWasClosed(event as Object)
    if m.buttonBar <> invalid then m.buttonBar.visible = m.isButtonBarVisible
end sub

sub SGDEX_SetTheme(theme as Object)
    colorTheme = {
        TextColor: {
            hudTitle:           "color"
            hudText:            "color"
        }
        TitleColor: {
            hudTitle:           "color"
        }
        DescriptionColor: {
            hudText:            "color"
        }
        textOverlayBackgroundColor: {
            hudBackgound:       "color"
        }
        BackgroundColor: {
            background:         "color"
        }
        PauseIconColor: {
            iconPause:          "blendColor"
        }
        PlayIconColor: {
            iconPlay:           "blendColor"
        }
    }

    SGDEX_setThemeFieldstoNode(m, colorTheme, theme)

    slideShowThemeAttributes = {
        TitleColor: { hudTitle: "color" }
        DescriptionColor: { hudText: "color" }
        BackgroundColor: { background: "color" }
        textOverlayBackgroundColor: { hudBackgound: "color" }
        PauseIconColor: { iconPause: "blendColor" }
        PlayIconColor: { iconPlay: "blendColor" }
        busySpinnerColor: { spinner: { poster: "blendColor"} }
    }

    SGDEX_setThemeFieldstoNode(m, slideShowThemeAttributes, theme)
end sub

function SGDEX_GetViewType() as String
    return "slideShowView"
end function

sub customSuspend()
    print "Suspend"
    'On Suspend close the slideshow view
    'to go back to the previous screen
    m.top.close = true
end sub

sub customResume()
    print "Resume"
end sub
