# SGDEX Guide: Using custom details views with SGDEX ContentManager

## Custom Details Views

Starting from v2.8, SGDEX provides developers with the possibility to connect their details-like RSG view’s with SGDEX details ContentManager.

In this sample we build a custom slide view and populate its content using SGDEX DetailsView Content Handlers.

## Creating a Custom Details View

The process of building and using a custom details view is documented here [SGDEX documentation](../../documentation/6-ContentManager_with_Custom_Views_Guide.md).

In the current sample, we build a custom slide view as a variant of the custom details view. Similar to the standard DetailsView, the content of the view will contain the list of Content Nodes representing the slide items content and there will be only one slide item displayed at a time.

We define a component named "CustomSlide" (see `CustomSlide.xml`) that extends RSG Group and define fields required to use SGDEX details view ContentManager:

-  _content_ - to be able to specify content of our custom view as a ContentNode.
- _contentManagerType_ - we set this field value to "details" to indicate that we intend to use details view ContentManager and Content Handlers to populate the view content.
- _itemFocused_ - this field will identify which slide item is currently focused and displayed.

In addition, we define _currentItem_ field which is optional for SGDEX custom details view. SGDEX will populate this field with the current content item being processed by the details ContentManager and we will leverage this in the sample app to update the slide poster URL once it's populated in the Content Handler.

We also define two custom fields that we use for the slide display logic:

- _control_ - controls the slides playback (auto-switching). Supported values are "play" and "pause".
- _slideDuration_ - defines for how many seconds the slide will be displayed before switching to the next one if _control="play"_.


## Implementing the ContentHandler

In the current sample, we use list model details Content Handler to populate list of the slides with their titles and descriptions (`CHSlide.brs`):

```
    childrenArray = []
    for index = 1 to 4
        SlideItem = CreateObject("roSGNode", "ContentNode")
        SlideItem.Update({
            title: "Item " + index.toStr()
            description: "This is description for Item " + index.toStr()
            HandlerConfigDetails: {
                name: "CHSlideItem"
                fields:{
                    slideIndex: index
                }
            }
        },true)
        childrenArray.Push(SlideItem)
    end for
```

As you can see from the code above, we also specify item-level ContentHandler configs for the slide items, so when the item is being focused, SGDEX will run additional Content Handler (`CHSlideItem.brs`) to populate the item poster URL (`hdPosterUrl`).


### Initializing the component

We use our custom view in the channel the same way we would use the standard DetailsView. 

We create the CustomSlide view as roSGNode object:
```
    slide = CreateObject("roSGNode", "CustomSlide")
```

Then we create a ContentNode with the HandlerConfigDetails specifying `CHSlide` as a Content Handler name:
```
    slideContent = CreateObject("roSGNode", "ContentNode")
    slideContent.Update({
        HandlerConfigDetails: {
            name: "CHSlide"
        }
    }, true)
```

and set this ContentNode to the _content_ field of our custom view:
```
    slide.content = slideContent
```

We also set additional _control_ field that we defined on the view to initiate slides playback (auto-switching):
```
    slide.control = "play"
```

and finally, we call "show" function on the SGDEX ComponentController to display the view:
```
    m.top.ComponentController.CallFunc("show", {
        view: slide
    })
```

###### Copyright (c) 2021 Roku, Inc. All rights reserved.

