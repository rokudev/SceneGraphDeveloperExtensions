' Copyright (c) 2019 Roku, Inc. All rights reserved.

' This handler is responsible for creating the children of a row node
' each child node represents a program in the row
sub GetContent()
    ' the id was set in the root handler
    id = m.top.content.id

    ' we'll fake the timestamps for demo purposes so that there Is
    ' always content displayed for the current time
    dt = CreateObject("roDateTime")
    now = dt.AsSeconds()
    playStart = now - (now mod 1800) - 3600

    ' make an API call to get the guide data for the channel
    raw = ReadASCIIFile("pkg:/api/3_guide_" + id + ".json")
    json = ParseJSON(raw)

    programNodes = {
        children: []
    }
    for each program in json
        ' create a node for the program and set its metadata fields
        programNode = {}
        if program.title <> invalid and program.title <> ""
            programNode.title = program.title
        else if program.airing_details.show_title <> invalid and program.airing_details.show_title <> ""
            programNode.title = program.airing_details.show_title
        else
            programNode.title = "---"
        end if
        if program.season_number <> invalid and program.episode_number <> invalid
            programNode.description = "S" + program.season_number.ToStr() + " E" + program.episode_number.ToStr()
        end if
        programNode.playStart = playStart
        programNode.playDuration = program.airing_details.duration

        programNodes.children.Push(programNode)

        playstart += programNode.playDuration
    end for

    ' update the row node with all the programs for the channel as children
    ' so they will be displayed in the view
    m.top.content.Update(programNodes)
end sub
