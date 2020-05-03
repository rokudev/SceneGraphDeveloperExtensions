' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

function ShowSearchView(view as Object)
    view.ObserveField("query", "OnSearchQuery")

    m.top.componentController.CallFunc("show", { view: view })
end function

sub OnSearchQuery(event as Object)
    query = event.GetData()
    searchView = event.GetRoSGNode()

    content = CreateObject("roSGNode", "ContentNode")
    if query.Len() > 2 ' perform search if user has typed at least three characters
        content.AddFields({
            HandlerConfigSearch: {
                name: "SearchHandler"
                query: query ' pass the query to the content handler
            }
        })
    end if
    ' setting the content with handlerConfigSearch will create
    ' the content handler where search should be performed
    ' setting the clear content node or invalid will clear the grid with results
    searchView.content = content
end sub