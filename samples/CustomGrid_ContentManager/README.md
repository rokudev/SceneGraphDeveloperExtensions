# SGDEX Guide: Using custom grid and media views with SGDEX ContentManager

## Custom Grid Views

SGDEX provides developers with the possibility to connect their grid-like RSG view’s with SGDEX grid content manager.

In this sample we're using `non-serial, paged loading model` using public API - https://archive.org/advancedsearch.php to show page loading model using non-SGDEX view. Now to bind your grid-like view with SGDEX grid content manger you should do:

1. Create view
2. Implement content handler
3. Show the view with binded content handler

Step by step implementation described below.

Detailed information about implementing Content Handlers can be found in [SGDEX documentation](https://github.com/rokudev/SceneGraphDeveloperExtensions/blob/master/documentation/2-Contenthandlers_Guide.md).


### Creating a custom grid view
To create custom grid view we should add RSG grid component like ZoomRowList, what was done in *CustomZoomRowList.xml*. Then, we need to add proper interfaces, they are:`saveState,wasShown,wasClosed,rowItemFocused,content and contentManagerType`, to component interfaces and alias`rowItemFocused` field to make SGDEX able to paginate content.
```
<?xml version="1.0" encoding="UTF-8"?>
<component name="CustomZoomRowList" extends="Group" >

    <script type="text/brightscript" uri="CustomZoomRowList.brs" />

    <interface>
       <field id="rowItemFocused" type="vector2d" alwaysNotify="true" alias="contentGrid.rowItemFocused"/>
       <field id="content" type="node"/>
       <field id="contentManagerType" type="string" value="grid"/>
       <field id="saveState" type="boolean" alwaysNotify="true" value="false" />
       <field id="wasShown" type="boolean" alwaysNotify="true" value="false" />
       <field id="wasClosed" type="boolean" alwaysNotify="true" value="false" />
    </interface>
```

Then we should add some RSG element as a child to the component with id equal to`"contentGrid"`:

```
    <children>
        <Overhang/>
        <ZoomRowList id="contentGrid" />
    </children>
</component>
```

Next, we should find our element and set attributes to make it visible and draw items as we want, done in *CustomZoomRowList.brs* :
```
    contentGrid = m.top.FindNode("contentGrid")
    contentGrid.Update({
        translation : [130, 100]
        itemComponentName : "SimpleGridItem"
    })
```

### Implementing the ContentHandler
#### Creating placeholders for content items

Next, we should implement`non-serial page loading model` using the content handler. Implement the logic for row item placeholders that will be displayed on view until API calls proceed, done in *CHRoot.brs*:

```
    for rowIndex = 0 to 7
        ' creating placeholders for row items that will be replaced with
        ' actual content items within paginated content handler(CHPaginatedRow)
        placeholders = []
        for i = 1 to 20 ' replace with update/ AppendChildren
            placeholderItem = CreateObject("roSGNode", "ContentNode")
            placeholderItem.hdPosterUrl = "pkg:/images/placeholder.png"

            placeholders.Push(placeholderItem)
        end for

        row = CreateObject("roSGNode", "ContentNode")
        row.title = rowTitles[rowIndex].title
        ' use update for more efficient populating row content node with
        ' placeholder items
        row.Update({
            children: placeholders ' Appending placeholders to row as a children
            HandlerConfigGrid: {
                name: "CHPaginatedRow"
                pageSize: 5 ' size of page that will be requested from API
                ' Passing additional custom params to ContentHandler (should be
                ' declared in Handler's xml)
                query : row.title ' passing title of row to use it as search query for API
            }
        },true)

        rootChildren.Push(row) ' pushing row's to root content node
    end for
    ' populate root content node
    m.top.content.AppendChildren(rootChildren)
```
#### Replacing placeholders with received content items
Placeholders will be replaced with real content after processing API calls implemented in *CHPaginatedRow.brs*:

```
    url.SetUrl(searchUrl)

    ' make an API call
    rawReponse = url.GetToString()

    ' parsing content items from response
    json = ParseJSON(rawReponse)
    if json <> invalid and json.response <> invalid
        response = json.response
        if response.docs <> invalid and response.docs.Count() > 0
            items = []
            for each item in response.docs
                contentItem = CreateObject("roSGNode", "ContentNode")
                contentItem.Update({
                    title: item.title
                    hdposterurl: BuildPosterUrl(item.identifier)
                },true)
                items.push(contentItem)
            end for

            ' replace placeholder items in the row (it's referenced by m.top.content)
            ' starting from itemIndex - this will make view display these items
            m.top.content.ReplaceChildren(items, itemIndex)
            end if
    end if
```

### Initializing the component

Now in Scene we're going to fill out the`show()` function. First, we should create Grid Object and set a few of its attributes, what was made in *MainScene.brs*

```
    customView = CreateObject("roSGNode","CustomZoomRowList")

```

Next, we should set up the Content Handler to fetch your content. To do this we need to create a content node and then tell it how ContentHandler called.

```
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        HandlerConfigGrid: {
            name: "CHRoot"
        }
    },true)
```

Next, we should set that content node we just made to our grid. After that, we will call the`show()` function to show our grid to the View.

```
    customView.content = content

    m.top.ComponentController.callFunc("show", {
        view: customView
    })
```

### Result
After view was shown, loading process will start and first 3 rows will load asynchronously, then if user will navigate to other row - it will be loaded, else if user will navigate to next items in focused row - row pagination will start. Otherwise - lazyloading will gradually load all the grid content.

## Custom Media Views

Starting from v2.6, SGDEX provides developers with the possibility to use the SGDEX ContentManager with a custom media view.

In this sample we're using a custom UI for the MediaView, populate content using SGDEX handlers, and use proxy node for disabling underlying Video node UI and observing its trickplay position in order to update custom trickplay UI.

### Creating a Custom Media View

#### Build the Custom Media View

The process of building and using a custom media view is documented here [SGDEX documentation](../../documentation/6-ContentManager_with_Custom_Views_Guide.md).

In this sample, we've created a component called CustomMedia that extends the RSG Group component. This component has several fields that will be needed by the sample channel.

These fields are required by SGDEX for all custom media views:

- _contentManagerType_ - This field will tell SGDEX what flavor of ContentHandler the custom view uses. For media views, the value is "media".
-  _content_ - Like MediaView, this is how we will set content to the custom view.
- _jumpToItem_ - The sample channel does not use it directly.
- _control_ - Like MediaView, this is used to control media playback.

These fields are optional and are used by the custom view to build its UX:

- _state_ - The sample channel observes this field to know when to display different UX elements of the custom view
- _mode_ - The sample channel needs to set this field when playing audio content. The default mode is video.
- _isContentList_ - The sample channel needs to set this field to disable playlists. 
- _position_ - The sample channel observes this field to know when to update the custom UX 
- _duration_ - The sample channel observes this field to know whether to display a playbar in the custom UX
- _currentItem_ - The sample channel observes this field to know when to update the metadata displayed in the custom UX

#### Add a Proxy Node

In oder to disable the Video node's UI and implement our custom version, we need access to the _enableUI_ and _trickplayPosition_ fields. Since those fields are not exposed through the SGDEX MediaView, we will need to add a proxy node to our custom media view. Proxy nodes are optional and should only be used to access fields that are not exposed through MediaView.

```
<component name="ProxyVideo" extends="Node">
    <interface>
        <field id="enableUI" type="boolean" value="true" />
        <field id="trickplayPosition" type="time" />
    </interface>
</component>
```
The proxy node must be a child of your custom media view named _contentMedia_

```
<component name="CustomMedia" extends="Group">
    <interface> 
        <field id="contentManagerType" type="string" value="media" />
        <field id="content" type="node" />
        <field id="mode" type="string" />
        <field id="jumpToItem" type="integer" value="0" alwaysNotify="true" />
        <field id="control" type="string" value="none" alwaysNotify="true" />
        <field id="isContentList" type="bool" alwaysNotify="true" />
        <field id="state" type="string" value="none" alwaysNotify="true" />
        <field id="position" type="integer" value="0" alwaysNotify="true" />
        <field id="duration" type="integer" value="0" alwaysNotify="true" />
        <field id="currentItem" type="node" alwaysNotify="true" />
    </interface>
    <script type="text/brightscript" uri="CustomMediaView.brs" />
    <children>
        <ProxyVideo id="contentMedia" />

```
Then in the Init() function of own `CustomMediaView.brs` we can be able to find _contentMedia_ via `FindNode()`  to set attributes and callbacks. In the current sample, we're using specified _enableUI_ and _trickplayPosition_ fields from ProxyVideo component.

```
sub Init()
    ' Cache custom UI bits to m to work with them in the scope of observers
    m.customUI = m.top.FindNode("customUI")
    proxyVideo = m.top.FindNode("contentMedia")

    m.spinner = m.top.FindNode("spinner")
    m.spinnerLayout = m.top.FindNode("spinnerLayout")

    ' Create a timer to hide CustomUI
    m.HUDtimer = m.top.CreateChild("Timer")
    m.HUDtimer.repeat = false
    m.HUDtimer.duration = 2
    m.HUDtimer.ObserveFieldScoped("fire", "OnHUDTimerFireChanged")

    ' Disable default Video node UI using proxy node, 
    ' as enableUI field is not availablle in the top fields of the view
    proxyVideo.enableUI = false

    ' Set Callbacks for m.top fields from the view
    m.top.ObserveFieldScoped("state", "OnStateChanged")
    m.top.ObserveFieldScoped("duration", "OnDurationChanged")
    m.top.ObserveFieldScoped("position", "OnPositionChanged")
    m.top.ObserveFieldScoped("currentItem", "OnCurrentItemChanged")
    m.top.ObserveFieldScoped("mode", "OnModeChanged")

    ' Set observer for trickplayPosition field of the proxy node,
    ' as theare is no related top view field 
    proxyVideo.ObserveFieldScoped("trickplayPosition", "OnTrickplayPositionChanged")
end sub
```

Then we've added RSG elements as a childs to the own CustomMedia component to render custom UI. In the current sample, we've created a CustomUI component for video and audio mode and handling a process of visibility it, depends on the _state_ field from MediaView:

- The CustomMediaView.xml file:
```
        <CustomUI
            id="videoUI"
            visible="false"/>
        
        <LayoutGroup
            id="spinnerLayout"
            translation="[640,360]"
            horizAlignment="center"
            vertAlignment="center"
            visible="false">
            <BusySpinner
                id="spinner"
                uri="pkg:/images/spinner.png"/>
        </LayoutGroup>
    </children>
</component> <!-- End of CustomMediaView.xml file -->
```

The process of visibility CustomUI for video mode we're processing in the `OnStateChanged()` function and show it depending on the _state_ field, also in that function to avoid an empty black screen we're using a spinner and show it when the video is in a loading state

- The `OnStateChanged()` function:
```
sub OnStateChanged(event as Object)
    state = event.getData()
    if state = "playing" 
        ' Hide a spinner and custom UI only for video mode
        ShowSpinner(false)
        if m.top.mode = "video"
            m.customUI.visible = false
            m.HUDtimer.control = "stop"
        end if
    else if state = "paused" 
        ' Show a custom UI only when the mode is a video
        if m.top.mode = "video"
            m.customUI.visible = true
        end if
    else if state = "finished" or state="buffering" or state="none" 
        ' Show the spinner to avoid empty black screen
        ShowSpinner(true)
    end if
end sub
```

For the audio mode we're always showing this CustomUI regardless of the _state_ field
- The `OnModeChanged()` function:
```
sub OnModeChanged(event as Object)
    mode = event.getData()
    m.customUI.mode = mode
    if mode = "audio" ' Always show a custom UI for audio mode
        m.customUI.visible = true
    end if
end sub
```

Also, we've overridden the `onKeyEvent()` function to handle keys that we needed for video mode we're handling  D-pad up/down key presses to show information about the video to user for 2 seconds, and for audio mode we're handling D-pad left/right for seek.
- The `onKeyEvent()` function:
```
' Overridden onKeyEvent() function to handle a key pressing
function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press and m.top.mode = "video" 
        ' Show or hide a custom UI depend on the key pressed
        if key = "down" and not m.customUI.visible 
           ' Show a custom UI for 2 seconds
            m.customUI.visible = true
            m.HUDtimer.control = "start"
        else if key = "up" and m.customUI.visible 
           ' Hide a custom UI and stop a timer when user press a up key
            m.customUI.visible = false
            m.HUDtimer.control = "stop"
        end if
    else if m.top.mode = "audio"
        if key = "left"
            m.top.seek = m.top.position - 5
        else if key = "right"
            m.top.seek = m.top.position + 5
        end if
    end if
    return handled
end function
```

#### Implementing the ContentHandler

In the current sample, we're using a ContentHandler for a single item model to populate a data and url for playback, which was done in `CHVideo.brs`, `CHAudio.brs`.

```
sub GetContent()
    m.top.content.Update({
        title: m.top.item.title
        description: m.top.item.description
        hdposterurl: m.top.item.hdposterurl
        url: "http://websrvr90va.audiovideoweb.com/va90web25003/companions/Foundations%20of%20Rock/13.06.mp3"
    },true)
end sub
```

#### Initialization of the own custom component

In order to use your own component, you need do all of the following steps:
- Create a component with the name which you specified in your own component .xml file
```
    media = CreateObject("roSGNode", "CustomMedia")
```
- Create an HandlerConfig to use SGDEX MediaView handlers to fetch your content. To do this we need to create a content node and then tell it how ContentHandler called.
```
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        HandlerConfigMedia: {
            name: "CHVideo"
        }
    },true)
    media.content = content
```
- Populate control field and other fields that you specified in your component 
```
    media.isContentList = false
    media.control = "play"

    m.top.ComponentController.callFunc("show", {
        view: media
    })
```

###### Copyright (c) 2021 Roku, Inc. All rights reserved.
