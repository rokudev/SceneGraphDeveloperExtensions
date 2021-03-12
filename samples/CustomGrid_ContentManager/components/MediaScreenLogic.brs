' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

'This is logic for video playback
function OpenMediaScreen(mode as String, itemSelected as Object) as Object
    media = CreateObject("roSGNode", "CustomMedia")
    media.mode = mode
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        HandlerConfigMedia: {
            name: "CH" + mode
            fields: {
                item: itemSelected.clone(true)
            }
        }
    },true)
    media.content = content
    media.isContentList = false
    media.control = "play"

    media.ObserveField("state", "OnMediaState")
    m.top.ComponentController.callFunc("show", {
        view: media
    })
    return media
end function

sub OnMediaState(event)
    n = event.GetRoSGNode()
    s = n.state
    ? "Media state changed to " + s
end sub