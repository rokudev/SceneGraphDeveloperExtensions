' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

sub GetContent()
    ' get row pagination parameters - offset and pageSize are passed via
    ' content handler interfaces behind the scenes
    offset = m.top.offset
    itemIndex = m.top.pageSize * offset
    query = m.top.query

    ' create a roUrlTransfer object
    url = CreateObject("roUrlTransfer")
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()

    ' Build paginated search url that will be passed
    searchUrl = BuildSearchUrl(m.top.pageSize, itemIndex, query)
    url.SetUrl(searchUrl)

    ' make an API call
    rawReponse = url.GetToString()
    
    ' parsing content items from response
    json = ParseJSON(rawReponse)
    if json <> invalid and json.response <> invalid
        response = json.response
        if response.docs <> invalid and response.docs.Count() > 0
            items = []
            for each item in response.docs
                contentItem = CreateObject("roSGNode", "ContentNode")
                contentItem.Update({
                    title: item.title
                    description: item.description
                    artist: item.creator
                    releaseDate: item.date
                    downloads: item.downloads
                    hdposterurl: BuildPosterUrl(item.identifier)
                }, true)
                items.push(contentItem)
            end for

            ' replace placeholder items in the row (it's referenced by m.top.content)
            ' starting from itemIndex - this will make view display these items
            m.top.content.ReplaceChildren(items, itemIndex)
        end if
    end if
end sub

function BuildPosterUrl(id as String) as String
    ' Building poster image url based on item id
    return "https://archive.org/services/get-item-image.php?identifier=" + id
end function

function BuildSearchUrl(pageSize as Integer, itemIndex as Integer, query as String) as String
    ' Building URL to request content from archive.org search API
    baseUrl = "https://archive.org/advancedsearch.php"

    params = {
        output: "json"
        "fl[]": ""
        q: query
        rows: pageSize.ToStr()
        page: itemIndex.ToStr()
    }

    searchUrl = baseUrl + "?"
    for each key in params.keys()
        searchUrl = searchUrl + key + "=" + params[key] + "&"
    end for

    return searchUrl
end function