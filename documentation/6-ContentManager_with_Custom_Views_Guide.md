# Using ContentManager with Custom Components

## Grid Views

Starting with SGDEX v2.3 you can leverage the ContentManager used by the SGDEX 
GridView to populate your own custom grid based views. You can use all the same 
data loading models supported by GridView to populate your custom grid view in the
most efficient way possible.

### Requirements

In order to use the Grid ContentManager, you must do all of the following in your custom view:

- Extend from an RSG component. We recommend using the Group component
- Include the following fields: `content`, `rowItemFocused`, `wasShown`, `wasClosed`, `saveState`, `contentManagerType`
- Include a grid type child component. We recommend RowList or ZoomRowList
- The ID of the grid component *must* be "contentGrid"

### Building the View

Your custom view must include the following fields. These are used by the ContentManager
to optimize the performance of the data loading logic and give the user the most
responsive experience possible.

* **content** (ContentNode)
    * Default value: invalid  
    * The value of this field is used by the ContentManager to populate your main grid 
      component, the one with ID "contentGrid". If this ContentNode includes a *handlerConfigGrid* 
      field, the associated ContentHandler will be used to update the content and drive the
      ContentManager, just like GridView.
* **rowItemFocused** (vector2d)
    * Default value: [0,0]
    * This field should be an alias to the *rowItemFocused* field of your main 
      grid component, the one with ID "contentGrid".
* **contentManagerType** (string)
    * Default value: "grid"
    * This field tells the ContentManager which mode to operate in for this view. 
      In SGDEX v2.3, "grid" is the only supported value.
* **wasShown** (boolean)
    * Default value: false
    * This field must be declared as alwaysNotify=true
    * This field is used by the ContentManager. There is no need for you to interact with it directly
* **wasClosed** (boolean)
    * Default value: false
    * This field must be declared as alwaysNotify=true
    * This field is used by the ContentManager. There is no need for you to interact with it directly
* **saveState** (boolean)
    * Default value: false
    * This field must be declared as alwaysNotify=true
    * This field is used by the ContentManager. There is no need for you to interact with it directly

#### Example

```
<component name="MyCustomView" extends="Group">
    <interface>
        <field id="contentManagerType" type="string" value="grid" />
        <field id="rowItemFocused" type="vector2d" alwaysNotify="true" alias="contentGrid.rowItemFocused" />
        <field id="content" type="node" />
        <field id="wasShown" type="boolean" alwaysNotify="true" value="false" />
        <field id="wasClosed" type="boolean" alwaysNotify="true" value="false" />
        <field id="saveState" type="boolean" alwaysNotify="true" value="false" />
    </interface>

    <children>
        <ZoomRowList id="contentGrid" />
    </children>
</component>
```

### Usage 

Once you've built your custom view, using it with SGDEX is exactly the same as using any other view in SGDEX.

#### Example

```
customView = CreateObject("roSGNode", "MyCustomView")
content = CreateObject("roSGNode", "ContentNode")
content.Update({
    HandlerConfigGrid: { name: "CHRoot" }
}, true)

customView.content = content

m.top.ComponentController.callFunc("show", { view: customView })
```

A sample channel using ContentManager with a custom view can be found [here](/samples/CustomGrid_ContentManager)  

## TimeGrid Views

Starting with SGDEX v2.4 you can leverage the ContentManager used by the SGDEX 
TimeGridView to populate your own custom TimeGird based views. You can use all the same 
data loading models supported by TimeGridView to populate your custom view in the
most efficient way possible.

### Requirements

In order to use the TimeGrid ContentManager, you must do all of the following in your custom view:

- Extend from an RSG component. We recommend using the Group component
- Include the following fields: `content`, `wasShown`, `wasClosed`, `contentManagerType`
- Include a TimeGrid child component
- The ID of the grid component *must* be "contentTimeGrid"

### Building the View

Your custom view must include the following fields. These are used by the ContentManager
to optimize the performance of the data loading logic and give the user the most
responsive experience possible.

* **content** (ContentNode)
    * Default value: invalid  
    * The value of this field is used by the ContentManager to populate your TimeGrid 
      component, the one with ID "contentTimeGrid". If this ContentNode includes a *handlerConfigTimeGrid* 
      field, the associated ContentHandler will be used to update the content and drive the
      ContentManager, just like TimeGridView.
