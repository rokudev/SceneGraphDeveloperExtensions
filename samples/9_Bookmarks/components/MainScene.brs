' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub Show(args as Object)
    ' details will be load by DetailsHandler content handler
    detailsContent = Utils_AAToContentNode({
        HandlerConfigDetails: {
            name: "DetailsHandler"
    }})

    ShowDetailsView(detailsContent, 0)

    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if

    m.top.signalBeacon("AppLaunchComplete")
end sub

sub Input(args as object)
    ' handle roInput event deep linking
    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if
end sub
