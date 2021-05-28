# SGDEX Sample Channel

## Video Preloading (Requires SGDEX v1.1)

This sample demonstrates using the SGDEX MediaView in playlist mode with endcards and preloading.
Preloading enables pre-flight execution of ContentHandlers and prebuffering of content
to minimize the amount of time the video buffer screen is visible.

### GridView

The GridView displays a single row of videos parsed from an RSS feed.

### DetailsView and MediaView

In this sample, the DetailsView and MediaView are more tightly integrated than if we weren't preloading.
When the DetailsView is shown, we also create a MediaView and begin preloading the content.
The MediaView is not shown until the user selects the "Play" button on the DetailsView.

## Custom endcard layout (Requires SGDEX v2.7)

Starting from v2.7, SGDEX provides developers with the possibility to create a custom endcard layout to be used with a custom media view.

In this sample we leverage custom endcard support for the videos from the second row of the main grid. In order to use the custom endcard layout, we must also use a custom media view.

### Build the custom media view

The process of building and using a custom media view is documented [here](../../documentation/6-ContentManager_with_Custom_Views_Guide.md#media-views).

First, we create a [custom media view](components/CustomMedia/CustomMedia.xml) that extends Group. We then add the fields required for the sample.

```
<component name="CustomMedia" extends="Group">
    <interface> 
        <field id="contentManagerType" type="string" value="media" />
        <field id="content" type="node" />
        <field id="jumpToItem" type="integer" value="0" alwaysNotify="true" />
        <field id="control" type="string" value="none" alwaysNotify="true" />
        <field id="alwaysShowEndcards" type="bool" alwaysNotify="true" />
        <field id="preloadContent" type="bool" value="false" />
        <field id="wasClosed" type="bool" value="false" alwaysNotify="true" />
    </interface>
    <script type="text/brightscript" uri="CustomMedia.brs" />
```

### Build the custom endcard layout

The process of building a custom endcard layout is documented [here](../../documentation/6-ContentManager_with_Custom_Views_Guide.md#endcards).

For this sample, we first create a [custom endcard layout](components/CustomMedia/CustomEndcardLayout.xml) that extends Group and contains the RSG elements needed to render the custom endcard.

Next, we specify the custom endcard layout as a child of the [custom media view](components/CustomMedia/CustomMedia.xml) having `id="endcardLayout"`. This will allow SGDEX to detect the custom endcard and use it instead of the standard layout.

```
    <children>
        <CustomEndcardLayout
            id="endcardLayout"
            visible="false"
        />
    </children>
</component>
```

In the scope of the [custom media view](components/CustomMedia/CustomMedia.brs) we can access the custom endcard and its elements using `FindNode()` to assign callback functions and build the logic for managing the custom endcard UX.

###### Copyright (c) 2021 Roku, Inc. All rights reserved.
