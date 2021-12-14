' Copyright (c) 2018-2019 Roku, Inc. All rights reserved.

' This function will be called by library when channel is ready to be shown
sub Init()
    ' Developer should store proper splash in this location as we can't read manifest here
    ' This is to avoid View blinking

    'TODO write proper handling
    'm.top.backgroundURI = "pkg:/images/splash_hd.png"

    m.top.ComponentController = m.top.findNode("ComponentController")
    
    ' initialize default button bar
    m.top.buttonBar = CreateObject("roSGNode", "ButtonBar")
    m.top.buttonBar.visible = false

    m.top.ObserveField("theme", "SceneSetTheme")
end sub

' launch_args interface callback
sub LaunchArgumentsReceived()
    ' This is safe to start channel
    Show(m.top.launch_args)
end sub

' input_args interface callback
sub InputArgumentsReceived()
    Input(m.top.input_args)
end sub

' This function should be overridden
sub Show(args as Object)
    ? "please implement sub show(args) in your code in order to show any View"
end sub

' This function should be overridden
sub Input(args as Object)
    ?"SGDEX: Please implement 'sub Input(args)' in your scene to handle roInputEvent deep linking"
end sub

sub SceneSetTheme(event as Object)
    m.top.actualThemeParameters = event.getData()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    ' if back button is passed here View stack is done with Views operaion
    ' developer can override onKeyEvent to prevent closing channel and show exit dialog for example
    if press and key = "back"
        if m.top.ComponentController.allowCloseChannelOnLastView
            m.top.GetScene().exitChannel = true
        end if
        return true
    end if

    return false
end function

'This is workaround for accessing scope of channel from framework library
'callback for creating objects needed in library
function createObjectOnDemand(value ) as Object
    return CreateObject("roSGNode", value)
end function
