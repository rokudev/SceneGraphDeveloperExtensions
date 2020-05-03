' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub Show(args as Object)
    print "Hello World!"
    m.top.signalBeacon("AppLaunchComplete")
end sub
