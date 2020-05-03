# Using ContentManager with Custom Views

Starting with SGDEX v2.3 you can leverage the ContentManager used by the SGDEX 
GridView to populate your own custom grid based views. You can use all the same 
data loading models supported by GridView to populate your custom grid view in the
most efficient way possible.

## Requirements

In order to use ContentManager, you must do all of the following in your custom view:

- Extend from an RSG component. We recommend using the Group component
- Include the following fields: `content`, `rowItemFocused`, `wasShown`, `wasClosed`, `saveState`, `contentManagerType`
- Include a grid type child component. We recommend RowList or ZoomRowList
- The ID of the grid component *must* be "contentGrid"

## Building the View

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
    * This field is used by the ContentManager. There is no need for you to interact with it directly
* **wasClosed** (boolean)
    * Default value: false
    * This field is used by the ContentManager. There is no need for you to interact with it directly
* **saveState** (boolean)
    * Default value: false
    * This field is used by the ContentManager. There is no need for you to interact with it directly

### Example

```
<component name="MyCustomView" extends="Group">
    <interface>
        <field id="contentManagerType" type="string" value="grid" />
        <field id="rowItemFocused" type="vector2d" alwaysNotify="true" alias="contentGrid.rowItemFocused" />
        <field id="content" type="node" />
        <field id="wasShown" type="boolean" value="false" />
        <field id="wasClosed" type="boolean" value="false" />
        <field id="saveState" type="boolean" value="false" />
    </interface>

    <children>
        <ZoomRowList id="contentGrid" />
    </children>
</component>
```

## Usage 

Once you've built your custom view, using it with SGDEX is exactly the same as using any other view in SGDEX.

### Example

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
For more information on ContentManager see [this document](https://github.com/rokudev/SceneGraphDeveloperExtensions/blob/master/documentation/2-Contenthandlers_Guide.md)

###### Copyright (c) 2020 Roku, Inc. All rights reserved.
