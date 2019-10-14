' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub GetContent()
    ? "CHAudioItem"
    m.top.content.update({
        streamFormat : "mp3" ' if the mode field  is not set on MediaView, streamFormat will be used to choose the mode
        url: "http://devtools.web.roku.com/samples/audio/John_Bartmann_-_05_-_Home_At_Last.mp3"
        length: 130 ' this field should be set to see progress bar on MediaView
    })
end sub
