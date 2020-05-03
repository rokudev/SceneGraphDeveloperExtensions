' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub GetContent()
    feed = ReadAsciiFile("pkg:/feed/feed.json")
    Sleep(2000) ' to emulate API call

    if feed.Len() > 0
        json = ParseJson(feed)
        if json <> invalid
            contentType = m.top.contentType
            rowAA = {
                title: contentType
                children: []
            }

            for each arrayItem in json[contentType]
                itemNode = CreateObject("roSGNode", "ContentNode")
                itemNode.SetFields({
                    hdPosterUrl: arrayItem.thumbnail
                    Description: arrayItem.shortDescription
                    id: arrayItem.id
                    title: arrayItem.title
                    url: arrayItem.url
                })
                rowAA.children.Push(itemNode)
            end for

            m.top.content.Update({
                children: [rowAA]
            })
        end if
    end if
end sub
