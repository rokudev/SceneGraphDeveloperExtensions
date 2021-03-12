' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

' This is the main entry point to the channel scene.
' This function will be called by library when channel is ready to be shown.
sub Show(args as Object)
    m.paragraphView = CreateObject("roSGNode", "paragraphView")
    content = CreateObject("roSGNode", "ContentNode")

    content.AddFields({
        HandlerConfigParagraph: {
            name: "CHRoot"
        }
    })

    m.paragraphView.content = content

    m.paragraphView.theme = {
        textColor: "0x22FF22"
        paragraphColor: "0xFF22FF"
        headerColor: "0x22FFFF"
        linkingCodeColor: "0xFFFF22"
        buttonsFocusedColor: "0x000000"
        OverhangShowOptions: false
    }
    
    m.paragraphView.buttons = GetButtons() ' to add buttons to view we should set 'buttons' interface

    m.paragraphView.ObserveField("buttonFocused", "OnButtonFocused")
    m.paragraphView.ObserveField("buttonSelected", "OnButtonSelected")

    m.top.componentController.CallFunc("show", {
        view: m.paragraphView
    })

    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if

    m.top.signalBeacon("AppLaunchComplete")
end sub

sub Input(args as object)
    ' handle roInput event deep linking
    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if
end sub


' function: GetButtons()
' @Description: create node with button, which should reload linking code, as child
' @Return as Object: buttons node
function GetButtons() as Object
    buttons = CreateObject("roSGNode", "ContentNode")
    buttons.Update({
        children: [{
            title: "Reload linking code"
            id: "codeButton"
        }]
    })
    return buttons
end function

' function: OnButtonFocused()
' @Description: actions to perform when button was focused
sub OnButtonFocused()
    ? "OnButtonFocused"
end sub

' function: OnButtonSelected()
' @Description: reload linking code when appropriate button was selected
sub OnButtonSelected(event as Object)
    ? "OnButtonSelected"
    buttonIndex = event.GetData()
    button = m.paragraphView.buttons.GetChild(buttonIndex)
    if button.id = "codeButton"
        ' You can reset content with config to trigger 
        ' content handler for fetching new linking code
        ' the entire screen will be reloaded in such case
        ' content = CreateObject("roSGNode", "ContentNode")
        ' content.AddFields({
        '     HandlerConfigParagraph: {
        '         name: "CHRoot"
        '     }
        ' })
        ' m.paragraphView.content = content
        ' Or you can fetch new linking code by your own 
        ' and just set it to the appropriate content node
        code = (1000 + Rnd(8999)).ToStr() ' create a new random 4-digit number for linking code
        content = m.paragraphView.content.Clone(true) ' create the copy of content to reset paragraphView content
        linkingCodeIndex = content.GetChildCount() - 1 ' linking code is the last child in our sample
        content.GetChild(linkingCodeIndex).text = code ' set generated code to created content node
        m.paragraphView.content = content ' set new content with new linking code
    end if
end sub
