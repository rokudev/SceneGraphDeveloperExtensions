' Copyright (c) 2019 Roku, Inc. All rights reserved.

' This is the main entry point to the channel scene.
' This function will be called by SGDEX when channel is ready to be shown.
sub Show(args as Object)
    ' create our TimeGridView
    grid = CreateObject("roSGNode", "TimeGridView")

    ' put a handler config on the root node of the tree
    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
        HandlerConfigTimeGrid: {
            name: "CHRoot"
        }
    })

    ' set content to the view
    grid.content = content

    ' this will trigger job to show this screen
    m.top.ComponentController.CallFunc("show", {
        view: grid
    })
end sub
