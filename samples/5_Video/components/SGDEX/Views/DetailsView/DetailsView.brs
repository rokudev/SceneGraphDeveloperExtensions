' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    ' setup nodes
    m.spinner =          m.top.FindNode("spinner")
    m.spinner.uri =      "pkg:/components/SGDEX/Images/loader.png"

    m.overhang =         m.top.FindNode("overhang")
    m.poster =           m.top.FindNode("poster")
    m.info1Layout =      m.top.FindNode("info1Layout")
    m.info2 =            m.top.FindNode("info2")
    m.info3 =            m.top.FindNode("info3")
    m.viewLayout =       m.top.FindNode("viewLayout")
    m.descriptionLabel = m.top.FindNode("description")
    m.actorsLabel =      m.top.FindNode("actors")
    m.buttons =          m.top.FindNode("buttons")
    m.styledPosterArea = m.top.FindNode("styledPosterArea")

    m.detailsGroup = m.top.findNode("detailsGroup")
    m.top.viewContentGroup.appendChild(m.detailsGroup)

    ' Observe SGDEXComnponent fields
    m.top.ObserveField("style", "OnStyleChange")
    m.top.ObserveField("wasShown", "OnWasShown")
    m.top.ObserveField("posterShape", "OnPosterShapeChange")

    m.top.ObserveField("focusedChild", "OnFocusedChildChanged")
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")
    m.top.ObserveField("currentItem", "OnCurrentItemChanged")
    m.contentObserverIsSet = false


    ' Reference to current ContentNode which populated to DetailsView
    ' To differentiate ContentNode change and ContentNode field change
    m.currentContentNode = invalid

    m.info1 = CreateObject("roSGNode", "Label")
        m.info1.Update({
            id :"info1"
            wrap : "false"
            horizAlign : "right"
        })
    m.info1Layout = CreateObject("roSGNode", "LayoutGroup")
        m.info1Layout.Update({
            id :"info1Layout"
            layoutDirection : "horiz"
            horizAlignment  :"right"
            itemSpacings : "[10,0]"
            children : [m.info1]
    })

    m.viewLayout.insertChild(m.info1Layout,2)

    if m.LastThemeAttributes <> invalid then
        SGDEX_SetTheme(m.LastThemeAttributes)
    end if
    ' used to restore default view UI if user reset style
    m.defaultUIConfig = {
        poster: {
            maxWidth: 357
            maxHeight: 201
            shape: "16x9"
            translation: [0, 0]
        }
        info1: {
            wrap: false
            horizAlign: "right"
        }
        info2: {
            width: 357
            wrap: false
            horizAlign: "right"
        }
    }
    OnStyleChange()
end sub

sub OnFocusedChildChanged()
    if m.buttons <> invalid and m.top.IsInFocusChain() and not m.buttons.HasFocus() then
        m.buttons.SetFocus(true)
    end if
end sub

sub OnStyleChange()
    style = m.top.style

    config = GetUIConfigForStyle(style)
    for each componentName in config
        if m[componentName] <> invalid
            m[componentName].Update(config[componentName])
        end if
    end for
end sub

function GetUIConfigForStyle(style as String) as Object
    uiConfig = m.defaultUIConfig

    if style = "rmp"
        uiConfig = {
            info1: {
                wrap: true
                width: 357
                maxLines: 2
                font: "font:LargeSystemFont"
            }
            info2: {
                wrap: true
                maxLines: 3
                font: "font:SmallSystemFont"
            }
        }
    end if

    return uiConfig
end function

sub OnPosterShapeChange()
    m.poster.shape = m.top.posterShape
    posterX = (m.styledPosterArea.width - m.poster.width) / 2
    posterY = (m.styledPosterArea.height - m.poster.height) / 2
    m.poster.translation = [posterX, posterY]
end sub

sub OnWasShown()
    if m.top.wasShown
        OnContentSet()

        ' Content observer should be set after DetailsView was shown
        ' in other case there can be race condition with setting
        ' content and isContentList fields
        if not m.contentObserverIsSet
            m.top.ObserveField("content", "OnContentSet")
            m.contentObserverIsSet = true
        end if
    end if
end sub

sub OnContentSet()
    if m.top.content <> invalid
        ' Handles if callback triggered by changing field of ContentNode or
        ' replace with new ContentNode by saving reference to m.currentContentNode
        if (m.currentContentNode = invalid or not m.currentContentNode.isSameNode(m.top.content))
            if m.top.isContentList = false
                SetDetailsContent(m.top.content)
            end if
            m.currentContentNode = m.top.content
        end if
    else
        ' Clear previous content
        SetDetailsContent(invalid)
        m.buttons.content = invalid
    end if
