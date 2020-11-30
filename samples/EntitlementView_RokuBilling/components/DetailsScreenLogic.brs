function ShowDetailsScreen(content, index)
    details = CreateObject("roSGNode", "DetailsView")
    
    m.details = details
    
    details.jumpToItem = index
    details.content = content
    details.isContentList = true
    details.ObserveFieldScoped("itemLoaded", "OnItemLoaded")
    details.ObserveFieldScoped("buttonSelected", "OnButtonSelected")
    details.ObserveFieldScoped("wasShown", "OnDetailsWasShown")

    m.top.ComponentController.callFunc("show", {view: details})

    return details
end function

sub OnDetailsWasShown(event as Object)
    show = event.getData()
    details = event.getRoSGNode()
    ' use EntitlementView to check subscription for reset buttons on DetailsView
    if show and details.buttons <> invalid
        isSubscribed = details.buttons.GetChildCount() > 1
        if not isSubscribed
            itemLoaded = details.itemLoaded
            currentItem = details.currentItem
            if itemLoaded = true and currentItem <> invalid
                CreateCheckHandlerEntitlement(currentItem)
            end if
        end if
    end if
end sub

sub OnItemLoaded(event as Object)
    itemLoaded = event.getData()
    currentItem = event.getRoSGNode().currentItem
    if itemLoaded = true and currentItem <> invalid
        ' use EntitlementView as headless component (no UI) to check subscription
        CreateCheckHandlerEntitlement(currentItem)
    else
        ' reset button title
        m.details.buttons = Utils_ContentList2Node([{title: "Loading..."}])
    end if
end sub

sub OnEntitlementSubscriptionChecked(event)
    buttonsList = []
    isSubscribed = event.GetData()

    if isSubscribed
        buttonsList = [{
            title:"Play", id:"play"
        },{
            title:"Upgrade Downgrade subscribe", id:"upgrade_downgrade"
        }]
    else
        buttonsList.Push({title: "Subscribe to watch", id: "subscribe"})
    end if
    
    m.details.buttons = Utils_ContentList2Node(buttonsList)
end sub

sub OnButtonSelected(event as Object)
    if m.details.currentItem <> invalid
        currentItem = m.details.currentItem.clone(true)
        buttonIndex = event.GetData()
        button = m.details.buttons.GetChild(buttonIndex)
        
        if button.id = "play"
            ' play piece of content
            OpenVideoPlayer(m.details.content, m.details.itemFocused)
        else if button.id = "upgrade_downgrade"
            ' show Entitlement view/flow
            ent = CreateObject("roSGNode","EntitlementView")
            ent.mode = "RokuBilling"
            ent.ObserveFieldScoped("isSubscribed", "OnIsSubscribedToPlay")
            currentItem.Update({
                handlerConfigEntitlement:{
                    name : "HandlerEntitlement"
                }
            },true)
            ent.content = currentItem
            m.top.ComponentController.callFunc("show", {view: ent})
        else if button.id = "subscribe"
            ' cannot play content, show Entitlement view/flow
            ent = CreateObject("roSGNode","EntitlementView")
            ent.mode = "RokuBilling"
            ent.ObserveFieldScoped("isSubscribed", "OnIsSubscribedToPlay")
            currentItem.Update({
                handlerConfigEntitlement:{
                    name : "HandlerEntitlement"
                }
            },true)
            ent.content = currentItem
            m.top.ComponentController.callFunc("show", {view: ent})
        end if
    end if
end sub

sub OnIsSubscribedToPlay(event as Object)
    isSubscribed = event.GetData()
    if isSubscribed
        OpenVideoPlayer(m.details.content, m.details.itemFocused)
    end if
end sub

sub CreateCheckHandlerEntitlement(item as Object)
    ent = CreateObject("roSGNode", "EntitlementView")
    ent.mode = "RokuBilling"
    ent.ObserveFieldScoped("isSubscribed", "OnEntitlementSubscriptionChecked")
    item.Update({
        handlerConfigEntitlement:{
            name : "CheckEntitlementHandler"
        }
    },true)
    ent.content = item
    ent.silentCheckEntitlement = true
end sub