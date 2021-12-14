# SGDEX Sample Channel

## Roku Recommends

This sample shows a complete channel driven by a single RSS feed containing basic deep linking logic implementation.

Samples of the valid deep linking parameters:
    mediaType=episode, contentId=decbe34b64ea4ca281dc09997d0f23fd
    mediaType=episode, contentId=6c9d0951d6d74229afe4adf972b278dd
    mediaType=episode, contentId=7405a8c101ee4c9da312c426e6067044

### GridView

Primary content navigation in this sample uses a _zoom_ style GridView.
The zoom style was introduced in SGDEX v1.1 and enables a zooming animation
as the user navigates vertically within the grid.

### DetailView

Selecting a poster from the grid opens a DetailView for that piece of content.
The DetailView operates in list mode, so you can navigate left/right through the list of content using the d-pad on the remote.

### Media View

Selecting the _Play_ button on the DetailView opens a MediaView for that piece of content.
The MediaView operates in list mode without endcards, so the next video in the list will play immediately.
When the last video in the playlist finishes, the MediaView closes and the DetailView is displayed.

## Custom ButtonBar

Starting from 2.9, SGDEX provides developers with the possibility to build their own layouts for buttonBar component

In this sample, we leverage custom buttonBar support for the standard SGDEX views and populate its content using SGDEX ButtonBar ContentHandler.

### Build the Custom ButtonBar component
The process of building and using a custom ButtonBar is documented here [SGDEX documentation](../../documentation/6-ContentManager_with_Custom_Views_Guide.md).

First, we create a [custom button bar](components/CustomButtonBar/CustomButtonBar.xml) that extends the Group. We then add the fields to be used for the sample.
```
<component name="CustomButtonBar" extends="Group">
    <script type="text/brightscript" uri="CustomButtonBar.brs" />

    <interface>
        <field id="content" type="node" />
        <field id="itemFocused" type="integer" alias="contentButtonBar.itemFocused" />
        <field id="itemSelected" type="integer" alias="contentButtonBar.itemSelected" />
        <field id="alignment" type="string" />
        <field id="overlay" type="bool" />
        <field id="renderOverContent" type="bool" value="true" />
    </interface>
```

### Build the Custom ButtonBar layout

Next, we specify a MarkupGrid child of the custom button bar assigning its id to `contentButtonBar`. This will allow SGDEX to leverage this child component for the button bar content rendering and do proper focus handling behind the scenes.
```
    <MarkupGrid
        id="contentButtonBar"
        drawFocusFeedback="false"
        itemComponentName="ButtonBarItem"
        vertFocusAnimationStyle="floatingFocus"
        numRows= "6"
        numColumns= "1"
        itemSize= "[108, 52]"
        itemSpacing= "[0, 8]"
        rowSpacings= "[0, 0, 0, 0, 100]"
        translation= "[0, 200]" />
```
In the scope of the [custom button bar](components/CustomButtonBar/CustomButtonBar.brs) component we can access the button bar and additional UI bits using `FindNode()` to assign callback functions and build the logic for managing the custom button bar UX.

In the current sample, we use animation to make the button bar shrink smoothly once it loses UI focus and return back to the original size once it gains UI focus. This is implemented by observing the button bar _focusedChild_ change.

###### Copyright (c) 2018-2021 Roku, Inc. All rights reserved.
