' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub GetContent()
    url = CreateObject("roUrlTransfer")
    url.SetUrl("https://devtools.web.roku.com/samples/sample_content.rss")
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    rsp = url.GetToString()

    responseXML = ParseXML(rsp)
    responseXML = responseXML.GetChildElements()
    responseArray = responseXML.GetChildElements()
    rootChildren = {
       children: []
    }
    rowAA = {
        children: []
    }

    itemCount = 0
    rowCount = 0

    for each xmlItem in responseArray
        print "xmItem Name: " + xmlItem.GetName()
        if xmlItem.GetName() = "item"
            itemAA = xmlItem.GetChildElements() 'itemAA contains a single feed <item> element
            if itemAA <> invalid
                item = {}
                for each xmlItem in itemAA
                    if xmlItem.GetName() = "guid"
                        item.id = xmlItem.GetText()
                    end if
                    if xmlItem.GetName() = "media:content"
                        item.url = xmlItem.GetAttributes().url
                        xmlTitle = xmlItem.GetNamedElements("media:title")
                        item.title = xmlTitle.GetText()
                        xmlDescription = xmlItem.GetNamedElements("media:description")
                        item.description = xmlDescription.GetText()
                        item.streamFormat = "mp4"
                        xmlThumbnail = xmlItem.GetNamedElements("media:thumbnail")
                        item.HDPosterUrl = xmlThumbnail.GetAttributes().url
                        itemNode = CreateObject("roSGNode", "ContentNode")
                        itemNode.SetFields(item)

                        itemNode.AddFields({
                            handlerConfigRAF: {
                                name: "HandlerRAF"
                            }
                        })

                        rowAA.children.Push(itemNode)
                    end if
                end for
            end if
            itemCount++
            if (itemCount = 4)
                print "Creating a new row"
                itemCount = 0
                rowCount++
                rowAA.Append({ title: "Row " + stri(rowCount) })
                rootChildren.children.Push(rowAA)
                rowAA = {
                    children: []
                }
            end if
        end if
    end for

    'Insert the last incomplete row if children array is not empty
    if (rowAA.children.Count() > 0)
        rowCount++
        rowAA.Append({ title: "Row " + stri(rowCount) })
        rootChildren.children.Push(rowAA)
    end if
    m.top.content.Update(rootChildren)
    m.top.content.Update({isContentLoaded: true})
end sub

function ParseXML(str As String) As dynamic
    if str = invalid return invalid
    xml = CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
end function
