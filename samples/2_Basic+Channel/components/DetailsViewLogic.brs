' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

function ShowDetailsView(content as Object, index as Integer, isContentList = true as Boolean) as Object
    details = CreateObject("roSGNode", "DetailsView")
    details.ObserveField("content", "OnDetailsContentSet")
    details.ObserveField("buttonSelected", "OnButtonSelected")
    details.SetFields({
        content: content
        jumpToItem: index
        isContentList: isContentList
    })

    'this will trigger job to show this View
    m.top.ComponentController.CallFunc("show", {
        view: details
    })

    return details
end function

sub OnDetailsContentSet(event as Object)
    btnsContent = CreateObject("roSGNode", "ContentNode")
    if event.GetData().TITLE = "series"
        btnsContent.Update({ children: [{ title: "Episodes", id: "episodes" }] })
    else
        btnsContent.Update({ children: [{ title: "Play", id: "play" }] })
    end if

    details = event.GetRoSGNode()
    details.buttons = btnsContent
end sub

sub OnButtonSelected(event as Object)
    details = event.GetRoSGNode()
    selectedButton = details.buttons.GetChild(event.GetData())

    if selectedButton.id = "play"
        OpenVideoPlayer(details.content, details.itemFocused, details.isContentList)
    else if selectedButton.id = "episodes"
        ShowEpisodePickerView(details.currentItem.seasons)
    end if
end sub
