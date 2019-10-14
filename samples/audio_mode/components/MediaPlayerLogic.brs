' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

'This is logic for Audio playback
function CreateMediaPlayer(content as Object, index as Integer) as Object
    audio = CreateObject("roSGNode", "MediaView")

    audio.ObserveFieldScoped("state", "OnFieldChanged")
    audio.isContentList = true
    audio.preloadContent = true ' Set preload content on created view
    audio.content = content
    audio.jumpToItem = index ' Set proper item to play

    return audio
end function

function CreateMediaPlayerItem(content as Object, index as Integer, isContentList as Boolean) as Object
    audio = CreateObject("roSGNode", "MediaView")

    audio.ObserveFieldScoped("state", "OnFieldChanged")
    audio.isContentList = isContentList
    audio.content = content
    audio.jumpToItem = index

    return audio
end function

sub OnFieldChanged(event as Object)
    currentItem = event.GetRoSGNode().currentItem
    if currentItem <> invalid then ? ">>>>> "; currentItem.title + ":"
    ?">>>>> "; event.GetField(); " == "; event.GetData()
end sub