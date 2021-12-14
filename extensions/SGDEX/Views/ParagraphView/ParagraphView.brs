' Copyright (c) 2019 Roku, Inc. All rights reserved.

sub init()
    InitContentGetterValues()
    m.debug = false
    m.Handler_ConfigField = "HandlerConfigParagraph"
    m.layoutX = GetViewXPadding()
    m.visibleWidth = 1280 - (m.layoutX * 2)

    ' here will be stored all labels
    ' needed for theming
    m.paragraphs = []
    m.headers = []
    m.linkingCodes = []

    m.visibleLabels = m.top.FindNode("visibleLabels")
    m.buttons = m.top.FindNode("buttons")
    m.spinnerGroup = m.top.FindNode("spinnerGroup")
    m.spinner = m.top.FindNode("spinner")
    m.spinner.uri = "pkg:/components/SGDEX/Images/loader.png"

    m.top.ObserveFieldScoped("content", "OnContentChanged")
    m.top.ObserveFieldScoped("focusedChild", "OnFocusedChildChanged")

    SetupRenderingRectangles()

    ' set specific to this view global theme attributes
    if m.LastThemeAttributes <> invalid then
        SGDEX_SetTheme(m.LastThemeAttributes)
    end if

    m.top.viewContentGroup.AppendChildren([
        m.visibleLabels,
        m.buttons
    ])
end sub

