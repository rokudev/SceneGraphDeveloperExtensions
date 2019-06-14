' Copyright (c) 2019 Roku, Inc. All rights reserved.

' This handler is responsible for creating the children of the root node
' each child node represents a row in the TimeGridView
sub GetContent()
    ' make an API call to get the list of channels
    raw = ReadASCIIFile("pkg:/api/1_channels.json")
    json = ParseJSON(raw)

    rootChildren = {
        children: []
    } ' channels array
    for each channel in json
        ' make another API call to get detailed metadata for each channel
        raw = ReadASCIIFile("pkg:/api/" + channel + ".json")
        channelJSON = ParseJSON(raw)

        ' create a node for the channel and set its metadata fields
        channelNode = CreateObject("roSGNode", "ContentNode")
        channelNode.title = channelJSON.channel.call_sign
        if channelJSON.channel.major <> invalid
            channelNode.title += " " + channelJSON.channel.major.ToStr()
        end if
        if channelJSON.channel.minor <> invalid
            channelNode.title += "." + channelJSON.channel.minor.ToStr()
        end if

        ' the ID will be used in the row handler to identify the channel
        channelNode.id = channelJSON.object_id.ToStr()

        ' add a handler config to the channel node that will its children
        channelNode.AddFields({
           HandlerConfigTimeGrid: {
               name: "CHRow"
           }
        })

        rootChildren.children.Push(channelNode)
    end for

    ' update the root node with all the channel nodes as children
    ' so they will appear as rows in the view
    m.top.content.Update(rootChildren)
end sub
