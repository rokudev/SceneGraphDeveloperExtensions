' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub GetContent()
    url = CreateObject("roUrlTransfer")
    url.SetUrl("http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss")
    rsp = url.GetToString()

    responseXML = ParseXML(rsp)
    responseXML = responseXML.GetChildElements()
    responseArray = responseXML.GetChildElements()
    rowAA = {
       children: [{
            title: "Playlist Videos"
            children: []
       }]
    }

    for each xmlItem in responseArray
        'print "xmItem Name: " + xmlItem.GetName()
        if xmlItem.GetName() = "item"
            itemAA = xmlItem.GetChildElements() ' itemAA contains a single feed <item> element
            if itemAA <> invalid
                for each xmlItem in itemAA
                    item = {}
                    if xmlItem.GetName() = "media:content"
                        item.url = xmlItem.GetAttributes().url
                        xmlTitle = xmlItem.GetNamedElements("media:title")
                        item.title = xmlTitle.GetText()
                        xmlDescription = xmlItem.GetNamedElements("media:description")
                        item.description = xmlDescription.GetText()
                        item.streamFormat = "mp4"
                        xmlThumbnail = xmlItem.GetNamedElements("media:thumbnail")
                        item.HDPosterUrl = xmlThumbnail.GetAttributes().url

                        rowAA.children[0].children.Push(item)
                    end if
                end for
            end if
        end if
    end for

    m.top.content.Update(rowAA)
end sub

function ParseXML(str As String) As dynamic
    if str = invalid then return invalid
    xml = CreateObject("roXMLElement")
    if not xml.Parse(str) then return invalid

    return xml
end function
