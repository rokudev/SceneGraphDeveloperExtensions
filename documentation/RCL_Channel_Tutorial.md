# RCL Channel tutorial

Purpose of this tutorial is to show how to build your first RCL based channel.
This is useful for people that want to build their first channel or are interested to move their existing channel to RSG.

RCL contains such types of views:

*   Grid
*   Details
*   Video with endcard view
*   Category list

Combining those screens you can create your channel without deep knowledge of RSG

## Create project
1.  Using your IDE create new project or use existing project
2.  Check your manifest
It should contain

        ui_resolutions=hd

All views are developed in HD resolution and autoscaled to FHD and SD, so you should develop your app in same resolution.

## Required files

File structure

    project/
        components/
        	   rcl
            your RSG components
        source/
        	   rcl.brs
            main.brs
        manifest

In source folder create one file main.brs and add

<U>Contents of main.brs</U>

    sub GetSceneName()
        return "MainScene"
    end sub

This is code that will create your scene and start everything

"MainScene" is name of your scene.


## Developing your channel

In order to develop RCL channel you have to Create a Scene that is extended from BaseScene


### Scene
Your xml file will look like:

    <?xml version="1.0" encoding="UTF-8"?>
    <component name="MainScene" extends="BaseScene" >
        <script type="text/brightscript" uri="pkg:/components/MainScene.brs" />
        <script type="text/brightscript" uri="pkg:/components/DetailsScreenLogic.brs" />
        <script type="text/brightscript" uri="pkg:/components/VideoPlayerLogic.brs" />
    </component>

In /components/MainScene.brs you should add this code:

    sub Show(args as Object)
        'This function will be called by library when everything is ready to show your content
    end sub

This function will pass params from main.brs so here you can decide what view should be displayed.

You can display home screen or you should create deeplinking screen here if proper params are passed.

Scene has _ComponentController_ interface field that is used to show views and control flows.


### ComponentController
This is component that controls all views

It has interface:

1.  currentScreen - view that is currently in showing
2.  shouldCloseLastScreenOnBack - this field tells if last screen in stack should be closed before channel exits.

You should manipulate this screen if you need to implement deeplinking or confirm exit dilaog when user presses back on first screen.

Function interfaces:

1.  function "show" - this function is used to add new view to stack


### Show your first view
In order to show your first view you have to create it, add content, show it.

Sample of showing grid view:

In /components/MainScene.brs add this code to your show(args) function

    sub Show(args as Object)
        m.grid = CreateObject("roSGNode", "GridView")
        m.grid.ObserveField("rowItemSelected", "OnGridItemSelected")

        'setup UI of view
        m.grid.SetFields({
            style: "standard"
            posterShape: "16x9"
        })
        'This is root content that describes how to populate rest of rows
        content = CreateObject("roSGNode", "ContentNode")
        content.AddFields({
            HandlerConfigGrid: {
                name: "CGRoot"
                fields : { param : "123" }
            }
        })
        m.grid.content = content
        'this will trigger job to show this view
        m.top.ComponentController.CallFunc("show", {
            view: m.grid
        })
    end sub

This code creates simple grid view and shows it.

All views that extend Component have these interfaces:

View UI setup:

*  style - style that should be used, see documentation for each view
*  posterShape - poster shape that has to be used in this view
*  content - view's content
*  overhang - overhang node that can be configured in order to customize each view of your channel, for ex. some views should have options or should have another logo or title

View visibility handling:

*  wasClosed - is triggered when this view is closed, use this when you need to read any value from closed view, for ex. itemFocused to set proper focus on previous screen
*  saveState - is triggered when a new view is opened after this view, is useful when you want to save some data before any view is opened, or for ex. pause audio or video because new view is opened
*  wasShown - is triggered when this view is opened for first time or restored after top view was closed.


*  close - use this field to manually close view, this is used if you have for ex. registration flow and need to close all registration views after successful login.


If you don't have content for the grid you can use HandlerConfigGrid that will describe how to populate rows for grid view.

       content = CreateObject("roSGNode", "ContentNode")
        content.AddFields({
            HandlerConfigGrid: {
                name: "CGRoot"
            }
        })
        m.grid.content = content

