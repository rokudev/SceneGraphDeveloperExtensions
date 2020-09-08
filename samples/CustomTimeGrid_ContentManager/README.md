# SGDEX Guide: Using custom time grid with SGDEX Content Manager

## Introduction

SGDEX provides developers with the possibility to connect their time grid-like RSG views with SGDEX time grid content manager. This channel uses the TimeGridView's `row-by-row loading model`.
### Content Manager loading models
- root model - when HandlerConfigTimeGrid is placed on the root level of the Content node and ContentHandler is invoked exactly once and returns entire content of the TimeGridView
- row-by-row model - when HandlerConfigTimeGrid is placed on each row (channel) of the root EPG content and ContentHandler is invoked for populating this specific row (channel)
- dynamic insertion model - more advanced row-by-row model when HandlerConfigTimeGrid is placed on each row (channel), contains pagination parameters and ContentHandler is invoked multiple times to insert related subset of EPG data into the row

We place a handler config on the root node of our content tree. 
When that
handler runs, it creates a child node for each row that should be displayed. It also
places a handler config on each of those nodes. When those row level handlers run,
they create a child node for each program that should be displayed on their respective row.
## Part 1: Custom time grid view
Custom time grid should extend basic RSG component (Group, etc.):
```
<component name="MyTimeGrid" extends="Group">
```
Such kind of interfaces should be supported:
- `"contentManagerType"` provides type of the content manager to be used 
for this custom view (suffix of the **handlerConfig*** ).
"**timeGrid** => handerConflig**TimeGrid**"
- `"content"` will be automatically passed to the child grid component that corresponds to contentManagerType. Handled by content manager behind the scenes.
"**timeGrid** =>"content**TimeGrid**"
- `"wasShown"` should just exist. Will be populated by ComponentController behind the scenes once view is added to the stack or appears at the top of the stack once some other view gets closed.
- `"wasClosed"` should just exist. Will be populated by ComponentController behind the scenes once view is closed.

In *"MyTimeGrid.xml"*:
```
    <interface>
        <field id="contentManagerType" type="string" value="timegrid" />
        <field id="content" type="node" />
        <field id="wasShown" type="node" alwaysNotify="true" />
        <field id="wasClosed" type="boolean" alwaysNotify="true" />
    </interface>
```
Custom time grid view should contain RSG time grid component as its child that will hold the actual content of the custom view (custom time grid also may have any other children). In *"MyTimeGrid.xml"*:
```
 <children>
        ...
        <CustomTimeGrid id="contentTimeGrid" />
        ...
    </children>
```
This child time grid component should have `id="contentTimeGrid"`.

Next, we should find elements of our custom grid, in order to make it visible, or set attributes, as we want, done in *"MyTimeGrid.brs"*:
```
sub Init()
    currentTime =  CreateObject("roDateTime")
    
    m.timegrid = m.top.FindNode("contentTimeGrid")
    m.title = m.top.FindNode("title")
    m.description = m.top.FindNode("description")
    m.poster = m.top.FindNode("poster")
    
    m.timegrid.ObserveField("channelFocused", "OnChannelFocused")
    m.timegrid.ObserveField("programFocused", "OnProgramFocused")
    
    m.timegrid.Update({
        ...
        contentStartTime : currentTime.AsSeconds()
        leftEdgeTargetTime : currentTime.AsSeconds()
        ...
    }, true)
end sub
```
Fields `"title" `, `"description"` and `"poster"` stand for details of focused program (implemented like additional children of custom view)
In this particular sample, we are observing fields `"channelFocused"` and `"programFocused"` in order to react every time we focus on *program* of the particular *channel*. When we trigger that, we must check out if content is valid, and then dynamically update those details, which are shown above the time grid. Logic is basically collaborative either for `"OnChannelFocused"` or `"OnProgramFocused"`, so we moved that to `"OnChannelProgramFocused"` function.
## Part 2: Integrating into RSG channel
Show custom time grid view using regular SGDEX method with creating view node and providing content handler using HandlerConfigTimeGrid field (as it's time grid-like view). In *"MainScene.brs"*:
```
sub Show(args as Object)
    timegrid = CreateObject("roSGNode", "MyTimeGrid")

    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        HandlerConfigTimeGrid: { name: "CHRoot" }
    }, true)

    grid.content = content

    m.top.ComponentController.callFunc("show", {
        view: timegrid
    })
end sub
```
## Part 3: Implementing content node
As described above, we are using "row-by-row loading model". In this model,
we place a handler config on the root node of our content tree. When that
handler runs, it creates a child node (`"CHRow"`) for each row that should be displayed. It also places a handler config on each of those nodes. When those row level handlers run, they create a child node for each program that should be displayed on their respective row. In *"CHRoot.brs"*: 
```
sub GetContent()
    raw = ReadASCIIFile("pkg:/api/1_channels.json")
    json = ParseJSON(raw)

    rootChildren = [] 
    for each channel in json
        ...
        channelNode = CreateObject("roSGNode", "ContentNode")
        ...
        channelNode.addFields({
           HandlerConfigTimeGrid: {
               name: "CHRow"
           }
        })

        rootChildren.push(channelNode)
    end for
    
    m.top.content.AppendChildren(rootChildren)
end sub
```

### API

This channel uses a simulated API represented by a collection of static files
bundled into the channel. There are 3 different API calls simulated in this channel.

* An initial call to get a list of channels
* A call for each channel to get more detailed metadata for it (title, callsign, etc)
* A call for each channel to get the list of programs for it
