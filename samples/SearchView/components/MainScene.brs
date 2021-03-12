' ********** Copyright 2019 Roku Corp. All Rights Reserved. **********

'This is the main entry point to the channel scene.
'This function will be called by library when channel is ready to be shown.
sub Show(args as Object)
    searchView = CreateObject("roSGNode", "SearchView")
    searchView.hintText = "Enter search term"
    ' query field will be changed each time user has typed something
    searchView.ObserveFieldScoped("query", "OnSearchQuery")
    searchView.ObserveFieldScoped("rowItemSelected", "OnSearchItemSelected")

    ' this will trigger job to show this screen
    m.top.ComponentController.CallFunc("show", {
        view: searchView
    })

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

sub OnSearchQuery(event as Object)
    query = event.GetData()
    searchView = event.GetRoSGNode()

    content = CreateObject("roSGNode", "ContentNode")
    if query.Len() > 2 ' perform search if user has typed at least three characters
        content.AddFields({
            HandlerConfigSearch: {
                name: "CHSearch"
                query: query ' pass the query to the content handler
            }
        })
    end if
    ' setting the content with handlerConfigSearch will create
    ' the content handler where search should be performed
    ' setting the clear content node or invalid will clear the grid with results
    searchView.content = content
end sub

sub OnSearchItemSelected(event as Object)
    ? "Item selected = " ; event.GetData()
end sub
