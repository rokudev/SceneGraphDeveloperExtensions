' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub ConfigureRAF(adIface)
    ' Detailed RAF docs: https://sdkdocs.roku.com/display/sdkdoc/Integrating+the+Roku+Advertising+Framework#IntegratingtheRokuAdvertisingFramework-setContentLength(lengthasInteger)
    adIface.SetAdURL("https://devtools.web.roku.com/samples/sample.xml")
    adIface.SetDebugOutput(false) ' for debug purpose
    adIface.SetAdPrefs(false)
    adIface.SetTrackingCallback(userCustomCallback) ' if developer want to track RAF events.
end sub

sub userCustomCallback (obj = invalid as Dynamic, eventType = invalid as Dynamic, ctx = invalid as Dynamic)
    'More info : https://developer.roku.com/docs/developer-program/advertising/raf-api.md#settrackingcallbackcallback-as-function-obj-as-object
end sub