### Content Getters
Content getter is component that is responsible for populating content for views

#### Describing Content Getter
if you need to load some data for view you can use content getters that will called when curtain portions of data are required

To add root Content Getter just add it to content of created view:

    m.grid = CreateObject("roSGNode", "GridView")
    content = CreateObject("roSGNode", "ContentNode")
        content.AddFields({
            HandlerConfigGrid: {
                name: "CGRoot"
                fields : { param : "123" }
            }
        })
        m.grid.content = content

Each RCL view has its own Content Getter field which should be AA and have:

1.  name [required] - Project Content Getter component name
1.  fields [optional] - developer interface fields that should be populated


#### Default Content Getter interfaces
Content getter provides predefined list of interfaces

1.  content  - content that should be modified by this content getter, content might be view's content field or child of it when content for child should be loaded (ex. row in grid or item in details or video view)
1.  HandlerConfig - Config that was added by developer, you can read it's values or restore it to content if needed. Note content getter removes processed Configs so if you need to reload data each time content is shown you need to restore config to content in proper Content Getter.
1.  offset   - is used for horizontal lazy loading of grid row, tells which offset is used
1.  pageSize - is used for horizontal lazy loading of grid row, tells pagesize that was configured by developer.

#### Implementing your Content Getter

To create your Content Getter you have to create component and extend it from ContentHandler

Sample:

    <?xml version="1.0" encoding="UTF-8"?>
    <component name="CGRoot" extends="ContentHandler" xsi:noNamespaceSchemaLocation="https://devtools.web.roku.com/schema/RokuSceneGraph.xsd">
        <script type="text/brightscript" uri="pkg:/components/content/CGRoot.brs" />
    </component>


Content getter should implement only one required function GetContent() that doesn't return anything.

    sub GetContent()
        'this is for a sample, usually feed is retrieved from url using roUrlTransfer
        feed = ReadAsciiFile("pkg:/components/content/feed.json")
        if feed.Len() > 0
            json = ParseJson(feed)
            if json <> invalid AND json.rows <> invalid AND json.rows.Count() > 0
                rootChildren = []
                for each row in json.rows
                    if row.items <> invalid
                        children = []
                        for childIndex = 0 to 3
                            for each item in row.items
                                itemNode = CreateObject("roSGNode", "ContentNode")
                                itemNode.SetFields(item)
                                children.Push(itemNode)
                            end for
                        end for

                        rowNode = CreateObject("roSGNode", "ContentNode")
                        rowNode.SetFields({ title: row.title })
                        rowNode.AppendChildren(children)

                        rootChildren.Push(rowNode)
                    end if
                end for
                m.top.content.AppendChildren(rootChildren)
            end if
        end if
    end sub

Contents of json:

    {
        "rows": [{
            "title": "ROW 1",
            "items": [{
                    "hdPosterUrl": "poster_url"
                },{
                    "hdPosterUrl": "poster_url"
                },{
                    "hdPosterUrl": "poster_url"
                },{
                    "hdPosterUrl": "poster_url"
            }]
        },{
            "title": "ROW 2",
            "items": [{
                "hdPosterUrl": "poster_url"
            },{
                "hdPosterUrl": "poster_url"
            },{
                "hdPosterUrl": "poster_url"
            },{
                "hdPosterUrl": "poster_url"
            }]
        }]
    }


Note according to best practices you should use        

    m.top.content.AppendChildren(rootChildren)

as this will remove multiple rendevous between render thread and task node.

### Opening next view
if you need to open any new view on certain action you should use same mechanism to create and populate it.
For example if you want to open details screen upon selection on grid you should write this code:

Assuming you already did:

    m.grid.ObserveField("rowItemSelected", "OnGridItemSelected")

You should then implement your function _OnGridItemSelected_

    sub OnGridItemSelected(event as Object)
        grid = event.GetRoSGNode()
        selectedIndex = event.getdata()
        rowContent = grid.content.getChild(selectedIndex[0])

        detailsScreen = ShowDetailsScreen(rowContent, selectedIndex[1])
        detailsScreen.ObserveField("wasClosed", "OnDetailsWasClosed")
    end sub