sub OnContentChanged()
    content = m.top.content
    if content <> invalid
        if content[m.Handler_ConfigField] <> invalid
            ShowBusySpinner()
            config = content[m.Handler_ConfigField]
            callback = {
                config: config
                needToRetry: true

                onReceive: sub(data)
                    if data <> invalid and data.GetChildCount() > 0
                        HideBusySpinner()
                        PlaceContentOnScreen(data)
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
        else if content.GetChildCount() > 0
            PlaceContentOnScreen(content)
        end if
    else
        ' clear the view
        ClearView()
    end if
end sub

sub OnFocusedChildChanged()
    if m.top.IsInFocusChain() and m.buttons.content <> invalid
        m.buttons.SetFocus(true)
    end if
end sub

sub OnButtonsChanged()
    m.buttons.content = m.top.buttons
    if m.top.buttons <> invalid
        SetupRenderingRectangles()
        OnFocusedChildChanged()
    end if
end sub

sub OnJumpToButton()
    if m.buttons.content <> invalid and m.top.jumpToButton > -1
        m.buttons.jumpToItem = m.top.jumpToButton
    end if
end sub

sub SetupRenderingRectangles()
    buttonsCount = 0
    if m.buttons.content <> invalid
        buttonsCount = m.buttons.content.GetChildCount()
        ' maximum 3 buttons are visible
        if buttonsCount > 2 then buttonsCount = m.buttons.numRows
    end if

    bottomPading = 56
    buttonsWidth = GetButtonsWidth()
    m.buttons.itemSize = [buttonsWidth, 38]
    buttonsSize = buttonsCount * m.buttons.itemSize[1] + (buttonsCount - 1) * m.buttons.itemSpacing[1]
    buttonsY = 720 - buttonsSize - bottomPading - m.top.viewContentGroup.translation[1]
    
    buttonBar = m.top.getScene().buttonBar
    alignment = buttonBar.alignment

    if (buttonBar.visible and buttonBar.overlay = false) and alignment = "left"
        buttonsX = m.visibleWidth - buttonsWidth
    else
        ' -20 for extra focus ring padding
        buttonsX = 1280 - buttonsWidth - m.layoutX - 20
    end if

    m.buttons.translation = [buttonsX, buttonsY]
    if buttonsCount > 1
        m.buttons.clippingRect = [-50, -50, buttonsWidth + 100, buttonsSize + 45]
    end if
    m.visibleLabels.translation = [m.layoutX, 0]
    m.visibleLabels.clippingRect = [0, 0, m.visibleWidth, buttonsY - 20]
end sub

sub PlaceContentOnScreen(content as Object)
    if content <> invalid
        ClearParagraphs()
        for each child in content.GetChildren(-1, 0)
            paragraphTypeToFunc = {
                invalid: AddParagraph ' if paragraphType not set assume that this is paragraph
                paragraph: AddParagraph
                header: AddHeader
                linkingCode: AddLinkingCode
                image: AddImage
            }

            paragraphTypeStr = Box(child.paragraphType).ToStr()
            handlerFunc = paragraphTypeToFunc[paragraphTypeStr]
            ' if paragraphType is not correct assume that this is paragraph
            if handlerFunc = invalid then handlerFunc = AddParagraph
            handlerFunc(child)
        end for
    end if
end sub

sub AddParagraph(node as Object)
    if node.text <> invalid and node.text.Len() > 0
        label = CreateLabelNode(node.text)
        label.color = GetLabelColor("paragraphColor")
        m.paragraphs.Push(label)
        m.visibleLabels.AppendChild(label)
        AppendSpacings("paragraph")
    end if
end sub

sub AddHeader(node as Object)
    if node.text <> invalid and node.text.Len() > 0
        label = CreateLabelNode(node.text, "font:LargeBoldSystemFont")
        label.color = GetLabelColor("headerColor")
        m.headers.Push(label)
        m.visibleLabels.AppendChild(label)
        AppendSpacings("header")
    end if
end sub

sub AddLinkingCode(node as Object)
    if node.text <> invalid and node.text.Len() > 0
        label = CreateLabelNode(node.text, "font:LargeBoldSystemFont", "center")
        label.wrap = false
        label.color = GetLabelColor("linkingCodeColor")
        m.linkingCodes.Push(label)
        m.visibleLabels.AppendChild(label)
        AppendSpacings("linkingCode")
    end if
end sub

sub AddImage(node as Object)
    if node.HDPosterUrl <> invalid and node.HDPosterUrl.Len() > 0
        layout = CreateObject("roSGNode", "LayoutGroup")
        layout.horizAlignment = "center"
        layout.translation = [m.visibleWidth / 2, 0]
        poster = layout.CreateChild("Poster")
        poster.loadDisplayMode = "scaleToFit"
        poster.uri = node.HDPosterUrl
        if node.TargetRect <> invalid
            if node.TargetRect.w <> invalid
                poster.width = node.TargetRect.w
                poster.loadWidth = node.TargetRect.w
            end if
            if node.TargetRect.h <> invalid
                poster.height = node.TargetRect.h
                poster.loadHeight = node.TargetRect.h
            end if
        end if
        m.visibleLabels.AppendChild(layout)
        AppendSpacings("image")
    end if
end sub

sub AppendSpacings(typeStr as String)
    itemSpacings = []
    itemSpacings.Append(m.visibleLabels.itemSpacings)
    labelSpacings = GetLabelSpacings(typeStr)
    prevSpacing = labelSpacings[0]
    if prevSpacing <> invalid and itemSpacings.Count() > 0 then itemSpacings.Push(itemSpacings.Pop() + prevSpacing)
    spacing = labelSpacings[1]
    if spacing <> invalid then itemSpacings.Push(spacing)
    m.visibleLabels.itemSpacings = itemSpacings
end sub

function GetLabelSpacings(typeStr as String) as Object
    defulatSpacings = [10, 10]
    typeToSpacings = {
        "paragraph": [10, 10]
        "header": [15, 20]
        "linkingCode": [40, 50]
        "image": [10, 10]
    }

    spacings = typeToSpacings[typeStr]
    if spacings = invalid then spacings = defulatSpacings

    return spacings
end function

function CreateLabelNode(text as String, font = "font:MediumSystemFont" as String, horizAlign = "left" as String) as Object
    label = CreateObject("roSGNode", "Label")
    label.horizAlign = horizAlign
    label.font = font
    label.wrap = true
    label.width = m.visibleWidth
    label.text = text
    return label
end function

sub ClearParagraphs()
    m.paragraphs = []
    m.headers = []
    m.linkingCodes = []
    m.visibleLabels.RemoveChildrenIndex(m.visibleLabels.GetChildCount(), 0)
end sub

sub ClearView()
    m.paragraphs = []
    m.headers = []
    m.linkingCodes = []
    m.top.buttons = invalid
    m.visibleLabels.RemoveChildrenIndex(m.visibleLabels.GetChildCount(), 0)
end sub

sub ShowBusySpinner()
    m.spinner.visible = true
    m.spinner.control = "start"
    m.visibleLabels.visible = false
    m.buttons.visible = false
end sub

sub HideBusySpinner()
    m.spinner.visible = false
    m.spinner.control = "stop"
    m.visibleLabels.visible = true
    m.buttons.visible = true
end sub

function GetButtonsWidth() as Integer
    return m.visibleWidth - 200
end function

sub SGDEX_SetTheme(theme as Object)
    colorAttributes = {
        TextColor: {
            buttons: [
                "focusedColor"
                "color"
            ]
        }
    }
    SGDEX_setThemeFieldstoNode(m, colorAttributes, theme)

    themeAttributes = {
        ' buttons theme
        buttonsFocusedColor:            { buttons: "focusedColor" }
        buttonsUnFocusedColor:          { buttons: "color" }
        buttonsFocusRingColor:          { buttons: "focusBitmapBlendColor" }

        busySpinnerColor: { spinner: { poster: "blendColor" } }
    }
    SGDEX_setThemeFieldstoNode(m, themeAttributes, theme)

    SetThemeForAllLabels()
end sub

sub SetThemeForAllLabels()
    typeToAttribute = {
        paragraphs: "paragraphColor"
        headers: "headerColor"
        linkingCodes: "linkingCodeColor"
    }
    for each typeStr in typeToAttribute
        attribute = typeToAttribute[typeStr]
        for each label in m[typeStr]
            label.color = GetLabelColor(attribute)
        end for
    end for
end sub

function GetLabelColor(themeAttribute as String)
    color = "0xddddddff" ' default label color

    if m.LastThemeAttributes <> invalid
        if m.LastThemeAttributes[themeAttribute] <> invalid
            color = m.LastThemeAttributes[themeAttribute]
        else if m.LastThemeAttributes["TextColor"] <> invalid
            color = m.LastThemeAttributes["TextColor"]
        end if
    end if

    return color
end function

function SGDEX_GetViewType() as String
    return "paragraphView"
end function


sub SGDEX_UpdateViewUI()
    buttonBar = m.top.getScene().buttonBar

    if m.buttons <> invalid
        if buttonBar.visible = true
            if buttonBar.overlay = false
                if buttonBar.alignment = "top"
                    m.layoutX = GetViewXPadding()
                    m.visibleWidth = 1280 - (m.layoutX * 2)
                    m.buttons.numRows = 2
                else if buttonBar.alignment = "left"
                    m.visibleWidth = ( 1280 - GetButtonBarWidth() - GetViewXPadding() )
                    m.layoutX = 0
                end if
            else
                m.layoutX = GetViewXPadding()
                m.visibleWidth = 1280 - (m.layoutX * 2)
                m.buttons.numRows = 3
            end if
        else
            if buttonBar.alignment = "left"
                m.layoutX = GetViewXPadding()
                m.visibleWidth = 1280 - (m.layoutX * 2)
            end if
            m.buttons.numRows = 3
        end if
        
        'need to recreate content for update label width
        if m.top.content <> invalid and m.top.content.GetChildCount() > 0
            PlaceContentOnScreen(m.top.content)
        end if
        SetupRenderingRectangles()
    end if
end sub
