' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

' function will create and show DetailsView
function ShowDetailsView(content as Object, index as Integer) as Object
    details = CreateObject("roSGNode", "DetailsView")
    details.SetFields({
        content: content
        jumpToItem: index
    })
    details.ObserveFieldScoped("currentItem", "OnDetailsContentSet")
    details.ObserveFieldScoped("buttonSelected", "OnButtonSelected")

    'this will trigger job to show this View
    m.top.ComponentController.CallFunc("show", {
        view: details
    })
    m.details = details
    return details
end function

' function will update buttons once item for details is loaded
sub OnDetailsContentSet(event as Object)
    ' user should decide is update buttons or not
    content = event.GetData()
    if content <> invalid
        streamUrl = content.url
        details = event.GetRoSGNode()
        if streamUrl <> invalid and streamUrl <> ""
            RefreshButtons(details)
        else
            btnsContent = CreateObject("roSGNode", "ContentNode")
            btnsContent.Update({ children: [{ title: "Loading" }] })
            details.buttons = btnsContent
        end if
    end if
end sub

' callback for on button selected event
sub OnButtonSelected(event as Object)
    details = event.GetRoSGNode()
    button = details.buttons.GetChild(event.GetData())
    item = details.content.GetChild(details.itemFocused)
    if button.id = "play" then
        item.bookmarkPosition = 0
    end if

    video = OpenVideoPlayer(details.content, details.itemFocused, true)
    video.ObserveFieldScoped("wasClosed", "OnVideoWasClosed")
end sub

' callback for media view close event
sub OnVideoWasClosed()
    RefreshButtons(m.details)
end sub

' function for refreshing buttons on details View
' it will check whether item has bookmark and show correct buttons
sub RefreshButtons(details as Object)
    item = details.content.GetChild(details.itemFocused)
    ' play button is always available
    buttons = [{ title: "Play", id: "play" }]
    ' continue button available only when this item has bookmark
    if item.bookmarkPosition > 0 then buttons.Push({ title: "Continue", id: "continue" })
    btnsContent = CreateObject("roSGNode", "ContentNode")
    btnsContent.Update({ children: buttons })
    ' set buttons
    details.buttons = btnsContent
end sub