end sub

sub OnItemFocusedChanged(event as Object)
    focusedItem = event.GetData()
    if m.top.isContentList
        content = m.top.content.GetChild(focusedItem)
        if content <> invalid
            ' to prevent stale data being displayed while the CH is running
            if m.ratingPoster <> invalid
                m.ratingPoster.uri = ""
            end if

            ' we are setting details to details page even if it' s not loaded, so user can see that something has changed
            ' developer should put some place holders to show user that data is loading
            SetDetailsContent(content)
        end if
    else
        ' ?"this is not list"
        ' TODO add logic here if needed
    end if
end sub

sub OnCurrentItemChanged(event as Object)
    currentItem = event.getData()
    if currentItem <> invalid
        ' set itemLoaded as the content has been fully loaded
        m.top.itemLoaded = true
        SetDetailsContent(currentItem)
    end if
end sub

sub OnJumpToItem()
    content = m.top.content
    if content <> invalid and m.top.jumpToItem >= 0 and content.Getchildcount() > m.top.jumpToItem
        m.top.itemFocused = m.top.jumpToItem
    end if
end sub

sub SetDetailsContent(content as Object)
    if content <> invalid
        m.poster.uri = content.hdposterurl
        contentDurationString = Utils_DurationAsString(content.length)

        if isImageURI(content.Rating) then
            if m.ratingPoster = invalid then
                m.ratingPoster = CreateObject("roSGNode", "Poster")
                m.info1Layout.insertChild(m.ratingPoster, 0)
            end if
            if m.ratingPoster <> invalid then
                m.ratingPoster.Update({
                    id :"ratingPoster"
                    width : "27"
                    height : "27"
                    uri : content.rating
                })
            end if
            info2Text = ConvertToStringAndJoin([Content.categories])
        else
            info2Text = ConvertToStringAndJoin([content.Rating, Content.categories])
        end if

        if m.top.style = "rmp"
            m.info1.text = content.title
            info2Text = ConvertToStringAndJoin([content.ReleaseDate, contentDurationString, content.Rating])
            info2Text = info2Text + chr(13) + chr(10)
            info2Text = info2Text + ConvertToStringAndJoin([content.categories])
        else
            SetOverhangTitle(content.title)
            m.info1.text = ConvertToStringAndJoin([content.ReleaseDate, contentDurationString])
            m.info3.text = content.shortDescriptionLine1
        end if
        m.info2.text = info2Text
        m.descriptionLabel.text = content.description
        m.actorsLabel.text = ConvertToStringAndJoin(content.actors, ", ")
    else ' clear content
        SetOverhangTitle("")
        m.poster.uri = ""
        m.info1.text = ""
        m.info2.text = ""
        m.info3.text = ""
        m.descriptionLabel.text = ""
        m.actorsLabel.text = ""
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    steps = {
        "right": + 1
        "left": - 1
        ' "fastforward"   : +2
        ' "rewind"        : -2
    }
    if press then
        if steps[key] <> invalid
            handled = true
            content = m.top.content
            buttonBar = m.top.getScene().buttonBar
            if content <> invalid and m.top.isContentList
                newIndex = GetNextItemIndex(m.top.itemFocused, content.Getchildcount() - 1, steps[key], m.top.allowWrapContent)
                if m.top.itemFocused <> newIndex then
                    m.top.jumpToItem = newIndex
                end if
            else if buttonBar <> invalid
                if buttonBar.visible = true and buttonBar.alignment = "left" and key = "left"
                    buttonBar.SetFocus(true)
                end if
            end if
        end if
    end if

    return handled
end function

sub SetOverhangTitle(title as String)
    if m.overhang <> invalid
        m.overhang.title = title
    end if
end sub

' #################################################################################

function ConvertToStringAndJoin(dataArray as Object, divider = " | " as String) as String
    result = ""
    if Type(dataArray) = "roArray" and dataArray.Count() > 0
        for each item in dataArray
            if item <> invalid
                strFormat = invalid
                if GetInterface(item, "ifToStr") <> invalid
                    strFormat = item.Tostr()
                else if GetInterface(item, "ifArrayJoin") <> invalid
                    strFormat = item.Join(" | ")
                end if
                if strFormat <> invalid then
                    if strFormat.Len() > 0
                        if result.Len() > 0 then result += divider
                        result += strFormat
                    end if
                end if
            end if
        end for
    end if
    return result
end function

