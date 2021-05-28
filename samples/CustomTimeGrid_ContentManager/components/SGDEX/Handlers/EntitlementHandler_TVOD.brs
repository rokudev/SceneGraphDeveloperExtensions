
sub TVOD__Init()
    ' Create channel store object here and use this instance for all operations
    m.channelStore = CreateObject("roChannelStore")

    if m.isNewFlow = true
        ' Getting all products from channelStore
        m.config.catalogProducts = RokuBilling__GetCatalog()

        ' Getting all purchases from channelStore
        m.config.purchases = RokuBilling__GetPurchases()
        
        ' Check if the orderRequest field set via handlerConfigEntitlement
        handlerConfigEntitlement = m.top.content.handlerConfigEntitlement
        if handlerConfigEntitlement <> invalid and handlerConfigEntitlement.orderRequest <> invalid
            m.config.orderRequest = handlerConfigEntitlement.orderRequest
        end if
        
        ' Call ConfigureEntitlements() function to provide ability 
        ' to override or populate orderRequest field
        ConfigureEntitlements(m.config)
    end if
end sub

' Helper function - Initiate the TVOD flow from the validating the orderRequest
' and checks the user's billing status via channelStore.RequestPartnerOrder()
' which is a prerequisite for ConfirmPartnerOrder() when doing transactional purchase
sub TVOD__InitiatePurchase()
    orderRequest = m.config.orderRequest
    if TVOD__IsOrderRequestValid(orderRequest)
        orderInfo = {
            price: orderRequest.price
            priceDisplay: orderRequest.priceDisplay
        }
        
        ' initiate order confirmation from the RokuPay system
        partnerResult = m.channelStore.RequestPartnerOrder(orderInfo, orderRequest.code)
        if partnerResult <> invalid
            ' merge the result AA from RequestPartnerOrder() and orderRequest
            ' to a single AA
            order = {
                orderID: partnerResult.id
            }
            order.Append(orderRequest)
            order.Append(partnerResult)
            if order.status = "Success"
                ' clone the order AA to disable ability for developer to change
                ' any fields there
                orderCopy = {}
                orderCopy.Append(order)
                
                ' check if we need to proceed with the transactional purchase
                ' by calling ConfirmOrder() that developer needs to override in
                ' their entitlement handler
                isConfirmOrder = ConfirmOrder(orderCopy)
                if isConfirmOrder = true
                    ' confirmed, initiate the RokuPay transaction
                    TVOD__ConfirmPartnerOrder(order)
                else
                    ' end TVOD flow, immediately close the view and populate 
                    ' orderResult field with the isSuccess=false
                    order.Append({
                        status : "Failure"
                        errorCode: orderCopy.errorCode
                        errorMessage: orderCopy.errorMessage
                    })
                    TVOD__ProcessOrderResult(order)
                end if
            else
                ' requestPartnerOrder() command failed, end TVOD flow now
                TVOD__ProcessOrderResult(order)
            end if
        end if
    else
        TVOD__ProcessOrderResult(orderRequest)
    end if
end sub

' Helper function - starts purchase for given product
' @param product [AA] product data like {code:"", title:"", contentKey:"", ...}
sub TVOD__ConfirmPartnerOrder(order as Object)
    confirmOrderInfo = {
        title: order.title
        priceDisplay: order.priceDisplay
        price: order.price
        orderID: order.orderID
    }
    confirmResult = m.channelStore.ConfirmPartnerOrder(confirmOrderInfo, order.code)
    if confirmResult <> invalid
        order.Append(confirmResult)
        if confirmResult.status = "Success"
            ' successful purchase, invalidate handler config on the ContentNode
            m.top.content.handlerConfigEntitlement = invalid

            OnPurchaseSuccess({
                purchaseID: order.purchaseID
                contentKey: order.contentKey
            })    
        else
            OnPurchaseFailure({
                errorCode: order.errorCode
                errorMessage: order.errorMessage
            })
        end if
        TVOD__ProcessOrderResult(order)
    end if
end sub

' Helper function to populate orderResult field of the EntitelmentView
' @param orderInfo [AA] the result of TVOD flow
sub TVOD__ProcessOrderResult(orderInfo as Object)
    orderResult = {
        isSuccess: false
    }
    if orderInfo <> invalid and orderInfo.status <> invalid
        if orderInfo.status = "Success"
            orderResult.isSuccess = true
            if orderInfo.purchaseID <> invalid
                orderResult.purchaseID = orderInfo.purchaseID
            end if
            if orderInfo.contentKey <> invalid
                orderResult.contentKey = orderInfo.contentKey
            end if
        else
            if orderInfo.errorCode <> invalid
                orderResult.errorCode = orderInfo.errorCode
            end if
            if orderInfo.errorMessage <> invalid
                orderResult.errorMessage = orderInfo.errorMessage
            end if
        end if
    end if
    m.top.view.orderResult = orderResult
    m.top.view.close = true
end sub

' Helper function - validate a orderRequest to required fields for RequestPartnerOrder()
' @param orderRequest [AA] order data like {code:"", title:"", price:"", priceDisplay:""}
' @return [Boolean] true - all fields were set | false - not
function TVOD__IsOrderRequestValid(orderRequest as Object) as Boolean
    result = false
    
    if orderRequest <> invalid
        if orderRequest.code <> invalid and orderRequest.price <> invalid and orderRequest.priceDisplay <> invalid
            result = true
        else
            ? "SGDEX: orderRequest AA must contain the ""code"", ""price"" and ""priceDisplay"" fields" 
        end if
    else
        ? "SGDEX: you must specify orderRequest AA either in the config within"
        ? "         sub ConfigureEntitlements(config as Object)"
        ? "       or in handlerConfigEntitlement on the ContentNode"
    end if
    
    return result
end function
