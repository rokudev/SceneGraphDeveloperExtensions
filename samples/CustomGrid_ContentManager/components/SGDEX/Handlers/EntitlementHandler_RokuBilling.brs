'------------------------------------------------------------------------------
'           Helper functions
'------------------------------------------------------------------------------

' Helper function - initializes variables and objects for Roku Billing mode
sub RokuBilling__Init()
    ' create channel store object here and use this instance for all operations
    m.channelStore = CreateObject("roChannelStore")
    
    ' trial usage flag
    m.hasTrialAlreadyUsed = false
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
        port = CreateObject("roMessagePort")
        m.channelStore.SetMessagePort(port)

        m.channelStore.GetPurchases()
        msg = Wait(0, port)
        if msg.IsRequestSucceeded()
            purchaseList = msg.GetResponse()
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
        end if
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

    port = CreateObject("roMessagePort")
    m.channelStore.SetMessagePort(port)

    m.channelStore.GetCatalog()
    msg = Wait(0, port)
    if msg.IsRequestSucceeded()
        catalogProductList = msg.GetResponse()
        productsByCodeAA = RokuBilling__GetProductsByCodeAA()

        for each catalogProduct in catalogProductList
            ' have such product in the map? also check trial logic
            hasTrial = productsByCodeAA[catalogProduct.code]
            if hasTrial <> invalid and (not hasTrial or not m.hasTrialAlreadyUsed)
                result.Push(catalogProduct)
            end if
        end for
    end if

    return result
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

    m.channelStore.SetOrder([{
        code: product.code
        qty: 1
    }])

    if m.channelStore.DoOrder()
        msg = Wait(0, port)
        if msg.IsRequestSucceeded()
            transactionsList = msg.GetResponse()
            if transactionsList <> invalid and transactionsList.Count() > 0
                OnPurchaseSuccess(transactionsList[0])
                isPurchased = true
            end if
        end if
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
    isSubscribed = RokuBilling__HasActiveSubscription()
    if isSubscribed
        ' subscribed? -> remove handler config
        m.top.content.handlerConfigEntitlement = invalid
    end if
    m.top.view.isSubscribed = isSubscribed
end sub

' Initiates subscription flow
sub RokuBilling__Subscribe()
    if RokuBilling__HasActiveSubscription()
        m.top.content.handlerConfigEntitlement = invalid
        m.top.view.close = true
        m.top.view.isSubscribed = true
    else
        ' use message port for processing Dialog events in the handler's 
        ' scope as async callbacks won't work in this case for FW > 7.6
        port = CreateObject("roMessagePort")
    
        dialog = CreateObject("roSGNode", "ProgressDialog")
        dialog.title = tr("Please wait...")
        m.top.GetScene().dialog = dialog

        allowedProducts = RokuBilling__GetProductsAllowedForPurchase()

        numAllowedProducts = allowedProducts.Count()
        if numAllowedProducts = 0
            dialog = CreateObject("roSGNode", "Dialog")
            dialog.ObserveField("buttonSelected", port)
            dialog.ObserveField("wasClosed", port)
            dialog.SetFields({
                title: tr("Error")
                message: tr("No available subscription products to purchase")
                buttons: [tr("Close")]
            })
            m.top.GetScene().dialog = dialog
            
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
'        else if numAllowedProducts = 1
'            ' only 1 product, proceed with purchase without selection dialog
'            RokuBilling__StartPurchase(allowedProducts[0])
        else
            ' show subscription product selection dialog
            dialog = CreateObject("roSGNode", "Dialog")
            dialog.ObserveField("buttonSelected", port)
            dialog.ObserveField("wasClosed", port)

            buttons = []
            for each product in allowedProducts
                buttons.Push(product.name)
            end for

            dialog.AddFields({
                storage: {allowedProducts: allowedProducts}
            })
            dialog.SetFields({
                title: tr("Select Subscription Product")
                buttons: buttons
            })
            m.top.GetScene().dialog = dialog
            
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
