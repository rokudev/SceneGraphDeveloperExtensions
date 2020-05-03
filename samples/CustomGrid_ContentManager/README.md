# SGDEX Guide: Using custom grid with SGDEX Content Manager

## Introduction

SGDEX now provides developers with the possibility to connect their grid-like RSG view’s with SGDEX grid content manager.

In this sample we're using `non-serial page loading model` using public API - https://archive.org/advancedsearch.php to show page loading model using non-SGDEX view. Now to bind your grid-like view with SGDEX grid content manger you should do:
1. Create view
2. Implement content handler
3. Show the view with binded content handler

Step by step implementation described below.

Detailed information about implementing Content Handlers can be found in [SGDEX documentation](https://github.com/rokudev/SceneGraphDeveloperExtensions/blob/master/documentation/2-Contenthandlers_Guide.md).


## Part 1: Creating own grid view
To create custom grid view we should add RSG grid component like ZoomRowList, what was done in *CustomZoomRowList.xml*. Then, we need to add proper interfaces, they are:`saveState,wasShown,wasClosed,rowItemFocused,content and contentManagerType`, to component interfaces and alias`rowItemFocused` field to make SGDEX able to paginate content.
```
<?xml version="1.0" encoding="UTF-8"?>
<component name="CustomZoomRowList" extends="Group" >

    <script type="text/brightscript" uri="CustomZoomRowList.brs" />

    <interface>
       <field id="rowItemFocused" type="vector2d" alwaysNotify="true" alias="contentGrid.rowItemFocused"/>
       <field id="content" type="node"/>
       <field id="contentManagerType" type="string" value="grid"/>
       <field id="saveState" type="boolean" value="false"/>
       <field id="wasShown" type="boolean" value="false"/>
       <field id="wasClosed" type="boolean" value="false"/>
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

## Part 2: Implementing content handler
### Part 2.1: Creating placeholders for content items
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
### Part 2.2: Replacing placeholders with received content items
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

## Part 3: Initializing the component
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

## Result
After view was shown, loading process will start and first 3 rows will load asynchronously, then if user will navigate to other row - it will be loaded, else if user will navigate to next items in focused row - row pagination will start. Otherwise - lazyloading will gradually load all the grid content.

###### Copyright (c) 2020 Roku, Inc. All rights reserved.
