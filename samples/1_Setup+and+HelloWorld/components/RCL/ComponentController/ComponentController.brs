' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.top.screenManager = createObject("roSGNode", "ScreenManager")
    screenStackUI = m.top.findNode("ScreenStack")
    m.top.screenManager.screenStackUI = screenStackUI
    m.top.screenManager.observeField("currentScreen","OnCurrentScreenChange")
    m.top.observeField("allowCloseChannelOnLastView","OnAllowCloseChannel")
    m.top.allowCloseChannelOnLastView = true
end sub

function Show(config as Object)
    if GetInterface(config, "ifAssociativeArray") = invalid then
        ? "Error: Component controller, received wrong config"
        
        return invalid
    end if
    screen = config.screen
    if screen = invalid then screen = config.view 
    contentManager = config.contentManager
    
    data = {}
    
    if screen <> invalid then
        subTypesSupported = { GridView: "" }
        subtype = screen.subtype()
        parentType = screen.parentSubtype(screen.subtype())
        createContentManager = false
        if subtype <> invalid and subTypesSupported[subtype] <> invalid then
            createContentManager = true
        else if parentType <> invalid and subTypesSupported[parentType] <> invalid then
            createContentManager = true
        end if
        
        if createContentManager then
            if contentManager = invalid then contentManager = CreateObject("roSgNode", "ContentManager")
            ' attach this screen to this content manager
            contentManager.Parent = m.top.getparent()
            
            contentManager.callFunc("setView", screen)
            data.contentManager = contentManager
        end if
    end if
    
    m.top.ScreenManager.callFunc("runProcedure", { 
        fn: "addscreen"
        fp: [screen, data]
    })
        
    if contentManager <> invalid then
        contentManager.control = "start"
    end if
    'do other stuff for proper registering and unregistering events 
end function

sub OnCurrentScreenChange()
    m.top.currentView = m.top.screenManager.currentScreen
end sub

sub OnAllowCloseChannel(event as Object)
    allowCloseChannel = event.getData()
    ' need to pass this flag to screen stack; it will set scene.exitChannel to true if no screens left
    m.top.screenManager.allowCloseChannelWhenNoScreens = allowCloseChannel
end sub

function onkeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press AND key = "back"
        handled = closeScreen()
    end if
    
    return handled
end function

' handles closing screen in screen stack
' if no screen left, closes scene and exits channel
function closeScreen() as Boolean
    ' user should receive back button when all screens are closed

    ' save flags locally because user can change it in wasClosed callback
    allowCloseLastViewOnBack = m.top.allowCloseLastViewOnBack
    allowCloseChannelOnLastView = m.top.allowCloseChannelOnLastView

    result = m.top.screenManager.screenCount > 1
    
    ' allowCloseLastViewOnBack is checked here because if it is set to true we need to close the screen even it is last screen in stack
    if result or allowCloseLastViewOnBack
        m.top.ScreenManager.callFunc("runProcedure", { 
            fn: "closeScreen"
            fp: ["", {}]
        })

        ' result is bool if count of screens is 2 or more, so screen in stach is closed and back button successfully handled
        if result then return true

        ' if last screen is closed check if user opens a new one in wasClosed callback, if so, back is handled
        if allowCloseLastViewOnBack and not allowCloseChannelOnLastView
            if m.top.screenManager.screenCount > 0 then return true
        end if
        
        if allowCloseLastViewOnBack then
            return false
        end if
    end if
    return not allowCloseChannelOnLastView
end function
