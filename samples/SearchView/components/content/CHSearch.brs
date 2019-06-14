' ********** Copyright 2019 Roku Corp. All Rights Reserved. **********

sub GetContent()
    baseUrl = "https://archive.org/advancedsearch.php?output=json"

    ' create a roUrlTransfer object
    url = CreateObject("roUrlTransfer")
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    ' build a search URL
    searchUrl = baseUrl + "&q=" + url.Escape(m.top.query) ' search query is accessible through handler's interface
    url.SetUrl(searchUrl)

    ' make an API call
    rawReponse = url.GetToString()
    ' convert response to AA
    json = ParseJSON(rawReponse)
    
    response = invalid
    if json <> invalid and json.response <> invalid
        response = json.response
        if response.docs <> invalid and response.docs.Count() > 0
            ' parsing reponse to content items
            rows = {}
            for each item in response.docs
                contentItem = CreateObject("roSGNode", "ContentNode")
                contentItem.SetFields({
                    title: item.title
                    shortDescriptionLine1: item.description
                    hdposterurl: GetPosterUrl(item.identifier)
                })
                if rows[item.mediatype] = invalid then rows[item.mediatype] = []
                rows[item.mediatype].Push(contentItem)
            end for

            ' building rows with specific content items
            rootChildren = {
               children: []
            }
            for each key in rows
                row = {
                    children: []
                }
                row.title = Ucase(key.left(1)) + Lcase(key.Right(key.Len() - 1))
                row.children = rows[key]
                rootChildren.children.Push(row)
            end for

            ' update the root node with rows as children
            ' so they will be displayed in the view
            m.top.content.Update(rootChildren)
        end if
    end if
end sub

function GetPosterUrl(id as String) as String
    return "https://archive.org/services/get-item-image.php?identifier=" + id
end function
