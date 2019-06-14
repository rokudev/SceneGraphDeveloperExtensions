' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

function ShowDetailsView(content as Object, index as Integer) as Object
    details = CreateObject("roSGNode", "DetailsView")
    details.SetFields({
        content: content
        jumpToItem: index
    })
    details.ObserveField("currentItem","OnDetailsContentSet")
    details.ObserveField("buttonSelected", "OnButtonSelected")
    m.top.ComponentController.CallFunc("show", {
        view: details
    })
    return details
end function

sub OnDetailsContentSet(event as Object)
    content = event.GetData()
    if (content <> invalid)
        btnsContent = CreateObject("roSGNode", "ContentNode")
        streamUrl = content.url
        if (streamUrl <> invalid and streamUrl <> "")
            btnsContent.Update({ children: [{ title: "Play" }] })
        else
            btnsContent.Update({ children: [{ title: "Loading..." }] })
        end if
        details = event.GetRoSGNode()
        details.buttons = btnsContent
    end if
end sub

sub OnButtonSelected(event as Object)
    details = event.GetRoSGNode()
    OpenVideoView(details.content, details.itemFocused)
end sub
