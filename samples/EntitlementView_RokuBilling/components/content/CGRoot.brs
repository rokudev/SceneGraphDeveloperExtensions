sub GetContent()
' https://image.roku.com/ZGV2ZWxvcGVy/newscaster/feeds/index.xml


    'this is for a sample, usually feed is retrieved from url using roUrlTransfer
    feed = ReadAsciiFile("pkg:/components/content/feed.json")
    if feed.Len() > 0
        json = ParseJson(feed)
        if json <> invalid and json.rows <> invalid and json.rows.Count() > 0
            rootChildren = []
            for each row in json.rows
                if row.items <> invalid
                    children = []

                    for each item in row.items
                        itemNode = CreateObject("roSGNode", "ContentNode")
                        itemNode.SetFields(item)
                        itemNode.AddFields({
                                HandlerConfigVideo : {
                                    name : "CGDetails"
                                    fields : {
                                        param : "123"
                                    }
                                }
                                HandlerConfigDetails : {
                                    name : "CGDetails"
                                    fields : {
                                        param : "123"
                                    }
                                }
                            })
                        children.Push(itemNode)
                    end for

                    rowNode = CreateObject("roSGNode", "ContentNode")
                    rowNode.SetFields({
                        title: row.title
                    })
                    rowNode.AppendChildren(children)

                    rootChildren.Push(rowNode)
                end if
            end for

            m.top.content.AppendChildren(rootChildren)
        end if
    end if
end sub
