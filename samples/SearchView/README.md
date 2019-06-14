# SearchView

This sample demonstrates using the SGDEX SearchView.

## Initializing the SearchView

To create and set up the SearchView we should do the following steps:

* Create the SearchView object and set some of its fileds, the list of all fields and theme attributes can be found TBD
```
searchView = CreateObject("roSGNode", "SearchView")
searchView.hintText = "Enter search term"
```

* Set up observers. Observer to the 'query' field is needed to perform search. The 'query' field will be changed every time when user has typed something. In observer to this field we should implement logic related to creation of content node with content handler config as described in [section below](#performing-the-search).
```
searchView.ObserveFieldScoped("query", "OnSearchQuery")
searchView.ObserveFieldScoped("rowItemSelected", "OnSearchItemSelected")
```

* Add view to screen stack by calling show function
```
m.top.ComponentController.CallFunc("show", {
    view: searchView
})
```

## Performing the search

Inside the callback to query field change we should create the content node with HandlerConfigSearch field and set it to the content field of SearchView to trigger creation of content handler. HandlerConfigSearch should contain name of content handler and query typed by user. Setting empty content or invalid will clear the grid with serach results.

It should look like this:

```
sub OnSearchQuery(event as Object)
    query = event.GetData()
    searchView = event.GetRoSGNode()

    content = CreateObject("roSGNode", "ContentNode")
    if query.Len() > 2 ' perform search if user has typed at least three characters
        content.AddFields({
            HandlerConfigSearch: {
                name: "CGRoot"
                query: query ' pass the query to the content handler
            }
        })
    end if
    searchView.content = content
end sub
```

Inside the content handler we should make an API call and parse response to the appropriate tree of content nodes. Note, SearchView supports all loading models that GridView does and structure of content is the same as for GridView.

```
url = CreateObject("roUrlTransfer")
url.SetCertificatesFile("common:/certs/ca-bundle.crt")
url.InitClientCertificates()
searchUrl = baseUrl + "&q=" + m.top.query ' search query is accessible through handler's interface
url.SetUrl(searchUrl)
```

Once we have parsed the API response and built a tree of content nodes, we should update the content node associated with your Content Handler with the AA of rows as children in the same maner as for grid view:

```
m.top.content.Update(rootChildren)
```

If the search had no results then we do not need to update the content node and do not need to change any its fields. If content handler was executed and content wasn't changed SearchView will show "no results" label.


###### Copyright (c) 2019 Roku, Inc. All rights reserved.
