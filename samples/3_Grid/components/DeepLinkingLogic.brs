function IsDeepLinking(args as Object)
    ' check if deep linking args is valid
    return args <> invalid and args.mediaType <> invalid and args.mediaType <> "" and args.contentId <> invalid and args.contentId <> "" 
end function

sub PerformDeepLinking(args as Object)
    ' Implement your deep linking logic. For more details, please see Roku_Recommends sample.
end sub
