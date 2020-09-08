' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' This handler is responsible for creating the children of a row node
' each child node represents a program in the row
sub GetContent()
    ' The id was set in the root handler
    id = m.top.content.id

    ' We'll fake the timestamps for demo purposes so that there is
    ' always content displayed for the current time
    dt = CreateObject("roDateTime")
    now = dt.AsSeconds()
    playStart = now - (now mod 1800) - 3600

    ' Make an API call to get the guide data for the channel
    raw = ReadASCIIFile("pkg:/api/3_guide_" + id + ".json")
    json = ParseJSON(raw)

    programNodes = []
    for each program in json
        ' Create a node for the program and set its metadata fields
        programNode = CreateObject("roSGNode", "ContentNode")
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
        programNodes.push(programNode)

        playstart += programNode.playDuration
    end for

    ' Append all the programs for the channel as children of the row node
    ' So they will be displayed in the view
    m.top.content.AppendChildren(programNodes)
end sub
