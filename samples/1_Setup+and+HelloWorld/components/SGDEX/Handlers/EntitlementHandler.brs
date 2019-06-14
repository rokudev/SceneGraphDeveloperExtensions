' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.top.observeField("state", "OnStateChange")

    ' get entitlements config params
    m.config = {}
    ConfigureEntitlements(m.config)
    
    ' keep mode value casted to a String for further calling 
    ' mode-specific internal functions
    m.sMode = Box(m.config.mode).ToStr()

    ' build internal functionality for each specific mode (by mode prefix)
    ' to be called as m.funcAA[m.sMode][fname]()
    m.funcAA = {
        RokuBilling: {
            Init: RokuBilling__Init
            SilentCheckEntitlement: RokuBilling__SilentCheckEntitlement
            RunEntitlementFlow: RokuBilling__Subscribe
        }
        UserPass: {
            SilentCheckAuthentication: UserPass__SilentCheckAuthentication
            SilentDeAuthenticate: UserPass__SilentDeAuthenticate
            RunEntitlementFlow: UserPass__Authenticate
        }
    }
    
    ' default mode should be "RokuBilling" (if mode = invalid)
    m.funcAA.invalid = m.funcAA.RokuBilling
    
    ' call mode-specific init function if exists
    CallModeFunc("Init")
end sub

' "state" interface callback
sub OnStateChange(event as Object)
    state = LCase(event.GetData())
    if state = "run"
        ' save itself in a node so task is not destroyed when its reference deleted
        m.dummyNode = createObject("roSGNode", "Node")
        m.dummyNode.appendChild(m.top)
    else if state = "stop" and m.dummyNode <> invalid
        ' clean up to ensure that no leaks happen
        m.dummyNode.removeChild(event.GetRoSGNode())
        m.dummyNode = invalid
    end if
end sub

'------------------------------------------------------------------------------
'           Helper funtions
'------------------------------------------------------------------------------

' Helper function - calls proper mode-specific internal function/sub if exists
' @param fname [String] name of the function to call (without mode prefix)
sub CallModeFunc(fname as String)
    modeFuncAA = m.funcAA[m.sMode]
    if modeFuncAA <> invalid
        fn = modeFuncAA[fname]
        if fn <> invalid then fn()
    end if
end sub

'------------------------------------------------------------------------------
'           To override by end developer
'------------------------------------------------------------------------------

' Allows end developer to configure entitlements.
' Developer should override this subroutine in their
' component extended from EntitlementHandler
' @param config [AA] should contain fields:
' @param config.mode [String] the desired mode: "RokuBilling" (default) or "UserPass" 
' @param config.products [Array] of AAs (only for "RokuBilling" mode): 
' @param config.products[i].code [String] product code in ChannelStore
' @param config.products[i].hasTrial [Boolean] true if product has trial period
sub ConfigureEntitlements(config as Object)
    ? "SGDEX: you should implement "
    ? "         sub ConfigureEntitlements(config as Object)"
    ? "     in your "m.top.Subtype()" component"
end sub

' For "RokuBilling" mode only. Allows end developer to inject some suctom logic on 
' purchase success by overriding this subroutine in their component extended from
' EntitlementHandler. Default implementation does nothing
sub OnPurchaseSuccess(transactionData as Object)
end sub

' This function should be overridden by the developer to validate user 
' authentication state (mode = "UserPass").
' This is the point where the developer can also restore authentication state, 
' e.g. restore data/tokens, renew tokens, re-authenticate user if needed etc.
' Once function finishes, SGDEX library populatesEntitlementView.isAuthenticated 
' interface field with the return value behind the scenes. The developer should 
' observe EntitlementView.isAuthenticated interface in their callback to process 
' authentication check result.
' @return [Boolean] should be true if user is authenticated, false otherwise.
function CheckAuthentication() as Boolean
    ? "SGDEX: you should implement "
    ? "         function CheckAuthentication() as Boolean"
    ? "     in your "m.top.Subtype()" component"
    return false
end function

' This function should be overridden by end developer to implement API calls 
' for user authentication based on username and password entered by user 
' (mode = "UserPass").
' This function is invoked once user has entered username and password 
' in the KeyboardView.
' This function is also the point where the developer can save any data that 
' might be needed to persist the authentication state in the future. This might 
' be the raw username and password or it might be an authentication token and 
' an expiration date. SGDEX does not impose any restrictions on what the data is 
' and how it is stored (registry etc.)
' Once function finishes, SGDEX library populatesEntitlementView.isAuthenticated 
' interface field with the return value behind the scenes. The developer should 
' observe EntitlementView.isAuthenticated interface in their callback processing
' user authentication results.
' @return [Boolean] should be true if authentication was successful, false otherwise.
function Authenticate(username as String, password as String) as Boolean
    ? "SGDEX: you should implement "
    ? "         function Authenticate(username as String, password as String) as Boolean"
    ? "     in your "m.top.Subtype()" component"
    return false
end function

' This function should be overridden by end developer to implement business logic
' (e.g. API calls etc.) related to user de-authentication (mode = "UserPass").
' This is also the point where the developer can remove any persistent data 
' (e.g. roRegistry values) related to authentication state so the user wouldn't
' be authenticated next time they launch the app.
' Once function finishes, SGDEX library populates EntitlementView.isAuthenticated
' interface field with the value indicating user authentication status behind
' the scenes: false in case if user has been de-authenticated and true if not. 
' End developer should observe EntitlementView.isAuthenticated interface in
' their callback processing user status after de-authentication.
' @return [Boolean] should be true if user has been de-authenticated successfully, false otherwise.
function DeAuthenticate() as Boolean
    ? "SGDEX: you should implement "
    ? "         function DeAuthenticate() as Boolean"
    ? "     in your "m.top.Subtype()" component"
    return false
end function

'------------------------------------------------------------------------------
'           Handler functions invoked by EntitlementView
'------------------------------------------------------------------------------

' Initiates silent entitlement checking (no UI)
sub SilentCheckEntitlement()
    CallModeFunc("SilentCheckEntitlement")
end sub

' Initiates silent authentication checking (no UI)
sub SilentCheckAuthentication()
    CallModeFunc("SilentCheckAuthentication")
end sub

' Initiates silent de-authentication (no UI)
sub SilentDeAuthenticate()
    CallModeFunc("SilentDeAuthenticate")
end sub

' Initiates entitlement flow - subscription or authentication, depenging
' on "config.mode" specified (see ConfigureEntitlements)
sub RunEntitlementFlow()
    CallModeFunc("RunEntitlementFlow")
end sub
