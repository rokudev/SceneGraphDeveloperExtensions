' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub ShowCustomView(hdPosterUrl as String)
    m.customView = CreateObject("roSGNode", "custom")
    m.customView.picPath = hdPosterUrl
    m.top.ComponentController.CallFunc("show", {
        view: m.customView
    })
end sub