* **contentManagerType** (string)
    * Default value: "grid"
    * For TimeGrid views, you must set this field to "timegrid"
    * This field tells the ContentManager which mode to operate in for this view. 
* **wasShown** (boolean)
    * Default value: false
    * This field is used by the ContentManager. There is no need for you to interact with it directly
* **wasClosed** (boolean)
    * Default value: false
    * This field is used by the ContentManager. There is no need for you to interact with it directly

#### Example

```
<component name="MyTimeGrid" extends="Group">
    <interface>
        <field id="contentManagerType" type="string" value="timegrid" />
        <field id="content" type="node" />
        <field id="wasShown" type="node" alwaysNotify="true" />
        <field id="wasClosed" type="boolean" alwaysNotify="true" />
    </interface>
    <children>
        <TimeGrid 
            id="contentTimeGrid"
            translation="[0, 400]"
            programTitleFocusedColor="#5A189A"
            programTitleColor="#5A189A"
        />
    </children>
</component>
```

### Usage

Once you've built your custom view, using it with SGDEX is exactly the same as using any other view in SGDEX.

#### Example

```
sub Show(args as Object)
    customView = CreateObject("roSGNode", "MyTimeGrid")
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        HandlerConfigTimeGrid: { name: "CHRoot" }
    }, true)
    customView.content = content
    m.top.ComponentController.callFunc("show", {
        view: customView
    })
end sub
```

