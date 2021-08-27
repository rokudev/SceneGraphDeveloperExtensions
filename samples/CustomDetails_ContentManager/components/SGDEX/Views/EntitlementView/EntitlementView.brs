' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.top.ObserveField("silentCheckEntitlement", "OnSilentCheckEntitlement")
    m.top.ObserveField("silentCheckAuthentication", "OnSilentCheckAuthentication")
    m.top.ObserveField("silentDeAuthenticate", "OnSilentDeAuthenticate")
    m.top.ObserveField("wasShown", "OnWasShown")
end sub

' Helper subroutine to run entitlement handler
' @param name [String] entitlement handler name
' @param functionName [String] handler function to call
sub RunEntitlementHander(name as String, functionName as String)
    handler = GetNodeFromChannel(name)
    if handler <> invalid
        handler.Update({
            content: m.top.content
            view: m.top
            fn: functionName
        }, true)
        handler.control = "RUN"
    end if
end sub

' "silentCheckEntitlement" interface callback,
' initiates entitlement checking in non-UI mode
sub OnSilentCheckEntitlement()
    content = m.top.content
    if content <> invalid
        handlerConfig = content.handlerConfigEntitlement
        if handlerConfig = invalid
            m.top.isSubscribed = true
        else if handlerConfig.name <> invalid
            RunEntitlementHander(handlerConfig.name, "SilentCheckEntitlement")
        end if
    end if
end sub

' "silentCheckAuthentication" interface callback,
' initiates authentication checking in non-UI mode
sub OnSilentCheckAuthentication()
    content = m.top.content
    if content <> invalid
        handlerConfig = content.handlerConfigEntitlement
        if handlerConfig = invalid
            m.top.isAuthenticated = true
        else if handlerConfig.name <> invalid
            RunEntitlementHander(handlerConfig.name, "SilentCheckAuthentication")
        end if
    end if
end sub

' "silentDeAuthenticate" interface callback,
' initiates de-authentication in non-UI mode
sub OnSilentDeAuthenticate()
    content = m.top.content
    if content <> invalid
        handlerConfig = content.handlerConfigEntitlement
        if handlerConfig = invalid
            m.top.isAuthenticated = false
        else if handlerConfig.name <> invalid
            RunEntitlementHander(handlerConfig.name, "SilentDeAuthenticate")
        end if
    end if
end sub


' "wasShown" interface callback, initiates subscription flow with UI
sub OnWasShown()
    content = m.top.content
    if content <> invalid
        handlerConfig = content.handlerConfigEntitlement
        if handlerConfig = invalid
            m.top.close = true
            m.top.isSubscribed = true
        else if handlerConfig.name <> invalid
            RunEntitlementHander(handlerConfig.name, "RunEntitlementFlow")
        end if
    end if
end sub

' Theme support
sub SGDEX_SetTheme(theme as Object)
end sub

sub SGDEX_SetBackgroundTheme(theme as Object)
    if GetInterface(theme.backgroundImageURI, "ifString") <> invalid then
        colorTheme = { backgroundImageURI: { backgroundRectangle: "uri" } }
    else
        colorTheme = { backgroundColor: { backgroundRectangle: "color" } }
    end if
    SGDEX_setThemeFieldstoNode(m, colorTheme, theme)
end Sub

Function SGDEX_GetViewType() as String
    return "entitlementView"
End Function