function GetNextItemIndex(currentIndex as Integer, maxIndex as Integer, _step as Integer, allowCarousel = false as Boolean, minIndex = 0 as Integer) as Integer
    result = currentIndex + _step

    if result > maxIndex then
        if allowCarousel then
            result = minIndex
        else
            result = maxIndex
        end if
    else if result < minIndex then
        if allowCarousel then
            result = maxIndex
        else
            result = minIndex
        end if
    end if

    return result
end function

function isImageURI(text as String) as Boolean
    regex = CreateObject("roRegex", "(?:jpg|gif|png)", text)
    return regex.isMatch(text)
end function

sub SGDEX_SetTheme(theme as Object)
    colorTheme = {
        TextColor: {
            buttons: [
                "focusedColor"
                "color"
                "sectionDividerTextColor"
            ]

            info1:            "color"
            info2:            "color"
            info3:            "color"
            actorsLabel:      "color"
            descriptionLabel: "color"
        }
        focusRingColor: {
            buttons: ["focusBitmapBlendColor"]
        }
    }

    SGDEX_setThemeFieldstoNode(m, colorTheme, theme)

    detailsThemeAttributes = {
        ' labels color
        descriptionColor:               { descriptionLabel: "color" }
        actorsColor:                    { actorsLabel: "color" }
        ReleaseDateColor:               { info1: "color" }
        RatingAndCategoriesColor:       { info2: "color" }
        shortDescriptionColor:          { info3: "color" }

        posterBackgroundColor:          { styledPosterArea: "color" }

        ' buttons theme
        buttonsFocusedColor:            { buttons: "focusedColor" }
        buttonsUnFocusedColor:          { buttons: "color" }
        buttonsFocusRingColor:          { buttons: "focusBitmapBlendColor" }
        buttonsSectionDividerTextColor: { buttons: "sectionDividerTextColor" }

        busySpinnerColor: { spinner : { poster: "blendColor"} }
    }

    SGDEX_setThemeFieldstoNode(m, detailsThemeAttributes, theme)
end sub

function SGDEX_GetViewType() as String
    return "detailsView"
end function


sub SGDEX_UpdateViewUI()
    'avoid triggering if view wasn't initialized
    if m.top.viewContentGroup.GetChildCount() > 0
        padding = m.detailsGroup.BoundingRect()["x"]
        buttonBar = m.top.GetScene().buttonBar
        contentGroupY = m.top.viewContentGroup.translation[1]
        isButtonBarVisible = buttonBar.visible
        isButtonBarOverlay = buttonBar.overlay
        isAutoHide = buttonBar.autoHide
        descriptionLabelWidth = 593

        if buttonBar <> invalid and m.detailsGroup <> invalid
            if buttonBar.alignment = "left"
                offset = GetButtonBarWidth()
                if not buttonBar.IsInFocusChain() and (isAutoHide and isButtonBarVisible)
                    m.top.viewContentGroup.translation = [0,contentGroupY]
                else if isButtonBarVisible and not isButtonBarOverlay
                    absoluteButtonBarWidth = offset - GetViewXPadding()
                    buttonBarViewContentPadding = 50
                    m.top.viewContentGroup.translation = [absoluteButtonBarWidth + 30,contentGroupY]

                    distanceToShrinkRightGroup = m.descriptionLabel.sceneBoundingRect()["x"]+ m.descriptionLabel.sceneBoundingRect()["width"] - 1280 + 128
                    ' shrink buttons and right labels only if it should be shrinked less then in 2/3
                    if distanceToShrinkRightGroup < (593 / 3)*2
                        descriptionLabelWidth -= distanceToShrinkRightGroup
                        m.top.viewContentGroup.translation = [m.top.viewContentGroup.translation[0]-distanceToShrinkRightGroup,m.top.viewContentGroup.translation[1]]
                    end if
                end if
            end if

            ' calculate minor change to avoid visual issue after overhang disabled
            buttonsWidthDelta = m.descriptionLabel.width - descriptionLabelWidth
            if buttonsWidthDelta < 0 then buttonsWidthDelta *= -1

            if m.descriptionLabel <> invalid and buttonsWidthDelta > 24
                m.descriptionLabel.width = descriptionLabelWidth
                m.actorsLabel.width = descriptionLabelWidth
                m.buttons.itemSize = [descriptionLabelWidth, 48]
            end if

        end if

        if m.descriptionLabel <> invalid
            if contentGroupY > 174
                m.descriptionLabel.maxLines = 3
            else
                m.descriptionLabel.maxLines = 5
            end if
        end if
    end if
end sub