' Copyright (c) 2019 Roku, Inc. All rights reserved.

sub init()
    m.poster = m.top.findNode("poster")
    m.buttons = m.top.findNode("buttons")
    m.nowPlayingUI = m.top.findNode("nowPlayingUI")


    'removing extra overhang
    overhang = m.top.FindNode("overhang")
    m.top.RemoveChild(overhang)

    m.playBar = m.top.findNode("playBar")

    m.info = m.top.findNode("info")
    m.albumInfo = m.top.findNode("albumInfo")
    m.titleInfo = m.top.findNode("titleInfo")
    m.artistInfo = m.top.findNode("artistInfo")
    m.releaseInfo = m.top.findNode("releaseInfo")

    m.top.ObserveFieldScoped("playBarVisible", "OnPlayBarVisibleChanged")
    m.top.ObserveFieldScoped("buttonContent", "OnButtonContentChanged")
    m.top.ObserveFieldScoped("content", "OnContentChanged")
end sub

sub OnButtonContentChanged(event as Object)
    contentCopy = event.getData()
    newContent = CreateObject("roSGNode", "ContentNode")
    for each buttonContent in contentCopy.GetChildren(-1, 0)
        rowContent = newContent.CreateChild("ContentNode")
        rowContent.AppendChild(buttonContent)
    end for
    m.buttons.content = newContent
    if m.top.jumpToItem > 0 then m.buttons.jumpToItem = m.top.jumpToItem
end sub

sub OnContentChanged(event as Object)
    content = event.GetData()
    if content <> invalid
        if content.hdPosterUrl <> invalid and content.hdPosterUrl.Len() > 0
            m.poster.uri = content.hdPosterUrl
        else
            m.poster.uri = ""
        end if

        if content.album <> invalid and content.album.Len() > 0
            m.albumInfo.Update({
                text : content.album
            })
        else if content.stationTitle <> invalid and content.stationTitle.Len() > 0
            m.albumInfo.Update({
                text : content.stationTitle
            })
        else
            m.albumInfo.Update({
                text: ""
            })
        end if

        if content.title <> invalid and content.title.Len() > 0
            m.titleInfo.Update({
                text : content.title
            })
        else
            m.titleInfo.Update({
                text: ""
            })
        end if
        if content.artist <> invalid and content.artist <> ""
            m.artistInfo.Update({
                text : "by " + content.artist
            })
        else if content.artists[0] <> invalid and content.artists[0].Len() > 0
            m.artistInfo.Update({
                text : "by " + content.artists[0]
            })
        else
            m.artistInfo.Update({
                text : ""
            })
        end if

        if content.releaseDate <> invalid and content.releaseDate.Len() > 0
            m.releaseInfo.Update({
                text : content.releaseDate
            })
        else
            m.releaseInfo.Update({
                text : ""
            })
        end if

        if (content.length <> invalid and content.length > 0)
            m.playBar.duration = content.length
        else
            m.playBar.visible = false
        end if
        OnPlayBarVisibleChanged()
    end if
end sub

sub OnPlayBarVisibleChanged()
    visible = m.top.playBarVisible
    content = m.top.content
    if content <> invalid and (content.length <> invalid and content.length > 0)
        m.playBar.visible = visible
    end if
end sub

' ************* Theme functions *************

sub SGDEX_SetTheme(theme as Object)
    colorTheme = {
        TextColor: {
            albumInfo:    "color",
            titleInfo:    "color",
            artistInfo:   "color",
            releaseInfo:  "color",
        }
    }
    SGDEX_setThemeFieldstoNode(m,colorTheme, theme)
    themeAttributes = {
        ' Labels customization
        albumColor:                            { albumInfo:    "color" }
        titleColor:                            { titleInfo:    "color" }
        artistColor:                           { artistInfo:   "color" }
        releaseDateColor:                      { releaseInfo:  "color" }

        ' Retrieving Bar customization
        progressBarColor:                           { playBar: "filledBarBlendColor" }
        retrievingBarEmptyBarBlendColor:            { playBar: "emptyBarBlendColor" }
        retrievingBarFilledBarBlendColor:           { playBar: "filledBarBlendColor" }
        bufferingBarEmptyBarBlendColor:             { playBar: "emptyBarBlendColor" }
        bufferingBarFilledBarBlendColor:            { playBar: "filledBarBlendColor" }
    }
    SGDEX_setThemeFieldstoNode(m, themeAttributes, theme)
end sub

function SGDEX_GetViewType() as String
    return "NowPlayingView"
end function
