# RCL v1.0 Content Manager Notes

## Content Management

The RCL content manager simplifies task management for developers so they don't have to worry as much about things like Task Nodes and the multi-threaded nature of Roku Scene Graph. RCL does this using Content Handlers. In order to populate a view, all the developer needs to do is provide RCL with a some config data to drive that view's Content Getter(s).

### Content Handlers

Content Handlers (CHs) are really just Task nodes, but that fact is largely abstracted away from the developer. From the developer's perspective a CH is just a RSG component that implements a BrightScript function. That function is called by RCL when a particular bit of content is needed. 

CHs do their job by modifying the Content node referenced by `m.top.content`. 

A CH has two pieces, markup and BrightScript. A very simple CH might look like this.

Markup (SimpleContentGetter.xml)

    <?xml version="1.0" encoding="UTF-8"?>
    <component name="SimpleContentGetter" extends="ContentHandler" >
      <script type="text/brightscript" uri="pkg:/components/content/SimpleContentGetter.brs" />
    </component>

BrightScript (SimpleContentGetter.brs)

    sub GetContent() 
      m.top.content.SetFields({
        title: "Hello World"
      })
    end sub

### Content Getter Handler Config

Each CH is driven by a Content Handler Config (CHConfig). The CHConfig is set as the value of a field on the content node it is intended to modify. The simplest CHConfig consists of just the name of the component that implements it. This example defines a DetailView CHConfig that will invoke the simple CH defined above.

    myContentNode.AddFields({
      HandlerConfigDetails: {
        name: "SimpleContentGetter"
      }
    }

### Grid View Suppoted Data Models

#### Single Task

In this model, all the data for the entire grid is populated by a single CH. The CHConfig for this CH should be placed on the GridView's root Content Node.

#### One Task Per Row

In this model, the rows of a grid are defined by a root CH similar to in the *Single Task* model, but the content for each row is populated by a seperate CH. To accomplish this, each row that requires loading should have it's CHConfig. You can set it either in root CH or in any other place.

#### Multiple Tasks Per Row

This model typically applies to situations where a developer is working with an API that returns the content for a row in pages and each page requires a seperate API call. There are two variations of this model.

##### Serial

In this variation, the pages of content for a row must be requested in order.

To accomplish this, the root CH should place CHConfigs on each of its child nodes (that represent row), similar to the *One Task Per Row* model. The difference is that the row CHConfigs should have a field `hasMore` that tells RCL that row has more items to load. This CH will be invoked by RCL multiple times without deleting the CHConfig. When developer loads portion serial content and he knows that there is more content he sets new CH to `m.top.content` inside of `getContent` function.

##### Non-Serial

In this variation, the pages of content for a row can be requested out of order. You must know at the outset how many items will ultimately be on each row.

This is the most complex model to implement. To accomplish this, the root CH should place CHConfigs on each of its child nodes(that represent row), similar to the *One Task Per Row* model. When RCL invokes a row's initial CH, it will delete the CHConfig. The initial CH should do two things:

* Populate the row with *n* placeholder content items where *n* is the final number of items the row will contain
* Place a new CHConfig on the row's node with a `pageSize` field, similar to in the serial model.

RCL will call this secondary row CH multiple times without deleting the CHConfig. Each time the CH should update the appropriate placeholder items on the row with their final content. The CH should use the values found in `m.top.offset` and `m.top.pageSize` to determine which items it needs to update.

### CHConfig Management

In some cases, when RCL invokes a CH, it deletes the associated CHConfig. In some situations a developer may need to re-run a CH. One example is the case where an API request fails. In this case the recommended approach is for the CH to detect the error and then set m.top.failed = true in getContent() function, if developer needs to invoke another handler he can specify a new CHConfig on the same Content Node which is passed by Library to `m.top.content` filed in Content handler, otherwise old config will be used. This will cause RCL to invoke the CH defined by the new CHConfig so the request can be re-tried.


### Details View Suppoted Data Models

If you don't have content to show on details screen and need to load it via API call you should set  `HandlerConfigDetails` to content node in your details view. This CH has basic structure see *Content Getter Handler Config*. 

Details view supports two variants of consuming content list model and single model. List model is used to show list of items on details view and user can navigate right/left to switch them. Single model is details screen that opens only one item.


#### List model
Is Default Model

To load list of items to be displayed in details screen you have to set CH to view's content node and inside of `getContent` function populate `m.top.content` with items to be displayed.

#### Single Item Model
To load single item to content details. You can set single content node to view if you want to show only one item and can't create list of one item.

Note. you have to set _view.isContentList = false_ in order for details screen to understand that this is not a list of items but just one item. If you need more details to be loaded you can specify CH for this item and details list will load data for it.
