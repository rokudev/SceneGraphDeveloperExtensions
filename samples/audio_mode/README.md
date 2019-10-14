# SGDEX Guide: Media

## Part 1: Creating the media view

Create the file "MediaPlayerLogic.brs" in the components folder and implement function CreateMediaPlayer() for displaying the MediaView. Like with the other views, we need to create the object, set all needed fields and observers and then return created view. Your function should look like the one below

```
function CreateMediaPlayer() as Object
    audio = CreateObject("roSGNode", "MediaView")

    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        HandlerConfigMedia: {
            name: "CHAudio"
        }
    },true)

    audio.ObserveFieldScoped("state", "OnStateChanged")
    audio.isContentList = true
    audio.preloadContent = true
    audio.content = content

    return audio
end function
```

The example of function which accepts arguments is primarily the same. The second one is more flexible and you can use it to create MediaViews in different configurations.

```
function CreateMediaPlayerItem(content as Object, index as Integer, isContentList as Boolean) as Object
    audio = CreateObject("roSGNode", "MediaView")

    audio.ObserveFieldScoped("state", "OnFieldChanged")
    audio.isContentList = isContentList
    audio.content = content
    audio.jumpToItem = index

    return audio
end function
```

Content structure should be the same as for MediaView each piece of content will look something like this:

```
<Component: roSGNode:ContentNode> =
{
    change: <Component: roAssociativeArray>
    focusable: false
    focusedChild: <Component: roInvalid>
    id: ""
    handlerconfigmedia: invalid
    STREAMFORMAT: "mp3"
    TITLE: "Audio 1"
    URL: "http://devtools.web.roku.com/samples/audio/John_Bartmann_-_05_-_Home_At_Last.mp3"
}

```

It's important to set proper ```STREAMFORMAT``` value so MediaView will identify which mode to use, audio or video.

## Part 2: Calling CreateMediaPlayer()

Now we go back to the DetailsViewLogic.brs file.  In the ShowDetailsView() function we need to add the following line after you create the details object,

```
m.details.ObserveField("buttonSelected", "OnButtonSelected")
```

# This paragraph says that you need to check if button id is play but the code is not doing that, fix in readme and in test channel
In your OnButtonSelected function, you need to get the details object, from that get the selected button and choose which action to perform. If the button’s id is "play" we show the MediaView using ComponentController.

```
sub OnButtonSelected(event as Object)
    details = event.GetRoSGNode()
    if m.audio <> invalid
        m.audio.control = "play"
        ' Show the Audio view
        m.top.ComponentController.callFunc("show", {
            view: m.audio
        })
    end if
end sub
```

## Part 3: Using ContentHandler

Content handlers work absolutely the same as for MediaView.

###### Copyright (c) 2019 Roku, Inc. All rights reserved.
