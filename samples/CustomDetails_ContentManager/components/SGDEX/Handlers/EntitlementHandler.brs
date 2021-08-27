' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.top.observeField("state", "OnStateChange")
    m.top.functionName = "HandlerFunctionRunner"
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

' Required for "RokuBilling"/"RokuPay_SVOD" and "RokuPay_TVOD" modes.
' Developer should override this subroutine in their component extended from
' the EntitlementHandler to be able to
' - determine user SVOD subscription status
' - define RokuPay products to be displayed/offered to the user for the SVOD flow
' - define transactional order request for the TVOD flow
' @param config [AA]:
' @param config.catalogProducts [Object][Read-Only] in "RokuBilling"/"RokuPay_SVOD" and "RokuPay_TVOD" mode - prepopulated with array of catalog products per roChannelStore.GetCatalog(); otherwise invalid 
' @param config.purchases [Object][Read-Only] in "RokuBilling"/"RokuPay_SVOD" and "RokuPay_TVOD" mode - prepopulated with array of purchases per roChannelStore.GetPurchases(); otherwise invalid
' @param config.orderRequest [String] "RokuPay_TVOD" mode only - order request data prepopulated with the handlerConfigEntitlement.orderRequest value which developer can update in this function
' @param config.orderRequest.code [String] Channel Store product code (ID) to be associated with the purchase
' @param config.orderRequest.price [String] the price to be charged, without currency sign, e.g. "5.99"
' @param config.orderRequest.priceDisplay [String] the price to be displayed in the Roku Pay screen without currency sign, e.g. "5.99"
' @param config.orderRequest.contentKey [String] – optional value corresponding to the item's publisher-specific SKU or other unique identifier to be used for the transaction
' @param config.orderRequest.title (String) – the name to be shown on user's invoices for the purchased item
sub ConfigureEntitlements(config as Object)
    ? "SGDEX: you should implement "
    ? "         sub ConfigureEntitlements(config as Object)"
    ? "     in your "m.top.Subtype()" component"
end sub

' For "RokuBilling" mode only. Allows developer to inject some business logic on 
' purchase success by overriding this subroutine in their component extended from
' EntitlementHandler. Default implementation does nothing
sub OnPurchaseSuccess(transactionData as Object)
end sub

' Allows developer to inject some business logic 
' in case when purchase was failure by overriding this function in their component extended from
' EntitlementHandler. Default implementation does nothing
sub OnPurchaseFailure(errorInfo as Object)
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

' This function should be overridden by developer in order to proceed with the transactional purchase.
' @param orderInfo [AA] contains information about the transactional order requested for processing:
' @param orderInfo.orderID [String] an internal ID of the initiated transaction per Channel Store API
' @param orderInfo.tax [String] cost of tax (if applicable)
' @param orderInfo.total [String] total cost of the transaction
' @param orderInfo.code [String] Channel Store product code (ID) to be associated with the purchase
' @param orderInfo.price [String] the price to be charged, without currency sign, e.g. "5.99"
' @param orderInfo.priceDisplay [String] the price to be displayed in the Roku Pay screen without currency sign, e.g. "5.99"
' @param orderInfo.contentKey [String] optional, the value corresponding to the item's publisher-specific SKU or other unique identifier to be used for the transaction
' @param orderInfo.title [String] the name to be shown on user's invoices for the purchased item
' @return [Boolean] should be true to proceed with the transaction, false otherwise (in this case developer can set orderInfo.errorCode and orderInfo.errorMessage strings to be reflected in EntitlementView.orderResult and OnPurchaseFailure() errorInfo).
function ConfirmOrder(orderInfo as Object) as Boolean
    ? "SGDEX: you should implement "
    ? "         function ConfirmOrder(orderInfo as Object) as Boolean"
    ? "     in your "m.top.Subtype()" component"
    return false
end function

'------------------------------------------------------------------------------
'           Handler functions invoked by EntitlementView
'------------------------------------------------------------------------------

sub HandlerFunctionRunner()
    ' entitlements config params
    m.config = {}

    ' keep mode value casted to a String for further calling
    ' mode-specific internal functions
    m.sMode = m.top.view.mode
    m.isNewFlow = (m.sMode.Len() > 0)
    if m.isNewFlow = false
        ? "SGDEX warning: your ("m.top.view.Subtype()") doesn't specify mode."
        ? "Using fallback flow with getting mode from ConfigureEntitlements config"
        ConfigureEntitlements(m.config)
        m.sMode = Box(m.config.mode).ToStr()
    end if

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
        RokuPay_TVOD: {
            Init: TVOD__Init
            RunEntitlementFlow: TVOD__InitiatePurchase
        }
    }
    
    ' add "RokuPay_SVOD" as a synonym of "RokuBilling" mode
    m.funcAA.RokuPay_SVOD = m.funcAA.RokuBilling

    ' default mode should be "RokuBilling" (if mode = invalid)
    m.funcAA.invalid = m.funcAA.RokuBilling
    ' call mode-specific init function if exists
    CallModeFunc("Init")

    ' call flow start function
    CallModeFunc(m.top.fn)
end sub