For more information on ContentManager see [this document](https://github.com/rokudev/SceneGraphDeveloperExtensions/blob/master/documentation/2-Contenthandlers_Guide.md)

## Media Views

Starting with SGDEX v2.6 you can leverage the ContentManager used by the SGDEX 
MediaView to populate your own custom media views. You can use all the same 
ContentHandlers supported by MediaView to manage your custom view in the
most efficient way possible.

A full working example of a custom media view can be found in the [custom grid view sample channel](https://github.com/rokudev/SceneGraphDeveloperExtensions/tree/master/samples/CustomGrid_ContentManager)

### Requirements

In order to use the Media ContentManager, you must do all of the following in your custom view:

- Extend from an RSG component. We recommend using the Group component
- Include the following required fields: `content`, `jumpToItem`, `control`, `contentManagerType`

### MediaView fields (optional)

You can optionally add any field to your custom view that exists in MediaView. For example: _seek_, _state_, or _position_. If you do, those fields will behave exactly as they do in MediaView. A full list of available fields is below.

### Proxy Node (optional)

If you need to access fields on the Video node that are not exposed through MediaView, you can optionally add a a proxy Node in your custom view. This node will mirror the fields on the SGDEX video node. You can find the list of available fields [in this document](https://developer.roku.com/en-gb/docs/references/scenegraph/media-playback-nodes/video.md)

The proxy node *must* be a child of your custom view named _contentMedia_.

#### Example

```
<component name="ProxyVideo" extends="Node">
    <interface>
        <field id="videoFormat" type="string" />
        <field id="retrievingTextColor" type="color" />
        <field id="bufferingTextColor" type="color" />
        <field id="enableUi" type="boolean" value="true" />
        <field id="mute" type="boolean" value="false" />
        <field id="loop" type="boolean" value="false" />
        <field id="bufferingStatus" type="assocarray" />
    </interface>
</component>
```
#### Usage

```
sub Init()
    ' set color for Retrieving lable
    m.proxyVideo.retrievingTextColor = "#e62222"
    ' observe change of buffering status
    m.proxyVideo.ObserveField("bufferingStatus", "OnBufferingStatus")
end sub
```

### Building the View

#### Required Fields

Your custom view must include the following fields. These are used by the ContentManager to optimize the performance of the data loading logic and give the user the most responsive experience possible.

* **content** (ContentNode)
    * Default value: invalid
    * Write-only. Specifies the content of the media view as a ContentNode. Depending on isContentList interface value (see below), can represent a single item (isContentList="false", the items is content itself) or a playlist (isContentList="false", the playlist items are child ContentNodes)
* **contentManagerType** (string)
    * Default value: "media"
    * For Media views, you must set this field to "media"
    * This field tells the ContentManager which mode to operate in for this view. 
* **jumpToItem** (integer)
    * Default value: 0
    * This field must be declared as alwaysNotify=true
    * Write-only. Allows to jump to the given index in the content playlist assigned to the view
* **control** (string)
    * Default value: "none"
    * This field must be declared as alwaysNotify=true
    * Write-only. Specifies the control value for the Video node like "play", "pause" etc. Supported values are the same as for the Video node control field

#### Optional Fields

Your custom view may include the following fields if you need them. These fields will behanve exactly as they do in MediaView.

* **isContentList** (boolean)
    * Default value: true
    * Write-only. Specifies if the ContentNode set to the content interface of the view represents the playlist (true, default value) or a single item (false). If set to true then the actual content items are the child ContentNodes of the content. This field must be set prior to setting the content field
* **mode** (string)
    * Default value: "video"
    * This field must be declared as alwaysNotify=true
    * Read/Write. Specifies the view mode. Allowed values: "audio", "video". The value can be updated by the SGDEX if there is mixed content playlist with both audio and video items.
* **seek** (integer)
    * Default value: -1
    * This field must be declared as alwaysNotify=true
    * Write-only. Specify a position in seconds from the beginning to seek to within the currently played content item
* **preloadContent** (boolean)
    * Default value: false
    * This field must be declared as alwaysNotify=true
    * Write-only. Specifies if the next item in playlist should be preloaded while the Endcard is displayed
* **currentIndex** (integer)
    * Default value: -1
    * This field must be declared as alwaysNotify=true
    * Read/Observe only. SGDEX will populate this field with the index of the current item of the content playlist
* **state** (string)
    * Default value: ""
    * Read/Observe only. SGDEX will populate this field with the current state of the media view. Values will correspond to the Video node state.
* **position** (integer)
    * Default value: 0
    * Read/Observe only. SGDEX will populate this field with the playback position in seconds for the current content item
* **duration** (integer)
    * Default value: 0
    * Read/Observe only. SGDEX will populate this field with the duration in seconds for the current content item
* **currentItem** (node)
    * Default value: invalid
    * This field must be declared as alwaysNotify=true
    * Read/Observe only. SGDEX will populate this field with the current content item being processed/played
* **enableTrickPlay** (boolean)
    * Default value: true
    * This field must be declared as alwaysNotify=true
    * Write-only. Allows trickplay (FF/RW/Pause/Resume) functionality for the user is set to true. If set to false, disables trickplay completely.
* **repeatOne** (boolean)
    * Default value: false
    * Write-only. If set to true, makes only one content item to be always repeated (works only for mode="audio").
* **repeatAll** (boolean)
    * Default value: false
    * Write-only. If set to true, makes all the playlist to be repeated/looped (works only for mode="audio" and isContentList="true").
* **shuffle** (boolean)
    * Default value: false
    * This field must be declared as alwaysNotify=true
    * Write-only. If set to true, shuffles the playlist (works only for mode="audio" and isContentList="true"). If set to false and playlist has been previously shuffled, changes playlist back to unshuffled order.
* **endcardCountdownTime** (integer)
    * Default value: 10
    * This field must be declared as alwaysNotify=true
    * Write-only. Affects only mode="video". Specifies the time in seconds for the endcard to be displayed until the next piece of content starts.
* **alwaysShowEndcards** (boolean)
    * Default value: false
    * Write-only. Affects only mode="video". Specifies if the media view always displays endcard even if the configHandlerEndcard hasn't been set on the content item ContentNode.
* **endcardItemSelected** (node)
    * Default value: invalid
    * This field must be declared as alwaysNotify=true
    * Read/Observe only. SGDEX will populate this field with the endcard item selected by the user (if endcards were enabled/available)
* **wasShown** (boolean)
    * Default value: false
    * This field must be declared as alwaysNotify=true
    * Read/Observe only. Will be populated by ComponentController behind the scenes once view is added to the stack or appears at the top of the stack once some other view gets closed.
* **wasClosed** (boolean)
    * Default value: false
    * This field must be declared as alwaysNotify=true
    * Read/Observe only. Will be populated by ComponentController behind the scenes once view is closed.

#### Example

```
<component name="CustomMedia" extends="Group">
    <interface> 
        <field id="contentManagerType" type="string" value="media" />
        <field id="content" type="node" />
        <field id="jumpToItem" type="integer" value="0" alwaysNotify="true" />
        <field id="control" type="string" value="none" alwaysNotify="true" />
    </interface>
    <script type="text/brightscript" uri="CustomMedia.brs" />
    <children>
        <ProxyVideo id="contentMedia" />
    </children>
</component>
```

### Usage

Once you've built your custom view, using it with SGDEX is exactly the same as using any other view in SGDEX.

#### Example

```
sub Show(args as Object)
    customView = CreateObject("roSGNode","MyCustomView")
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        HandlerConfigMedia: { name: "CHMediaRoot" }
    }, true)
    m.customView.content = content
    m.top.ComponentController.callFunc("show", { view: customView })
end sub
```
A sample channel using ContentManager with a custom view can be found [here](/samples/CustomGrid_ContentManager)

### Endcards

Starting with SGDEX v2.7 you can define a custom endcard UX for your custom media view.

A full working example of custom endcards can be found in the [video preloading sample channel](https://github.com/rokudev/SceneGraphDeveloperExtensions/tree/master/samples/video_preloading)

#### Requirements

In order to use custom endcards, your custom media view must have a child node whose id is "endcardLayout". This child should be extended from a Group node.

#### Required Fields

Your custom endcard layout must include the following field. 

* **visible** (boolean)
    * Default value: false
    * Specifies if the endcard layout is visible. SGDEX wil set this field to "true" when the endcard is displayed to the user.

#### Optional Fields

Your custom endcard layout may include the following field if needed. 

* **content** (node)
    * Default value: invalid
    * SGDEX will populate this field with data from your EndcardHandler if you define one.

#### Example

EndcardLayout.xml
```
<component name="EndcardLayout" extends="FocusableGroup">
    <interface>
        <field id="content" type="node" />
    </interface>
    <children>
        <Button
            id="repeatButton"
            text="Replay"
        />
        <Button
            id="playNextButton"
            text="Play next"
        />
        <RowList
            id="grid"
        />
    </children>
</component>
```

CustomMedia.xml
```
<component name="CustomMedia" extends="Group">
    <interface> 
        <field id="contentManagerType" type="string" value="media" />
        <field id="content" type="node" />
        <field id="jumpToItem" type="integer" value="0" alwaysNotify="true" />
        <field id="control" type="string" value="none" alwaysNotify="true" />
    </interface>
    <script type="text/brightscript" uri="CustomMedia.brs" />
    <children>
        <ProxyVideo id="contentMedia" />
        <EndcardLayout
            id="endcardLayout"
            visible="false"
        />
    </children>
</component>
```

CustomMedia.brs
```
sub Init()
    m.endcardView = m.top.FindNode("endcardLayout")
    m.endcardView.ObserveField("visible", "OnEndcardsVisibleChanged")
    m.endcardView.ObserveField("content", "OnContentChanged")
    m.grid = m.top.FindNode("grid")
    m.grid.ObserveField("rowItemSelected", "OnRowItemSelected")
    m.repeatButton = m.top.FindNode("repeatButton")
    m.repeatButton.ObserveField("buttonSelected", "OnButtonSelected")
    m.playNextButton = m.top.FindNode("playNextButton")
    m.playNextButton.ObserveField("buttonSelected", "OnPlayNextButtonSelected")
end sub

sub OnEndcardsVisibleChanged(event as Object)
    ? "visible=" event.GetData()
    ' Do some stuff on visible change if you need. SGDEX set "visible" to true at the end of playback.
end sub

sub OnPlayNextButtonSelected()
    ' Start next item of playlist
    m.top.control = "play"
    m.endcardView.visible = false
end sub

sub OnButtonSelected()
    ' Replay previous item of playlist
    m.top.jumpToItem = m.top.currentIndex - 1
    m.top.control = "play"
    m.endcardView.visible = false
end sub

sub OnContentChanged()
    m.grid.content = m.endcardView.content
end sub

sub OnRowItemSelected(event as Object)
    selectedItemIndex = event.GetData()
    grid = event.GetRoSGNode()
    row = grid.content.GetChild(selectedItemIndex[0])
    item = row.GetChild(selectedItemIndex[1])
    ' Set new content and start playback
    m.top.content = item
    m.top.control = "play"
    m.endcardView.visible = false
end sub
```

## Details Views

Starting with SGDEX v2.8 you can leverage the ContentManager used by the SGDEX 
DetailsView to populate your own custom detail style views. You can use all the same 
data loading models supported by DetailsView to populate your custom view in the
most efficient way possible.

### Requirements

In order to use the details ContentManager, you must do all of the following in your custom view:

- Extend from an RSG component. We recommend using the Group component
- Include the following fields: `content`, `contentManagerType`, `itemFocused`

### Building the View

#### Required Fields
Your custom view must include the following fields. These are used by the ContentManager
to optimize the performance of the data loading logic and give the user the most
responsive experience possible.

* **content** (ContentNode)
    * Default value: invalid  
    * Specifies the content of the details view as a ContentNode. Depending on isContentList interface value, can represent a single item (isContentList="false", the items is content itself) or a list (isContentList="true", the list items are child ContentNodes).
* **contentManagerType** (string)
    * Default value: "details"
    * For Details views, you must set this field to "details"
    * This field tells the ContentManager which mode to operate in for this view. 
* **itemFocused** (integer)
    * Default value: 0
    * This field tells what item is currently focused.
    * This field can be safely removed only if your view includes an isContentList field whose value is false.

#### Optional Fields

Your custom view may include the following fields if you need them. These fields will behanve exactly as they do in DetailsView.

* **isContentList** (bool)
    * Default value: true
    * Specifies whether the ContentNode set to the content interface of the view represents the list or a single item (false). This field, if defined on a custom view, must be specified prior to setting the content field.
* **currentItem** (node)
    * Default value: invalid
    * SGDEX will populate this field with the current content item being processed by the details ContentManager.
* **wasShown** (boolean)
    * Default value: false
    * Will be populated by ComponentController behind the scenes once the view gets added to the stack or appears at the top of the stack when some other view gets closed.
* **wasClosed** (boolean)
    * Default value: false
    * Will be populated by ComponentController behind the scenes once the view gets closed.

#### Example

```
<?xml version="1.0" encoding="UTF-8"?>
<component name="CustomDetails" extends="Group">
  <script type="text/brightscript" uri="CustomDetails.brs" />
  <interface>
      <field id="content" type="node" />
      <field id="contentManagerType" type="string" value="details"/>
      <field id="itemFocused" type="integer" value="0"/>
  </interface>
  <children>
      ...
  </children>
</component>
```

### Usage

Once you've built your custom view, using it with SGDEX is exactly the same as using any other view in SGDEX.

#### Example

```
sub Show(args as Object)
    customView = CreateObject("roSGNode", "CustomDetails")
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        HandlerConfigDetails: {
                name: "CHList"
            }
    }, true)
    customView.content = content
    m.top.ComponentController.callFunc("show", {
        view: customView
    })
end sub
```
## Button Bar
Starting with SGDEX 2.9 you can leverage the ContentManager used by the SGDEX ButtonBar to populate your own custom button bar.

### Requirements
In order to use button bar ContentManager, you must do all of the following in your custom button bar component:
* Extend from an RSG renderable node (we recommend using the Group)
* Include `content` field

Optionally, you can specify a renderable node to be automatically used by SGDEX for the button bar content rendering and focus handling. This is a recommended approach. In order to do this, you need to
* include a child node of one of the types to your custom button bar: MarkupGrid, PosterGrid, MarkupList, LabelList
* this child node ID *must* be "contentButtonBar" in order to be used by SGDEX

### Building button bar component
#### Required Fields
Your custom button bar component must include the following fields to be used by the ContentManager to optimize the performance of the data loading logic and give the user the most responsive experience possible.
* **content** (ContentNode)
    * Default value: invalid
    * If this ContentNode includes *handlerConfigButtonBar*, the associated ContentHandler will be used to update the content and drive the ContentManager, just like with default ButtonBar
    * If custom button bar contains "contentButtonBar" child, this ContentNode value will be automatically applied to it by SGDEX for rendering

#### Optional Fields 
Your custom view may include the following fields if you need them.
* **alignment** (string)
    * Default value: "top" 
    * This field tells SGDEX where to position button bar on the screen
* **overlay** (boolean)
    * Default value: false
    * This field tells SGDEX whether button bar should be rendered in front of the views and their content
    * Used by SGDEX views to adjust their layout. Custom views are responsible for if/how they react to this field
* **renderOverContent** (boolean)
    * Default value: false
    * This field tells SGDEX whether button bar should be rendered in from of the playing content in MediaView and SlideShowView
    *  Used by SGDEX views to adjust their layout. Custom views are responsible for if/how they react to this field
* **itemFocused** (integer)
    * Default value: -1
    * This field is useful in case you have list component, the one with ID "contentButtonBar"
    * This field should be an alias to the itemSelected field of the
list component
    * This field tells what item is currently focused
* **itemSelected** (integer)
    * Default value: -1 
    * This field is useful in case you have list component, the one with ID "contentButtonBar"
    * This field should be an alias to the itemSelected field of the
list component
    * This field tells what item is currently selected
#### Example
```
<?xml version="1.0" encoding="UTF-8"?>
<component name="CustomButtonBar" extends="Group">
    <script type="text/brightscript" uri="CustomButtonBar.brs" />
    <interface>
        <!-- Required field -->
        <field id="content" type="node" />
        <!-- Optional fields -->
        <field id="alignment" type="string" value="top" />
        <field id="overlay" type="bool" value="false" />
        <field id="renderOverContent" type="bool" value="true" />
        <field id="itemFocused" type="integer" alias="contentButtonBar.itemFocused" />
        <field id="itemSelected" type="integer" alias="contentButtonBar.itemSelected" />
    </interface>
    <children>
        <MarkupGrid
            id="contentButtonBar"
            itemComponentName="ButtonBarItem" />
    </children>
</component>
```
### Usage
In order to use your custom button bar instead of the default ButtonBar, you need to:
* Create you custom button bar instance
* Assign it to the scene *buttonBar* field
* Populate the button bar with the ContentNode
    * ContentNode could either be already populated with the data, or include *handlerConfigButtonBar* field with the config for associated ContentHandler
* Show the button bar by setting its *visible* field to *true*
#### Example
```
' create custom button bar component
buttonBar = CreateObject("roSGNode", "CustomButtonBar")
 
' set it to the scene "buttonBar" field (m.top is a scene as we are in the scene scope here)
m.top.buttonBar = buttonBar
 
' create empty content node with the CH config
content = CreateObject("roSGNode", "ContentNode")
content.AddFields({
    HandlerConfigButtonBar: {
        name: "CHCustomButtonBar"
    }
})
 
' set this to the button bar "content" field to populate the custom button bar
m.top.buttonBar.content = content

' show the button bar
m.top.buttonBar.visible = true
```

## Details Views

Starting with SGDEX v2.8 you can leverage the ContentManager used by the SGDEX 
DetailsView to populate your own custom detail style views. You can use all the same 
data loading models supported by DetailsView to populate your custom view in the
most efficient way possible.

### Requirements

In order to use the details ContentManager, you must do all of the following in your custom view:

- Extend from an RSG component. We recommend using the Group component
- Include the following fields: `content`, `contentManagerType`, `itemFocused`

### Building the View

#### Required Fields
Your custom view must include the following fields. These are used by the ContentManager
to optimize the performance of the data loading logic and give the user the most
responsive experience possible.

* **content** (ContentNode)
    * Default value: invalid  
    * Specifies the content of the details view as a ContentNode. Depending on isContentList interface value, can represent a single item (isContentList="false", the items is content itself) or a list (isContentList="true", the list items are child ContentNodes).
* **contentManagerType** (string)
    * Default value: "details"
    * For Details views, you must set this field to "details"
    * This field tells the ContentManager which mode to operate in for this view. 
* **itemFocused** (integer)
    * Default value: 0
    * This field tells what item is currently focused.
    * This field can be safely removed only if your view includes an isContentList field whose value is false.

#### Optional Fields

Your custom view may include the following fields if you need them. These fields will behanve exactly as they do in DetailsView.

* **isContentList** (bool)
    * Default value: true
    * Specifies whether the ContentNode set to the content interface of the view represents the list or a single item (false). This field, if defined on a custom view, must be specified prior to setting the content field.
* **currentItem** (node)
    * Default value: invalid
    * SGDEX will populate this field with the current content item being processed by the details ContentManager.
* **wasShown** (boolean)
    * Default value: false
    * Will be populated by ComponentController behind the scenes once the view gets added to the stack or appears at the top of the stack when some other view gets closed.
* **wasClosed** (boolean)
    * Default value: false
    * Will be populated by ComponentController behind the scenes once the view gets closed.

#### Example

```
<?xml version="1.0" encoding="UTF-8"?>
<component name="CustomDetails" extends="Group">
  <script type="text/brightscript" uri="CustomDetails.brs" />
  <interface>
      <field id="content" type="node" />
      <field id="contentManagerType" type="string" value="details"/>
      <field id="itemFocused" type="integer" value="0"/>
  </interface>
  <children>
      ...
  </children>
</component>
```

### Usage

Once you've built your custom view, using it with SGDEX is exactly the same as using any other view in SGDEX.

#### Example

```
sub Show(args as Object)
    customView = CreateObject("roSGNode", "CustomDetails")
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        HandlerConfigDetails: {
                name: "CHList"
            }
    }, true)
    customView.content = content
    m.top.ComponentController.callFunc("show", {
        view: customView
    })
end sub
```

## Button Bar
Starting with SGDEX 2.9 you can leverage the ContentManager used by the SGDEX ButtonBar to populate your own custom button bar.

### Requirements
In order to use button bar ContentManager, you must do all of the following in your custom button bar component:
* Extend from an RSG renderable node (we recommend using the Group)
* Include `content` field

Optionally, you can specify a renderable node to be automatically used by SGDEX for the button bar content rendering and focus handling. This is a recommended approach. In order to do this, you need to
* include a child node of one of the types to your custom button bar: MarkupGrid, PosterGrid, MarkupList, LabelList
* this child node ID *must* be "contentButtonBar" in order to be used by SGDEX

### Building button bar component
#### Required Fields
Your custom button bar component must include the following fields to be used by the ContentManager to optimize the performance of the data loading logic and give the user the most responsive experience possible.
* **content** (ContentNode)
    * Default value: invalid
    * If this ContentNode includes *handlerConfigButtonBar*, the associated ContentHandler will be used to update the content and drive the ContentManager, just like with default ButtonBar
    * If custom button bar contains "contentButtonBar" child, this ContentNode value will be automatically applied to it by SGDEX for rendering

#### Optional Fields 
Your custom view may include the following fields if you need them.
* **alignment** (string)
    * Default value: "top" 
    * This field tells SGDEX where to position button bar on the screen
* **overlay** (boolean)
    * Default value: false
    * This field tells SGDEX whether button bar should be rendered in front of the views and their content
    * Used by SGDEX views to adjust their layout. Custom views are responsible for if/how they react to this field
* **renderOverContent** (boolean)
    * Default value: false
    * This field tells SGDEX whether button bar should be rendered in from of the playing content in MediaView and SlideShowView
    *  Used by SGDEX views to adjust their layout. Custom views are responsible for if/how they react to this field
* **itemFocused** (integer)
    * Default value: -1
    * This field is useful in case you have list component, the one with ID "contentButtonBar"
    * This field should be an alias to the itemSelected field of the
list component
    * This field tells what item is currently focused
* **itemSelected** (integer)
    * Default value: -1 
    * This field is useful in case you have list component, the one with ID "contentButtonBar"
    * This field should be an alias to the itemSelected field of the
list component
    * This field tells what item is currently selected
#### Example
```
<?xml version="1.0" encoding="UTF-8"?>
<component name="CustomButtonBar" extends="Group">
    <script type="text/brightscript" uri="CustomButtonBar.brs" />
    <interface>
        <!-- Required field -->
        <field id="content" type="node" />
        <!-- Optional fields -->
        <field id="alignment" type="string" value="top" />
        <field id="overlay" type="bool" value="false" />
        <field id="renderOverContent" type="bool" value="true" />
        <field id="itemFocused" type="integer" alias="contentButtonBar.itemFocused" />
        <field id="itemSelected" type="integer" alias="contentButtonBar.itemSelected" />
    </interface>
    <children>
        <MarkupGrid
            id="contentButtonBar"
            itemComponentName="ButtonBarItem" />
    </children>
</component>
```
### Usage
In order to use your custom button bar instead of the default ButtonBar, you need to:
* Create you custom button bar instance
* Assign it to the scene *buttonBar* field
* Populate the button bar with the ContentNode
    * ContentNode could either be already populated with the data, or include *handlerConfigButtonBar* field with the config for associated ContentHandler
* Show the button bar by setting its *visible* field to *true*
#### Example
```
' create custom button bar component
buttonBar = CreateObject("roSGNode", "CustomButtonBar")
 
' set it to the scene "buttonBar" field (m.top is a scene as we are in the scene scope here)
m.top.buttonBar = buttonBar
 
' create empty content node with the CH config
content = CreateObject("roSGNode", "ContentNode")
content.AddFields({
    HandlerConfigButtonBar: {
        name: "CHCustomButtonBar"
    }
})
 
' set this to the button bar "content" field to populate the custom button bar
m.top.buttonBar.content = content

' show the button bar
m.top.buttonBar.visible = true
```

###### Copyright (c) 2021 Roku, Inc. All rights reserved.
