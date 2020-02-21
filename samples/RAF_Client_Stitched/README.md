# SGDEX Guide: RAF Client stitched

## Part 1: Add logic for RAF

Take a look to the file VideoHandler.brs in the components/content folder.

Also you need to update content with HandlerConfigRAF to provide information about RAF to Content Handler and set *useCSAS* field to true to use Client stitching mode.

```
HandlerConfigRAF :{
        name :"HandlerRAF"
        useCSAS : true
    }
```

Now you should set up RAF configuration using ConfigureRAF function in HandlerRAF.brs using provided RAF interface named *adIFace*.

## Part 2: Providing content

Content should contain *LENGTH* field, with duration of playable asset, otherwise content playback won't start.

```
sub GetContent()
    m.top.content.Update({
        url:"http://pmd205604tn.download.theplatform.com.edgesuite.net/Demo_Sub_Account_2/411/535/ED_HD__571970.m3u8"
        length : 600
        streamFormat : "hls"
        HDPosterURL : "pkg:/images/icon_focus_hd.png"

        HandlerConfigRAF :{
            name :"HandlerRAF"
            useCSAS : true
        }
    },true)
end sub
```

## Part 3: Observing RAF playback fields changes

Also you can observe fields change of RAF/content playback by adding callback tracker function with signature as described above:

```
sub userCustomCallback (obj = invalid as Dynamic, eventType = invalid as Dynamic, ctx = invalid as Dynamic)
    ? "[HandlerRAF] Field change received"
end sub
```
and adding it to adIface using propriate method:

```
adIface.SetTrackingCallback(userCustomCallback)
```
where *userCustomCallback* is name of your tracker function.

For more info about Roku Advertisement Framework see SDK Docs https://developer.roku.com/en-gb/docs/developer-program/advertising/integrating-roku-advertising-framework.md

###### Copyright (c) 2020 Roku, Inc. All rights reserved.
