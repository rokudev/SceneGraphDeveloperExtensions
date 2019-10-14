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

###### Copyright (c) 2019 Roku, Inc. All rights reserved.
