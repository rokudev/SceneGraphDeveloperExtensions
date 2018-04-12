# RCL Components:  
* [BaseScene](#basescene)  
* [EntitlementView](#entitlementview)  
* [VideoView](#videoview)  
* [RCLComponent](#rclcomponent)  
* [GridView](#gridview)  
* [DetailsView](#detailsview)  
* [CategoryListView](#categorylistview)  
* [ComponentController](#componentcontroller)  
* [EntitlementHandler](#entitlementhandler)  
* [RAFHandler](#rafhandler)  
* [ContentHandler](#contenthandler)

____

## <a id="BaseScene"></a>BaseScene
### <a id="BaseScene#extends"></a>Extends: Scene
### <a id="BaseScene#description"></a>Description
User should extend BaseScene and work in it's context.  
Function show(args) should be overrided in channel.

### <a id="BaseScene#interface"></a>Interface
#### <a id="BaseScene#fields"></a>Fields

* <a id="BaseScene#fields#ComponentController"></a>**ComponentController** (node)
    * reference to ComponentController node that is created and used inside library  
    * Read Only  
* <a id="BaseScene#fields#exitChannel"></a>**exitChannel** (bool)
    * Exits channel if set to true  
    * Write Only  
* <a id="BaseScene#fields#theme"></a>**theme** (assocarray)
    * Theme is used to customize the appearance of all RCL views.  
For common fields see [RCLComponent](#RCLComponent#fields#theme)  
For view specific views see view documentation  
[GridView](#GridView_fields_theme)  
[DetailsView](#DetailsView#fields#theme)  
[VideoView](#VideoView#fields#theme)  
[CategoryListView](#CategoryListView#fields#theme)  
<b>Theme can be set to several levels</b>  
<b>Any view:</b>  
<code>  
scene.theme = {  
&nbsp;&nbsp;global: {  
&nbsp;&nbsp;&nbsp;&nbsp;textColor: "FF0000FF"  
&nbsp;&nbsp;}  
}  
</code>  
Set's all text colors to red  
<b>Type of view</b>  
<code>  
scene.theme = {  
&nbsp;&nbsp;gridView: {  
&nbsp;&nbsp;&nbsp;&nbsp;textColor: "FF0000FF"  
&nbsp;&nbsp;}  
}  
</code>  
Set's all grids text color to red  
<b>Instance specific:</b>  
use view's theme field to set it's theme  
<code>  
view = CreateObject("roSGNode", "GridView")  
view.theme = {  
&nbsp;&nbsp;textColor: "FF0000FF"  
}  
</code>  
this grid will only have text color red  
All theme fields are combined and used by view when created, so you can set  
<code>  
scene.theme = {  
&nbsp;&nbsp;   global: {  
&nbsp;&nbsp;&nbsp;&nbsp;textColor: "FF0000FF"  
&nbsp;&nbsp;}  
&nbsp;&nbsp;gridView: {  
&nbsp;&nbsp;&nbsp;&nbsp;textColor: "00FF00FF"  
&nbsp;&nbsp;}  
}  
view1 = CreateObject("roSGNode", "GridView")  
view2 = CreateObject("roSGNode", "GridView")  
view.2theme = {  
&nbsp;&nbsp;textColor: "FFFFFFFF"  
}  
detailsView= CreateObject("roSGNode", "DetailsView")  
</code>  
In this case  
view1 - will have texts in 00FF00FF  
view2 - will have FFFFFFFF  
detailsView - will take textColor from global and it will be FF0000FF  

* <a id="BaseScene#fields#updateTheme"></a>**updateTheme** (assocarray)
    * Field to update themes by passing the config   
Structure of config is same as for [theme](#BaseScene#fields#theme) field.   
You should only pass fields that should be updated not all theme fields.  
Note. if you want to change a lot of fields change them with as smaller amount of configs as you can, it wouldn't redraw views too often then.  


### <a id="BaseScene#sample"></a>Sample of usage:
    // MainScene.xml
    <?xml version="1.0" encoding="UTF-8"?>
    <component name="MainScene" extends="BaseScene" >
        <script type="text/brightscript" uri="pkg:/components/MainScene.brs" />
    </component>

    // MainScene.brs
    sub Show(args)
        homeGrid = CreateObject("roSGNode", "GridView")
        homeGrid.content = GetContentNodeForHome() ' implemented by user
        homeGrid.ObserveField("rowItemSelected","OnGridItemSelected")
        'this will trigger job to show this screen
        m.top.ComponentController.callFunc("show", {
            view: homeGrid
        })
    end sub



___

## <a id="EntitlementView"></a>EntitlementView
### <a id="EntitlementView#extends"></a>Extends: [RCLComponent](#rclcomponent)
### <a id="EntitlementView#description"></a>Description
EntitlementView is a view that allows RCL user to make subscription easy.  
There are two basic behaviours:  
1) Silen check of available subscription  
2) Checking with show Entitlement view/flow  
To pass configs to View, user should implement handler that extends EntitlementHandler

### <a id="EntitlementView#interface"></a>Interface
#### <a id="EntitlementView#fields"></a>Fields

* <a id="EntitlementView#fields#isSubscribed"></a>**isSubscribed** (bool)
    * Default value: false
    * [ObserveOnly] sets to true|false and shows if user is subscribed after:  
1) checking via silentCheckEntitlement=true (see below)  
2) exitting from subscription flow initiated by adding view to screen stack  

* <a id="EntitlementView#fields#silentCheckEntitlement"></a>**silentCheckEntitlement** (bool)
    * Default value: false
    * initiates silent entitlement checking (headless mode)  
    * Write Only

### <a id="EntitlementView#sample"></a>Sample of usage:
    // [In channel]
    // contentItem - content node with handlerConfigEntitlement: {name : "HandlerEntitlement"}

    // To make just silent check if user subscribed
    ent = CreateObject("roSGNode", "EntitlementView")
    ent.ObserveField("isSubscribed", "OnSubscriptionChecked")
    ent.content = contentItem
    ent.silentCheckEntitlement = true

    // To show billing flow:
    ent = CreateObject("roSGNode","EntitlementView")
    ent.ObserveField("isSubscribed", "OnIsSubscribedToPlay")
    ent.content = contentItem
    m.top.ComponentController.callFunc("show", {view: ent})


___

## <a id="VideoView"></a>VideoView
### <a id="VideoView#extends"></a>Extends: [RCLComponent](#rclcomponent)
### <a id="VideoView#description"></a>Description
Video View is a component that provide pre-defined approach to play Video  
It incapsulates different features:  
- Playback of video playlist or one item;  
- Loading of content via HandlerConfigVideo before playback;  
- Showing Endcards View after video playback ends;  
- Loading of endcard content via HandlerConfigEndcard some time before video ends to provide smooth user experience;  
- Handling of Raf - handlerConfigRAF should be set in content node;  
- Video.state field is aliased to make tracking of states easier;  
- Themes support

### <a id="VideoView#interface"></a>Interface
#### <a id="VideoView#fields"></a>Fields

* <a id="VideoView#fields#endcardCountdownTime"></a>**endcardCountdownTime** (integer)
    * Default value: 10
    * Endcard countdown time. How much endcard is shown until next video start  

* <a id="VideoView#fields#endcardLoadTime"></a>**endcardLoadTime** (integer)
    * Default value: 10
    * Time to end when endcard content start load  

* <a id="VideoView#fields#alwaysShowEndcards"></a>**alwaysShowEndcards** (bool)
    * Default value: false
    * Config to know should Video View show endcards with default next item and Repeat button  
even if there is no content getter specified by user  

* <a id="VideoView#fields#isContentList"></a>**isContentList** (bool)
    * Default value: true
    * To make library know is it playlist or individual item  

* <a id="VideoView#fields#jumpToItem"></a>**jumpToItem** (integer)
    * Jumps to item in playlist  
  This field must be set after setting the content field.  

* <a id="VideoView#fields#control"></a>**control** (string)
    * Control "play" and "prebuffer" makes library start to load content from Content Getter  
if any other control - set it directly to video node  

* <a id="VideoView#fields#endcardTrigger"></a>**endcardTrigger** (boolean)
    * Trigger to notify channel that endcard loading is started  

* <a id="VideoView#fields#currentIndex"></a>**currentIndex** (integer)
    * Default value: -1
    * Field to know what is index of current item - index of child in content Content Node  

* <a id="VideoView#fields#state"></a>**state** (string)
    * Video Node state  

* <a id="VideoView#fields#position"></a>**position** (int)
    * Playback position in seconds  

* <a id="VideoView#fields#currentItem"></a>**currentItem** (node)
    * If change this field manually, unexpected behaviour can occur.  
    * Read Only  
* <a id="VideoView#fields#endcardItemSelected"></a>**endcardItemSelected** (node)
    * Content node of endcard item what was selected  

* <a id="VideoView#fields#disableScreenSaver"></a>**disableScreenSaver** (boolean)
    * Default value: false
    * This is an alias of the video node's field of the same name  
  https://sdkdocs.roku.com/display/sdkdoc/Video#Video-MiscellaneousFields  

* <a id="VideoView#fields#theme"></a>**theme** (assocarray)
    * Theme is used to change color of grid view elements  
<b>Note.</b> you can set TextColor and focusRingColor to have generic theme and only change attributes that shouldn't use it.  
<b>Possible fields:</b>  
<b>General fields</b>  
	* Possible values  
     * TextColor - set text color for all texts on video and endcard views
     * progressBarColor - set color for progress bar
     * focusRingColor - set color for focus ring on endcard view
     * backgroundColor - set background color for endcards view
     * backgroundImageURI - set background image url for endcards view
     * endcardGridBackgroundColor -set background color for grid for endcard items  
<b>Video player fields:</b>
     * trickPlayBarTextColor - Sets the color of the text next to the trickPlayBar node indicating the time elapsed/remaining.
     * trickPlayBarTrackImageUri - A 9-patch or ordinary PNG of the track of the progress bar, which surrounds the filled and empty bars. This will be blended with the color specified by the trackBlendColor field, if set to a non-default value.
     * trickPlayBarTrackBlendColor - This color is blended with the graphical image specified by trackImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.
     * trickPlayBarThumbBlendColor - Sets the blend color of the square image in the trickPlayBar node that shows the current position, with the current direction arrows or pause icon on top. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.
     * trickPlayBarFilledBarImageUri - A 9-patch or ordinary PNG of the bar that represents the completed portion of the work represented by this ProgressBar node. This is typically displayed on the left side of the track. This will be blended with the color specified by the filledBarBlendColor field, if set to a non-default value.
     * trickPlayBarFilledBarBlendColor - This color will be blended with the graphical image specified in the filledBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.
     * trickPlayBarCurrentTimeMarkerBlendColor - This is blended with the marker for the current playback position. This is typically a small vertical bar displayed in the TrickPlayBar node when the user is fast-forwarding or rewinding through the video.  
<b>Buffering Bar customization</b>
     * bufferingTextColor - The color of the text displayed near the buffering bar defined by the bufferingBar field, when the buffering bar is visible. If this is 0, the system default color is used. To set a custom color, set this field to a value other than 0x0.
     * bufferingBarEmptyBarImageUri - A 9-patch or ordinary PNG of the bar presenting the remaining work to be done. This is typically displayed on the right side of the track, and is blended with the color specified in the emptyBarBlendColor field, if set to a non-default value.
     * bufferingBarFilledBarImageUri - A 9-patch or ordinary PNG of the bar that represents the completed portion of the work represented by this ProgressBar node. This is typically displayed on the left side of the track. This will be blended with the color specified by the filledBarBlendColor field, if set to a non-default value.
     * bufferingBarTrackImageUri - A 9-patch or ordinary PNG of the track of the progress bar, which surrounds the filled and empty bars. This will be blended with the color specified by the trackBlendColor field, if set to a non-default value.
     * bufferingBarTrackBlendColor - This color is blended with the graphical image specified by trackImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.
     * bufferingBarEmptyBarBlendColor - A color to be blended with the graphical image specified in the emptyBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.
     * bufferingBarFilledBarBlendColor - This color will be blended with the graphical image specified in the filledBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.  
<b>Retrieving Bar customization</b>
     * retrievingTextColor - Same as bufferingTextColor but for retrieving bar
     * retrievingBarEmptyBarImageUri - Same as bufferingBarEmptyBarImageUri but for retrieving bar
     * retrievingBarFilledBarImageUri - Same as bufferingBarFilledBarImageUri but for retrieving bar
     * retrievingBarTrackImageUri - Same as bufferingBarTrackImageUri but for retrieving bar
     * retrievingBarTrackBlendColor - Same as bufferingBarTrackBlendColor but for retrieving bar
     * retrievingBarEmptyBarBlendColor - Same as bufferingBarEmptyBarBlendColor but for retrieving bar
     * retrievingBarFilledBarBlendColor - Same as bufferingBarFilledBarBlendColor but for retrieving bar  
<b>Endcard view theme attributes</b>
     * buttonsFocusedColor - repeat button focused text color
     * buttonsUnFocusedColor - repeat button unfocused text color
     * buttonsfocusRingColor - repeat button background color  
<b>grid attributes</b>
     * rowLabelColor - grid row title color
     * focusRingColor - grid focus ring color
     * focusFootprintBlendColor - grid unfocused focus ring color
     * itemTextColorLine1 - text color for 1st row on endcard item
     * itemTextColorLine2 - text color for 2nd row on endcard item
     * timerLabelColor - Color of remaining timer


### <a id="VideoView#sample"></a>Sample of usage:
    video = CreateObject("roSGNode", "VideoView")

    video.content = content
    video.jumpToItem = index
    video.control = "play"

    m.top.ComponentController.callFunc("show", {
        view: video
    })

    ' user can observe video.endcardItemSelected to handle endcard selection
    ' video.currentIndex or video.currentItem fields can be used to track what was the last video after video closed.


___

## <a id="RCLComponent"></a>RCLComponent
### <a id="RCLComponent#extends"></a>Extends: Group
### <a id="RCLComponent#description"></a>Description
Base component for RCL views that adds common fields and handles theme params passing to view,  
 each view is responsible for populating proper params to it's views

### <a id="RCLComponent#interface"></a>Interface
#### <a id="RCLComponent#fields"></a>Fields

* <a id="RCLComponent#fields#theme"></a>**theme** (assocarray)
    * Theme is used to set view specific theme fields, this is used to set initial theme, if you want to update any value use updateTheme  
Commmon attributes for all view:  
*textColor - Set text color to all supported labels  
*focusRingColor - Set focus ring color  
*progressBarColor - Set color for progress bars  
*backgroundImageURI - Set url to background image  
*backgroundColor - Set background color  
*OverhangTitle - text that will be displayed in overhang title   
*OverhangTitleColor - Color of overhang title  
*OverhangShowClock - toggle showing of overhang clock  
*OverhangShowOptions - show options on overhang  
*OverhangOptionsAvailable - tells if options are available. Note this is only visual field and doesn't affect if developer implements options  
*OverhangVisible - set if overhang should be visible    
*OverhangLogoUri - url to overhang logo  
*OverhangBackgroundUri - overhang background url  
*OverhangOptionsText - text that will be show in options  
*OverhangHeight - height of overhang  
*OverhangBackgroundColor - overhang background color  
Usage:  
To set global theme attributes refer to [BaseScene](#BaseScene#fields#theme)   
To set view specific fields use:  
view = CreateObject("roSGNode", "GridView")  
view.theme = {  
textColor: "FF0000FF"  
}  

* <a id="RCLComponent#fields#updateTheme"></a>**updateTheme** (assocarray)
    * updateTheme is used to update view specific theme fields  
Usage is same as [theme](#RCLComponent#fields#theme) field but here you should only set field that you want to update  
If you want global updates use [BaseScene updateTheme](#BaseScene#fields#updateTheme)  

* <a id="RCLComponent#fields#style"></a>**style** (string)
    * is used to tell view what style should be used, style is view specific  

* <a id="RCLComponent#fields#posterShape"></a>**posterShape** (string)
    * is used to tell view what poster shape should be used for posters that are rendered on view  

* <a id="RCLComponent#fields#content"></a>**content** (node)
    * Main field for setting content  
content tree is specific to each view and is handled by view itself  

* <a id="RCLComponent#fields#close"></a>**close** (boolean)
    * Control field to tell Screen Manager to close this screen manually.  
Is desined for authentication flows or other flows when set of screens should be closed after some action.  

* <a id="RCLComponent#fields#wasClosed"></a>**wasClosed** (boolean)
    * Observe this to know when view is closed and removed from Screen Manager  

* <a id="RCLComponent#fields#saveState"></a>**saveState** (boolean)
    * Observe this to know when view is hiding and new top view is being opened  

* <a id="RCLComponent#fields#wasShown"></a>**wasShown** (boolean)
    * Observe this to know when view was shown for first time or restored after top view was closed  


___

## <a id="GridView"></a>GridView
### <a id="GridView#extends"></a>Extends: [RCLComponent](#rclcomponent)
### <a id="GridView#description"></a>Description
Grid view represents RCL grid that is responsible for:  
- content loading   
- lazy loading of rows and item in row  
- loading pages of content  
- lazy loading rows when user is not navigating

### <a id="GridView#interface"></a>Interface
#### <a id="GridView#fields"></a>Fields

* <a id="GridView#fields#rowItemFocused"></a>**rowItemFocused** (vector2d)
    * Updated when focused item changes  
Value is an array containing the index of the row and item that were focused  

* <a id="GridView#fields#rowItemSelected"></a>**rowItemSelected** (vector2d)
    * Updated when an item is selected  
Value is an array containing the index of the row and item that were selected  

* <a id="GridView#fields#jumpToRowItem"></a>**jumpToRowItem** (vector2d)
    * Set grid focus to specified item   
Value is an array containing the index of the row and item that should be focused  
This field must be set after setting the content field.  

* <a id="GridView_fields_theme"></a>**theme** (assocarray)
    * Controls the color of visual elements  
	* Possible values  
     * textColor - sets the color of all text elements in the view
     * focusRingColor - set color of focus ring
     * focusFootprintColor - set color for focus ring when unfocused
     * rowLabelColor - sets color for row title
     * itemTextColorLine1 - set color for first row in item description
     * itemTextColorLine2 - set color for second row in item description
     * titleColor - sets color of title
     * descriptionColor - sets color of description text
     * descriptionmaxWidth - sets max width for description
     * descriptionMaxLines - sets max lines for description

* <a id="GridView#fields#style"></a>**style** (string)
    * Styles are used to tell what grid UI will be used  
	* Possible values  
     * standard - is default grid style
     * hero - is default grid style

* <a id="GridView#fields#posterShape"></a>**posterShape** (string)
    * Controls the aspect ratio of the posters on the grid  
	* Possible values  
     * 16x9
     * portrait
     * 4x3
     * square

* <a id="GridView#fields#content"></a>**content** (node)
    * Controls how RCL will load the content for the view  

Content metadata field that can be used:  
root = {  
children:[{  
title: "Row title"  
children: [{  
title: "title that will be shown on upper details section"  
description: "Description that will be shown on upper details section"  
hdPosterUrl: "Poster URL that should be shown on grid item"  
releaseDate: "Release date string"  
StarRating: "star rating integer between 0 and 100"  
_gridItemMetaData: "fields that are used on grid"  
shortDescriptionLine1: "first row that will be displayed on grid"  
shortDescriptionLine2: "second row that will be displayed on grid"  

_forShowing_bookmarks_on_grid: "Add these fields to show bookmarks on grid item"  
length: "length of video"  
bookmarkposition: "actual bookmark position"  
_note: "tels if this bar should be hidden, default = true"  
hideItemDurationBar: false  
}]     
}]  
}  
If you have to make API call to get list of rows set content like this:  
content = CreateObject("roSGNode", "ContentNode")  
content.addfields({  
HandlerConfigGrid: {  
name: "CHRoot"  
}  
})  
grid.content = content  
Where CHRoot is a ContentHandler that is responsible for getting rows for grid  
IF you know the structure of your grid but need to load content to rows you can do:  
content = CreateObject("roSGNode", "ContentNode")  
row = CreateObject("roSGNode", "ContentNode")  
row.title = "first row"  
row.addfields({  
HandlerConfigGrid: {  
name: "ContentHandlerForRows"  
fields : {  
myField1 : "value I need to pass to content handler"  
}  
}  
})  
grid.content = content  
Where   
1) "ContentHandlerForRows" is content handler that will be called to get content for provided row.  
2) fields is AA of values that will be set to ContentHandler so you can pass additional data to ContentHandler  
Note. that passing row itself or grid via fields might cause memory leaks    
You can set row ContentHandler even when parsing content in "CHRoot", so it will be called when data for that row is needed  


### <a id="GridView#sample"></a>Sample of usage:
    grid = CreateObject("roSGNode", "GridView")
    grid.setFields({
        style: "standard"
        posterShape: "16x9"
    })
    content = CreateObject("roSGNode", "ContentNode")
    content.addfields({
        HandlerConfigGrid: {
            name: "CHRoot"
        }
    })
    grid.content = content

    'this will trigger job to show this screen
    m.top.ComponentController.callFunc("show", {
        view: grid
    })


___

## <a id="DetailsView"></a>DetailsView
### <a id="DetailsView#extends"></a>Extends: [RCLComponent](#rclcomponent)
### <a id="DetailsView#description"></a>Description
buttons support same content meta-data fields as Label list, so you can set title and small icon for each button  
fields description:  
TITLE - string  The label for the list item  
HDLISTITEMICONURL - uri The image file for the icon to be displayed to the left of the list item label when the list item is not focused  
HDLISTITEMICONSELECTEDURL - uri The image file for the icon to be displayed to the left of the list item label when the list item is focused

### <a id="DetailsView#interface"></a>Interface
#### <a id="DetailsView#fields"></a>Fields

* <a id="DetailsView#fields#buttons"></a>**buttons** (node)
    * Content node for buttons node. Has childrens with id and title that will be shown on View.  

* <a id="DetailsView#fields#isContentList"></a>**isContentList** (bool)
    * Default value: true
    * Tells details view how your content is structured  
if set to true it will take children of _content_ to display on screen  
if set to false it will take _content_ and display it on the screen  
    * Write Only  
* <a id="DetailsView#fields#allowWrapContent"></a>**allowWrapContent** (bool)
    * Default value: true
    * defines logic of showing content when pressing left on first item, or pressing right on last item.  
if set to true it will start from start from first item (when pressing right) or last item (when pressing left)  
    * Write Only  
* <a id="DetailsView#fields#currentItem"></a>**currentItem** (node)
    * Current displayed item. This item is set when Content Getter finished loading extra meta-data  
    * Read Only  
* <a id="DetailsView#fields#itemFocused"></a>**itemFocused** (integer)
    * tells what item is currently focused  

* <a id="DetailsView#fields#jumpToItem"></a>**jumpToItem** (integer)
    * Default value: 0
    * Manually focus on desired item. This field must be set after setting the content field.  
    * Write Only  
* <a id="DetailsView#fields#buttonFocused"></a>**buttonFocused** (integer)
    * Tells what button is focused  
    * Read Only  
* <a id="DetailsView#fields#buttonSelected"></a>**buttonSelected** (integer)
    * Is set when button is selected by user. Should be observed in channel.  
Can be used for showing next screen or start playback or so.  
    * Read Only  
* <a id="DetailsView#fields#jumpToButton"></a>**jumpToButton** (integer)
    * Interface for setting focused button  
    * Write Only  
* <a id="DetailsView#fields#theme"></a>**theme** (assocarray)
    * Controls the color of visual elements  
	* Possible values  
     * textColor - sets the color of all text elements in the view
     * focusRingColor - set color of focus ring
     * focusFootprintColor - set color for focus ring when unfocused
     * rowLabelColor - sets color for row title
     * descriptionColor -set the color of descriptionLabel
     * actorsColor -set the color of actorsLabel
     * ReleaseDateColor -set the the color for ReleaseDate
     * RatingAndCategoriesColor -set the color of categories
     * buttonsFocusedColor - set the color of focused buttons
     * buttonsUnFocusedColor - set the color of unfucused buttons
     * buttonsFocusRingColor - set the color of button focuse ring
     * buttonsSectionDividerTextColor - set the color of section divider


___

## <a id="CategoryListView"></a>CategoryListView
### <a id="CategoryListView#extends"></a>Extends: [RCLComponent](#rclcomponent)
### <a id="CategoryListView#description"></a>Description
CategoryListView represents RCL category list view that shows two lists: one for categories another for items in category

### <a id="CategoryListView#interface"></a>Interface
#### <a id="CategoryListView#fields"></a>Fields

* <a id="CategoryListView#fields#initialPosition"></a>**initialPosition** (vector2d)
    * Default value: [0, 0]
    * Tells where set initial focus on itemsList: 1st coordinate = category, 2st coordinate = item in this category  

* <a id="CategoryListView#fields#selectedItem"></a>**selectedItem** (vector2d)
    * Array with 2 ints - section and item in current section that was selected  
    * Read Only  
* <a id="CategoryListView#fields#focusedItem"></a>**focusedItem** (int)
    * Current focued item index (within all categories)  
    * Read Only  
* <a id="CategoryListView#fields#focusedItemInCategory"></a>**focusedItemInCategory** (int)
    * Current focued item index from current focusedCategory  

* <a id="CategoryListView#fields#focusedCategory"></a>**focusedCategory** (int)
    * Current focused category index.  

* <a id="CategoryListView#fields#jumpToItem"></a>**jumpToItem** (int)
    * Jumps to item in items list (within all categories).  
  This field must be set after setting the content field.  
    * Write Only  
* <a id="CategoryListView#fields#animateToItem"></a>**animateToItem** (int)
    * Animates to item in items list (within all categories).  
    * Write Only  
* <a id="CategoryListView#fields#jumpToCategory"></a>**jumpToCategory** (int)
    * Jumps to category.  
    * Write Only  
* <a id="CategoryListView#fields#animateToCategory"></a>**animateToCategory** (int)
    * Animates to category.  
    * Write Only  
* <a id="CategoryListView#fields#jumpToItemInCategory"></a>**jumpToItemInCategory** (int)  
    * Write Only  
* <a id="CategoryListView#fields#animateToItemInCategory"></a>**animateToItemInCategory** (int)
    * Animates to item in current category.  
    * Write Only  
* <a id="CategoryListView#fields#theme"></a>**theme** (assocarray)
    * Theme is used to change color of grid view elements  
Note. you can set TextColor and focusRingColor to have generic theme and only change attributes that shouldn't use it.  
Possible fields:  
*TextColor - changes color for all text fields in category list  
*focusRingColor - changes color of focus rings for both category and item list  
*categoryFocusedColor - set focused text color for category  
*categoryUnFocusedColor - set unfocused text color for category  
*itemTitleColor - set item title color  
*itemDescriptionColor - set item description color  
*categoryfocusRingColor - set color for category list focus ring  
*itemsListfocusRingColor - set color for item list focus ring  

* <a id="CategoryListView#fields#content"></a>**content** (node)
    * In order to build proper content node tree you have to stick to this model:  
Possible fields:  
Category fields:  
Title - Title that will be displayed for category name  
CONTENTTYPE - Must be set to SECTION  
HDLISTITEMICONURL - The image file for the icon to be displayed to the left of the list item label when the list item is not focused  
HDLISTITEMICONSELECTEDURL - The image file for the icon to be displayed to the left of the list item label when the list item is focused  
HDGRIDPOSTERURL - The image file for the icon to be displayed to the left of the section label when the screen resolution is set to HD.  
Item List fields:  
title - Title to be shown  
description - Description for item, max 4 lines  
hdPosterUrl - image url for item  


### <a id="CategoryListView#sample"></a>Sample of usage:
    CategoryList = CreateObject("roSGNode", "CategoryListView")
    CategoryList.posterShape = "square"

    content = CreateObject("roSGNode", "ContentNode")
    content.Addfields({
        HandlerCategoryList: {
            name: "CGSeasons"
        }
    })

    CategoryList.content = content
    CategoryList.ObserveField("selectedItem", "OnEpisodeSelected")

    ' this will trigger job to show this screen
    m.top.ComponentController.CallFunc("show", {
        view: CategoryList
    })

    <b>Advanced loading logic</b>

    root = {
        HandlerConfigCategoryList: {
            _description: "Content handler that will be called to populate categories if they are not created"
            name: "Component name that extends [ContentHandler](#ContentHandler)"
            fields: {
                field: "any field that you want to set in this component when it's created"
            }
        }
        _comment: "categories"
        children: [{
            title: "Category that is prepopulated"
            contentType: "section"
            children: [{
                title: "Title to be shown"
                description: "Description for item, max 4 lines"
                hdPosterUrl: "image url for item"
            }]
            _optionalFields: "Fields that can be used for category"
            HDLISTITEMICONURL: "icon that will be shown left to category when not focused"
            HDLISTITEMICONSELECTEDURL: "icon that will be shown left to category title when focused"
            HDGRIDPOSTERURL: "icon that will be shown left to title in item list"
        }, {
            title: "Category that requires content to be loaded"
            contentType: "section"
            HandlerConfigCategoryList: {
                _description: "Content handler that will be called if there are no children in category"
                name: "Component name that extends [ContentHandler](#ContentHandler)"
                fields: {
                    field: "any field that you want to set in this component when it's created"
                }
            }
        }, {
            title: "Category that has children but they need metadata (non serial model)"
            contentType: "section"
            HandlerConfigCategoryList: {
                _description: "Content handler that will be called if "
                name: "Component name that extends [ContentHandler](#ContentHandler)"
                _note: "use bigger value for page size to improve performance"
                _mandatatory: "This field is required in order to work"

                pageSize: 2
                fields: {
                    field: "any field that you want to set in this component when it's created"
                }
            }
            children: [{title: "Title to be shown"}
                {title: "Title to be shown"}
                {title: "Title to be shown"}
                {title: "Title to be shown"}]
        }, {
            title: "Category has children but there are more items that can be loaded"
            contentType: "section"
            HandlerConfigCategoryList: {
                _description: "Content handler will be called when focused near end of category"
                name: "Component name that extends [ContentHandler](#ContentHandler)"
                _mandatatory: "This field is required in order to work"
                hasMore: true
                fields: {
                    field: "any field that you want to set in this component when it's created"
                }
            }
            children: [{
                title: "Title to be shown"
                description: "Description for item, max 4 lines"
                hdPosterUrl: "image url for item"
            }]
        }]
    }

    CategoryList = CreateObject("roSGNode", "CategoryListView")
    CategoryList.posterShape = "square"

    content = CreateObject("roSGNode", "ContentNode")
    content.update(root)

    CategoryList.content = content

    ' this will trigger job to show this screen
    m.top.ComponentController.CallFunc("show", {
        view: CategoryList
    })



___

## <a id="ComponentController"></a>ComponentController
### <a id="ComponentController#extends"></a>Extends: Group
### <a id="ComponentController#description"></a>Description
ComponentController (CC) is a node that responsible to make basic screen interaction logic.  
From user side, CC is used to show screens for different use cases.  
There are 2 flags to handle close behaviour:  
allowCloseChannelOnLastView:bool=true and allowCloseLastViewOnBack:bool=true

### <a id="ComponentController#interface"></a>Interface
#### <a id="ComponentController#fields"></a>Fields

* <a id="ComponentController#fields#currentView"></a>**currentView** (node)
    * holds the reference to view that is currently shown.  
Can be used for checking in onkeyEvent  

* <a id="ComponentController#fields#allowCloseChannelOnLastView"></a>**allowCloseChannelOnLastView** (boolean)
    * Default value: true
    * If user set this flag channel closes when press back or set close=true on last view  

* <a id="ComponentController#fields#allowCloseLastViewOnBack"></a>**allowCloseLastViewOnBack** (boolean)
    * Default value: true
    * If user set this flag the last screen will be closed and user can open another in wasClosed callback  

#### <a id="ComponentController#functions"></a>Functions
* <a id="ComponentController#functions#show"></a>**show**
    * Function that has to be called when you want to add view to view stack

### <a id="ComponentController#sample"></a>Sample of usage:
    ' in Scene context in channel
    m.top.ComponentController.callFunc("show", {
        view: screen
    })


___

## <a id="EntitlementHandler"></a>EntitlementHandler
### <a id="EntitlementHandler#extends"></a>Extends: Task
### <a id="EntitlementHandler#description"></a>Description
User should implement own Handler in channel that extends EntitlementHandler  
In this handler user can override 2 function:  
- ConfigureEntitlements(config) [Required]  
- OnPurchaseSuccess(transactionData) [Optional]  
In ConfigureEntitlements user can update config with his own params:  
config should contain fields:  
config.products [Array] of AAs having fields:  
config.products.code [String] product code in ChannelStore  
config.products.hasTrial [Boolean] true if product has trial period  
OnPurchaseSuccess is a callback that allows end developer to inject some suctom logic on purchase success  
by overriding this subroutine. Default implementation does nothing.

### <a id="EntitlementHandler#interface"></a>Interface
#### <a id="EntitlementHandler#fields"></a>Fields

* <a id="EntitlementHandler#fields#content"></a>**content** (node)
    * Content node from EntitlementView will be passed here, user can use it in handler.  

* <a id="EntitlementHandler#fields#view"></a>**view** (node)
    * View is a reference to EntitlementView where this Handler is created.  


### <a id="EntitlementHandler#sample"></a>Sample of usage:
    // [In <component name="HandlerEntitlement" extends="EntitlementHandler"> in channel]
    sub ConfigureEntitlements(config as Object)
        config.products = [
            '{code: "PROD1", hasTrial: false}
            {code: "PROD2", hasTrial: false}
        ]
    end sub


___

## <a id="RAFHandler"></a>RAFHandler
### <a id="RAFHandler#extends"></a>Extends: Task
### <a id="RAFHandler#description"></a>Description
RAFHandler is responsible for making all business logic related to Ads playing.  
User extends this Handler in channel and can override ConfigureRAF(adIface as Object) sub.  
Reference to Raf library instance will be passed to ConfigureRAF sub.  
In ConfigureRAF user can make any configuraion that supported by RAF.



### <a id="RAFHandler#sample"></a>Sample of usage:
    sub ConfigureRAF(adIface)
        ' Detailed RAF docs: https://sdkdocs.roku.com/display/sdkdoc/Integrating+the+Roku+Advertising+Framework
        adIface.SetAdUrl("http://www.some.ad.url.com")
        adIface.SetContentGenre("General Variety")
        adIface.SetContentLength(1200) ' in seconds
        ' Nielsen specific data
        adIface.EnableNielsenDAR(true)
        adIface.SetNielsenProgramId("CBAA")
        adIface.SetNielsenGenre("GV")
        adIface.SetNielsenAppId("P123QWE-1A2B-1234-5678-C7D654348321")
    end sub


___

## <a id="ContentHandler"></a>ContentHandler
### <a id="ContentHandler#extends"></a>Extends: Task
### <a id="ContentHandler#description"></a>Description
Content Handlers are responsible for all content loading tasks in RCL.  
When you extend a Content Hander, you must implement a function called GetContent().  
This function is where you will do things like make API requests and build ContentNodes  
to be rendered in your RCL views.

### <a id="ContentHandler#interface"></a>Interface
#### <a id="ContentHandler#fields"></a>Fields

* <a id="ContentHandler#fields#content"></a>**content** (node)
    * This is the field you should modify in your GetContent() function  
by adding/updating the ContentNodes being rendered by the associated view.  

* <a id="ContentHandler#fields#offset"></a>**offset** (int)
    * When working with paged data, this will reflect which page of content  
RCL is expecting the ContentHandler to populate.  

* <a id="ContentHandler#fields#pageSize"></a>**pageSize** (int)
    * When working with paged data, this will reflect the number of items  
RCL is expecting the ContentHandler to populate.  

* <a id="ContentHandler#fields#failed"></a>**failed** (bool)
    * Default value: false
    * When your ContentHandler fails to load the requested content  
you should set this field to TRUE in your GetContent() function. This will  
force RCL to re-try the ContentHandler.  
In this case, you can also optionally set a new HandlerConfig to the content field.  
That will cause RCL to use the new config when it re-tries the ContentHandler.  
If you do not update the HandlerConfig, RCL will re-use the original one for subsequent tries.  

* <a id="ContentHandler#fields#HandlerConfig"></a>**HandlerConfig** (assocarray)
    * This is a copy of the config that was used to invoke the ContentHandler.  


### <a id="ContentHandler#sample"></a>Sample of usage:
    ' SimpleContentHandler.xml
    <?xml version="1.0" encoding="UTF-8"?>
    <component name="SimpleContentHandler" extends="ContentHandler" >
      <script type="text/brightscript" uri="pkg:/components/content/SimpleContentHandler.brs" />
    </component>

    ' SimpleContentHandler.brs
    sub GetContent()
      m.top.content.SetFields({
        title: "Hello World"
      })
    end sub


___
