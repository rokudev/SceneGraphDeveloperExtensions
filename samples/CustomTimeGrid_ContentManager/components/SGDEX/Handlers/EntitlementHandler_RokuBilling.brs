'------------------------------------------------------------------------------
'           Helper functions
'------------------------------------------------------------------------------

' Helper function - initializes variables and objects for Roku Billing mode
sub RokuBilling__Init()
    ' create channel store object here and use this instance for all operations
    m.channelStore = CreateObject("roChannelStore")
    
    ' trial usage flag
    m.hasTrialAlreadyUsed = false

    ' flags to be overridden in RokuBilling__GetProductsByCodeAA
    ' - flag indicating that there are only non-trial products configured;
    ' - assuming true by default
    m.hasOnlyNonTrialProducts = true
    ' - flag indicating that there are only trial products configured;
    ' - assuming true by default
    m.hasOnlyTrialProducts = true

    if m.isNewFlow = true
        ' Getting all products from channelStore
        m.catalogProducts = RokuBilling__GetCatalog()
        m.config.catalogProducts = m.catalogProducts

        ' Getting all purchases from channelStore
        m.config.purchases = RokuBilling__GetPurchases()

        ConfigureEntitlements(m.config)
    end if
end sub

' Helper function - constructs AA from array of products mapping them by code
' @return [AA] {someProduct1: (hasTrial), ...} where (hasTrial)=true|false
function RokuBilling__GetProductsByCodeAA() as Object
    if m.productsByCodeAA = invalid
        m.productsByCodeAA = {}

        products = m.config.products
        if products <> invalid
            for each product in products
                if product <> invalid and product.code <> invalid
                    hasTrial = (product.hasTrial <> invalid and product.hasTrial = true)
                    m.productsByCodeAA[product.code] = hasTrial

                    if hasTrial and m.hasOnlyNonTrialProducts
                        ' faced trial product - override the flag
                        m.hasOnlyNonTrialProducts = false
                    else if not hasTrial and m.hasOnlyTrialProducts
                        ' faced non-trial product - override the flag
                        m.hasOnlyTrialProducts = false
                    end if
                end if
            end for
        end if
    end if

    return m.productsByCodeAA
end function

' Helper function - checks if user has active subscription
' @return [Boolean] true - has subscription; false - not
function RokuBilling__HasActiveSubscription() as Boolean
    result = false

    if m.config.products <> invalid
        purchaseList = RokuBilling__GetPurchases()
        productsByCodeAA = RokuBilling__GetProductsByCodeAA()
        for each purchase in purchaseList
            ' have such product in the map?
            if productsByCodeAA[purchase.code] <> invalid
                ' check if user has ever used trial
                if productsByCodeAA[purchase.code] and not m.hasTrialAlreadyUsed
                    m.hasTrialAlreadyUsed = true
                end if

                ' check if purchase hasn't expired yet
                nowDate = CreateObject("roDateTime")
                expirationDate = CreateObject("roDateTime")

                if purchase.expirationDate <> invalid
                    expirationDate.FromISO8601String(purchase.expirationDate)
                end if
                if expirationDate.AsSeconds() >= nowDate.AsSeconds()
                    ' found valid subscription
                    result = true
                    exit for
                end if
            end if
        end for
    else
        ? "SGDEX: you should set config.products inside"
        ? "         sub ConfigureEntitlements(config as Object)"
    end if

    return result
end function

' Helper function - returns array of products allowed for purchase
' @return [Array] like [{code:"", name:"", description:"", cost:"", ...}]
function RokuBilling__GetProductsAllowedForPurchase() as Object
    result = []
    
    if m.config.products <> invalid
        
        catalogProductList = RokuBilling__GetCatalog()
        catalogAA = {}
        for each catalogProduct in catalogProductList
            catalogAA[catalogProduct.code] = catalogProduct
        end for

        ' iterate through the products specified by developer
        ' to keep their original order in the list
        for each product in m.config.products
            if product <> invalid and product.code <> invalid
                ' have this product in the Channel Store catalog?
                catalogProduct = catalogAA[product.code]
                if catalogProduct <> invalid
                    ' check trial logic
                    hasTrial = product.hasTrial
                    if hasTrial <> invalid
                        ' add product only in case it's
                        ' - a trial product and either trial hasn't been used
                        ' or there are only trial products configured;
                        ' - a non-trial product and either trial has been used
                        ' or there are only non-trial products configured
                        if hasTrial and (not m.hasTrialAlreadyUsed or m.hasOnlyTrialProducts) or not hasTrial and (m.hasTrialAlreadyUsed or m.hasOnlyNonTrialProducts)
                            result.Push(catalogProduct)
                        end if
                    end if
                end if
            end if
        end for
    end if

    return result
