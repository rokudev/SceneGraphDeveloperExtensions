# SGDEX Guide: Audio Using MediaView

## Part 1: Creating the MediaView

Create the file "MediaPlayerLogic.brs" in the components folder and implement function CreateMediaPlayer() for displaying the MediaView. Like with the other views, we need to create the object, set all needed fields and observers and then return created view. Your function should look like the one below

```
function CreateMediaPlayer() as Object
    audio = CreateObject("roSGNode", "MediaView")

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

Content structure should be the same as for video content each piece of content will look something like this:

```
<Component: roSGNode:ContentNode> =
{
    title: "Item 1.1"
    hdPosterUrl: "http://devtools.web.roku.com/samples/audio/nps_poster.jpg"
    description: "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum"" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, ""Lorem ipsum dolor sit amet.."", comes from a line in section 1.10.32."
    releaseDate: "25.12.2018"
    rating: "7.5"
    artists: "Barack Gates, Bill Obama" ' artist metadata will be displayed on MediaView
    album: "Achtung"
    StationTitle: "Station Title" ' this field can be used to display an album title on MediaView
    url: "http://www.sdktestinglab.com/Tutorial/sounds/audionode.mp3"
    streamFormat : "mp3" ' if the mode field  is not set on MediaView, streamFormat will be used to choose the mode
    length: 3 ' this field should be set to see progress bar on MediaView
}

```

It's important to set proper ```STREAMFORMAT``` value so MediaView will identify which mode to use, audio or video.

## Part 2: Calling CreateMediaPlayer()

Now we go back to the DetailsViewLogic.brs file.  In the ShowDetailsView() function we need to add the following line after you create the details object,

```
m.details.ObserveField("buttonSelected", "OnButtonSelected")
```

In your OnButtonSelected function, you need to get the details object, from that get the selected button and choose which action to perform. If the button’s id is "play" we show the MediaView using ComponentController.

```
sub OnButtonSelected(event as Object)
    buttons = event.getRoSGNode().buttons
    buttonId = event.getData()
    if m.audio <> invalid and buttons.getChild(buttonId).id = "play"
        m.audio.control = "play"
        ' Show the Audio view
        m.top.ComponentController.callFunc("show", {
            view: m.audio
        })
    end if
end sub
```

###### Copyright (c) 2020 Roku, Inc. All rights reserved.