### Details view
In /components/DetailsScreenLogic.brs

    function ShowDetailsScreen(content, index)
        details = CreateObject("roSGNode", "DetailsView")

        details.content = content
        details.jumpToItem = index
        details.ObserveField("currentItem", "OnDetailsContentSet")
        details.ObserveField("buttonSelected", "OnButtonSelected")

        'this will trigger job to show this screen
        m.top.ComponentController.callFunc("show", {
            view: details
        })

        return details
    end function

This creates new details view and passes grid row as content for details, uses jumpToItem to set starting index.

If you don't want to pass list of items but only one item you should also do:

    details.content = content.getChild(index)
    'this tells details screen that only one item should be visible
    details.isContentList = false


_isContentList_ - will tell details view that this is proper item to render so it would know that no extra items should be loaded

#### Details view interfaces

Details view provides several extra interfaces:

*   buttons type="node"

        Content node three with buttons
    buttons support same content meta-data fields as Label list, so you can set title and small icon for each button
        fields description:

        TITLE                     - string  The label for the list item
        HDLISTITEMICONURL         - uri The image file for the icon to be displayed to the left of the list item label when the list item is not focused
        HDLISTITEMICONSELECTEDURL - uri The image file for the icon to be displayed to the left of the list item label when the list item is focused

*   isContentList  type="bool", default = true

        Tells details view how your content is structured
    if set to true it will take children of _content_ to display on screen
    if set to false it will take _content_ and display it on the screen

*   allowWrapContent type="bool" default = true

        defines logic of showing content when pressing left on first item, or pressing right on last item.
    if set to true it will start from start from first item (when pressing right) or last item (when pressing left)   

*   itemFocused     type="integer"

        tells what item is currently focused

*   jumpToItem      type="integer"

        manually focus on desired item

*   buttonFocused   type="integer"

        tells what button is focused

*   buttonSelected"  type="integer"

        is set when button is selected by user

*   jumpToButton"    type="integer"

        interface for setting focused button

*   currentItem     type="node"

        current displayed item. This item is set when Content Getter finished loading extra meta-data   


#### Getting extra metadata for details view

Sometimes when setting content to details view you are still pending some info to be loaded to properly show this item.

To resolve this issue you should use content getter for details screen.

      function ShowDetailsScreen(content)
        details = CreateObject("roSGNode", "DetailsView")

        for each child in content.getChildren(-1, 0)
            'This will tell details view which content getter is responsible for getting content
            child.HandlerConfigDetails = {
                name: "GetDetailsContentConfig"
            }
        end for

        details.content = content

        'this will trigger job to show this screen
        m.top.ComponentController.callFunc("show", {
            view: details
        })

        return details
    end function


### Open non RCL view
RCL is not limited to use only RCL view, so in any step you can show your own view and observe it's fields.

To open your view just create it populate interface fields, set observers and call

        m.top.ComponentController.callFunc("show", {
            view: yourViewNode
        })

This will hide current screen (if any) and show your view.

Note. Component controller set's focus on your view, so your view should implement proper focus handling.

For example:

    <?xml version="1.0" encoding="UTF-8"?>
    <component name="CustomView" extends="Group" xsi:noNamespaceSchemaLocation="https://devtools.web.roku.com/schema/RokuSceneGraph.xsd">

        <script type = "text/brightscript" uri="pkg:/components/customView.brs"/ >

        <children>
            <Group id="container">
                <Button id="btn" text="Push Me"/>
            </Group>
        </children>
    </component>

In /components/customView.brs

        function init() as void
            m.btn = m.top.findNode("btn")
            m.top.observeField("focusedChild", "OnChildFocused")
        end function

        sub OnChildFocused()
            if m.top.isInFocusChain() and not m.btn.hasFocus() then
                m.btn.setFocus(true)
            end if
        end sub


_Whenever your view receives focus it should check if it's in focus chain and node that should have focus doesn't_


Focus handling is important as component controller set focus to your view in two cases:

 1.  view is just shown
 2.  view is restored after top view was closed


Component Controller is responsible for closing your view when back button is pressed.
If you want manually close your view, new field is added to your view called "close".

By setting _yourView.close = true_ you can close your view and previous view will be opened.