end function

' Helper function - get all products
function RokuBilling__GetCatalog()
    catalogProductList = []
    port = CreateObject("roMessagePort")
    m.channelStore.SetMessagePort(port)
    
    m.channelStore.GetCatalog()
    msg = Wait(0, port)
    if msg.IsRequestSucceeded()
        ' convert catalog products to AA by product code
        catalogProductList = msg.GetResponse()
    end if

    return catalogProductList
end function

' Helper function - get all purchases list
function RokuBilling__GetPurchases()
    purchaseList = []
    port = CreateObject("roMessagePort")
    m.channelStore.SetMessagePort(port)

    m.channelStore.GetPurchases()
    msg = Wait(0, port)
    if msg.IsRequestSucceeded()
        purchaseList = msg.GetResponse()
    end if

    return purchaseList
end function
      

' Helper function - starts purchase for given product
' @param product [AA] product data like {code:"", name:"", description:"", ...}
sub RokuBilling__StartPurchase(product = m.productToPurchase as Object)
    dialog = CreateObject("roSGNode", "ProgressDialog")
    dialog.title = tr("Please wait...")
    m.top.GetScene().dialog = dialog

    isPurchased = false
    m.productToPurchase = invalid

    port = CreateObject("roMessagePort")
    m.channelStore.SetMessagePort(port)

    order = [{
        code: product.code
        qty: 1
    }]
    orderInfo = invalid

    if m.isNewFlow = true and product.action <> invalid
        actionAA = {
            "upgrade": "Upgrade",
            "downgrade": "Downgrade"
        }
        productAction = Lcase(product.action)
        action = actionAA[productAction]
        if action <> invalid
            orderInfo = {
                action: action
            }
        end if
    end if

    if orderInfo <> invalid
        m.channelStore.SetOrder(order, orderInfo)
    else
        m.channelStore.SetOrder(order)
    end if

    m.channelStore.DoOrder()
    msg = Wait(0, port)
    if msg.IsRequestSucceeded()
        transactionsList = msg.GetResponse()
        if transactionsList <> invalid and transactionsList.Count() > 0
            OnPurchaseSuccess(transactionsList[0])
            isPurchased = true
        end if
    else if msg.isRequestFailed()
        OnPurchaseFailure({
            errorCode: msg.GetStatus()
            errorMessage: msg.GetStatusMessage()    
        })
    end if

    dialog.close = true

    if isPurchased then m.top.content.handlerConfigEntitlement = invalid
    m.top.view.close = true
    m.top.view.isSubscribed = isPurchased
end sub

'------------------------------------------------------------------------------
'           Handler functions invoked by EntitlementView
'------------------------------------------------------------------------------

' Initiates entitlement checking in headless mode
sub RokuBilling__SilentCheckEntitlement()
    if type(m.config.isSubscribed) = "Boolean" or type(m.config.isSubscribed) = "roBoolean"
        ' new flow, developer decides if there is valid subscription
        if m.config.isSubscribed = true
            m.top.content.handlerConfigEntitlement = invalid
        end if
        m.top.view.isSubscribed = m.config.isSubscribed
    else
        ' fallback flow, SGDEX decides
        ?
        ? "SGDEX SilentCheckEntitlement warning: m.config.isSubscribed is not defined in ConfigureEntitlements(), using fallback flow."
        ?
        RokuBilling__FallbackSilentCheckEntitlement()
    end if
end sub

sub RokuBilling__FallbackSilentCheckEntitlement()
    isSubscribed = RokuBilling__HasActiveSubscription()
    if isSubscribed
        ' subscribed? -> remove handler config
        m.top.content.handlerConfigEntitlement = invalid
    end if
    m.top.view.isSubscribed = isSubscribed
end sub

sub RokuBilling__Subscribe()
    if m.isNewFlow = true and m.config.displayProducts <> invalid
        RokuBilling__ActionSubscribe()
    else
        RokuBilling__FallbackSubscribe()
    end if
end sub

