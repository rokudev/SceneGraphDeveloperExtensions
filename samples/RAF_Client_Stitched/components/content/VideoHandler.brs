' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub GetContent()
    m.top.content.Update({
        url: "http://pmd205604tn.download.theplatform.com.edgesuite.net/Demo_Sub_Account_2/411/535/ED_HD__571970.m3u8"
        length: 600
        streamFormat: "m3u8"
        
        HandlerConfigRAF: {
            name: "HandlerRAF"
            useCSAS: true ' should be true to use Client stitched ads mode
        }
    }, true)
end sub
