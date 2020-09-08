' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' This handler is responsible for creating the children of the root node
' each child node represents a row in the TimeGridView
sub GetContent()

    ' Make an API call to get the list of channels
    raw = ReadASCIIFile("pkg:/api/1_channels.json")
    json = ParseJSON(raw)

    ' Channels array
    rootChildren = [] 
    for each channel in json
        ' Make another API call to get detailed metadata for each channel
        raw = ReadASCIIFile("pkg:/api/" + channel + ".json")
        channelJSON = ParseJSON(raw)

        ' Create a node for the channel and set its metadata fields
        channelNode = CreateObject("roSGNode", "ContentNode")
        channelNode.title = channelJSON.channel.call_sign
        if channelJSON.channel.major <> invalid
            channelNode.title += " " + channelJSON.channel.major.ToStr()
        end if
        if channelJSON.channel.minor <> invalid
            channelNode.title += "." + channelJSON.channel.minor.ToStr()
        end if

        ' The ID will be used in the row handler to identify the channel
        channelNode.id = channelJSON.object_id.ToStr()

        ' Add a handler config to the channel node that will its children
        channelNode.addFields({
           HandlerConfigTimeGrid: {
               name: "CHRow"
           }
        })

        rootChildren.push(channelNode)
    end for

    ' Append all the channel nodes as children of the root node
    ' So they will appear as rows in the view
    m.top.content.AppendChildren(rootChildren)
end sub
