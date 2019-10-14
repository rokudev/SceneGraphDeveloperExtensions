' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

'This is the main entry point to the channel scene.
'This function will be called by library when channel is ready to be shown.
function ShowDetailsScreen(content as Object, index as Integer)
    m.details = CreateObject("roSGNode", "DetailsView")

    m.details.overhang.showOptions = false

    m.details.content = content
    m.details.jumpToItem = index

    m.details.ObserveField("itemLoaded", "OnDetailsItemLoaded")
    m.details.ObserveField("currentItem", "OnDetailsContentSet")
    m.details.ObserveField("buttonSelected", "OnButtonSelected")

    'this will trigger job to show this screen
    m.top.ComponentController.CallFunc("show", {
        view: m.details
    })

    return m.details
end function

sub OnDetailsContentSet(event as Object)
    ' User should decide is update buttons or not
    content = event.getData()
    if content <> invalid
        streamUrl = content.url
        m.btnsContent = Utils_ContentList2Node([{
            title: "Play"
            id:"play"
        }])

        m.details = event.getRoSGNode()
        m.details.buttons = m.btnsContent
    end if
end sub

sub OnDetailsItemLoaded()
    ClearMediaPlayer() ' Reseting MediaView
    m.audio = CreateMediaPlayer(m.details.content, m.details.itemFocused)
    m.audio.ObserveFieldScoped("wasClosed", "OnMediaWasClosed")
end sub

sub OnButtonSelected(event as Object)
    buttons = event.getroSGNode().buttons
    buttonId = event.getData()
    if m.audio <> invalid and buttons.getChild(buttonId).id = "play"
        m.audio.control = "play"
        ' Show the Audio view
        m.top.ComponentController.callFunc("show", {
            view: m.audio
        })
    end if
end sub

sub OnMediaWasClosed()
    m.details.jumpToItem = m.audio.currentIndex 'moving focus to proper item on details row
    ClearMediaPlayer() ' clear player
    OnDetailsItemLoaded() ' start buffering new one
end sub

sub ClearMediaPlayer()
    if m.audio <> invalid
        m.audio.UnobserveFieldScoped("wasClosed")
        m.audio = invalid
    end if
end sub
