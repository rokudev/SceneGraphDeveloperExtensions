' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

sub GetContent()
    url = CreateObject("roUrlTransfer")
    url.SetUrl("https://devtools.web.roku.com/samples/sample_content.rss")
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    rsp = url.GetToString()

    responseXML = ParseXML(rsp)
    responseXML = responseXML.GetChildElements()
    responseArray = responseXML.GetChildElements()
    rowAA = {
       children: [{
           title: "Playlist of videos with standard MediaView and endcards"
           children: []
       },{
           title: "Playlist of videos with custom media view and endcards"
           children: []
       }]
    }

    for each xmlItem in responseArray
        'print "xmItem Name: " + xmlItem.GetName()
        if xmlItem.GetName() = "item"
            itemAA = xmlItem.GetChildElements() ' itemAA contains a single feed <item> element
            if itemAA <> invalid
                for each xmlItem in itemAA
                    item = CreateObject("roSGNode", "ContentNode")
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
                        rowAA.children[1].children.Push(item.clone(false))
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