sub RokuBilling__ActionSubscribe()
    RokuBilling__CreateProgressDialog()    

    ' use message port for processing Dialog events in the handler's 
    ' scope as async callbacks won't work in this case for FW > 7.6
    port = CreateObject("roMessagePort")

    ' map catalog products by code
    catalogAA = {}
    for each catalogProduct in m.catalogProducts
        catalogAA[catalogProduct.code] = catalogProduct
    end for

    ' use product names per ChannelStore as falback logic 
    ' if names not specified by developer
    for each product in m.config.displayProducts
        if product.name = invalid
            catalogProduct = catalogAA[product.code]
            if catalogProduct <> invalid and catalogProduct.name <> invalid
                product.name = catalogProduct.name
            end if
        end if
    end for

    allowedProducts = m.config.displayProducts

    numAllowedProducts = allowedProducts.Count()
    if numAllowedProducts = 0
        config = {
            buttons: [tr("Close")], 
            title: tr("Error"), 
            message: tr("No available subscription products to purchase")
        }
        RokuBilling__CreateDialog(config, port)
        while true
            msg = Wait(0, port)
            field = msg.Getfield()
            if field = "buttonSelected"
                RokuBilling__OnErrorDialogSelection()
            else if field = "wasClosed"
                RokuBilling__OnErrorDialogWasClosed()
                exit while
            end if     
        end while
    else
        buttons = []
        for each product in allowedProducts
            buttons.Push(product.name)
        end for
        config = {
            buttons: buttons, 
            title: tr("Select Subscription Product"),
            storage: {allowedProducts: allowedProducts}
        }
        ' show subscription product selection dialog
        RokuBilling__CreateDialog(config, port)
        while true
            msg = Wait(0, port)
            field = msg.Getfield()
            if field = "buttonSelected"
                RokuBilling__OnProductDialogSelection(msg)
            else if field = "wasClosed"
                RokuBilling__OnProductDialogWasClosed()
                exit while
            end if     
        end while
    end if
end sub

' Initiates subscription flow
sub RokuBilling__FallbackSubscribe()
    if RokuBilling__HasActiveSubscription()
        m.top.content.handlerConfigEntitlement = invalid
        m.top.view.close = true
        m.top.view.isSubscribed = true
    else
        ' use message port for processing Dialog events in the handler's 
        ' scope as async callbacks won't work in this case for FW > 7.6
        port = CreateObject("roMessagePort")
        RokuBilling__CreateProgressDialog()    

        allowedProducts = RokuBilling__GetProductsAllowedForPurchase()

        numAllowedProducts = allowedProducts.Count()
        if numAllowedProducts = 0
            config = {
                buttons: [tr("Close")], 
                title: tr("Error"), 
                message: tr("No available subscription products to purchase")
            }
            RokuBilling__CreateDialog(config, port)
            ' waiting on msg port instead of async callbacks
            ' for processing Dialog events in the handler's scope
            while true
                msg = Wait(0, port)
                field = msg.Getfield()
                if field = "buttonSelected"
                    RokuBilling__OnErrorDialogSelection()
                else if field = "wasClosed"
                    RokuBilling__OnErrorDialogWasClosed()
                    exit while
                end if     
            end while
        else
            buttons = []
            for each product in allowedProducts
                buttons.Push(product.name)
            end for
            config = {
                buttons: buttons, 
                title: tr("Select Subscription Product") 
                storage: {allowedProducts: allowedProducts}
            }
            ' show subscription product selection dialog
            RokuBilling__CreateDialog(config, port)
            ' waiting on msg port instead of async callbacks
            ' for processing Dialog events in the handler's scope
            while true
                msg = Wait(0, port)
                field = msg.Getfield()
                if field = "buttonSelected"
                    RokuBilling__OnProductDialogSelection(msg)
                else if field = "wasClosed"
                    RokuBilling__OnProductDialogWasClosed()
                    exit while
                end if     
            end while
        end if
    end if
end sub

'------------------------------------------------------------------------------
'           Dialog helper function
'------------------------------------------------------------------------------

sub RokuBilling__CreateProgressDialog()
    dialog = CreateObject("roSGNode", "ProgressDialog")
    dialog.title = tr("Please wait...")
    m.top.GetScene().dialog = dialog
end sub

function RokuBilling__CreateDialog(config as Object, port as Object) as Object
    dialog = CreateObject("roSGNode", "Dialog")
    dialog.ObserveField("buttonSelected", port)
    dialog.ObserveField("wasClosed", port)

    dialog.Update(config, true)
    
    m.top.GetScene().dialog = dialog
    return dialog
end function
'------------------------------------------------------------------------------
'           Dialog callbacks
'------------------------------------------------------------------------------

sub RokuBilling__OnProductDialogSelection(event)
    dialog = m.top.GetScene().dialog
    product = dialog.storage.allowedProducts[event.GetData()]

    m.productToPurchase = product
    dialog.close = true

    RokuBilling__StartPurchase()
end sub

sub RokuBilling__OnProductDialogWasClosed()
    if m.productToPurchase = invalid
        ' user has exited product selection dialog by back button
        m.top.view.close = true
        m.top.view.isSubscribed = false
    end if
end sub

sub RokuBilling__OnErrorDialogSelection()
    m.top.GetScene().dialog.close = true
end sub

sub RokuBilling__OnErrorDialogWasClosed()
    m.top.view.close = true
    m.top.view.isSubscribed = false
end sub
