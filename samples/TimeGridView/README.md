# SGDEX TimeGridView

## TimeGridView

This sample demonstrates using the SGDEX TimeGridView. The TimeGridView is built
for displaying the TimeGrid with robust data and memory management features that can
display hundreds of channels worth of data efficiently on any modern Roku device.

## Data Model

This channel uses the TimeGridView's row-by-row loading model. In this model,
we place a handler config on the root node of our content tree. When that
handler runs, it creates a child node for each row that should be displayed. It also
places a handler config on each of those nodes. When those row level handlers run,
they create a child node for each program that should be displayed on their respective row.

## API

This channel uses a simulated API represented by a collection of static files
bundled into the channel. There are 3 different API calls simulated in this channel.

* An initial call to get a list of channels
* A call for each channel to get more detailed metadata for it (title, callsign, etc)
* A call for each channel to get the list of programs for it

###### Copyright (c) 2019 Roku, Inc. All rights reserved.
