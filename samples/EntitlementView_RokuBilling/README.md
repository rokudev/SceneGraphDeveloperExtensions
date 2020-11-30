# SGDEX Roku Billing Sample: Using on-device upgrade and downgrade with EntitlementView

## Introduction
SGDEX provides developers with [EntitlementView](https://github.com/rokudev/SceneGraphDeveloperExtensions/blob/master/documentation/1-components.md#entitlementview) and [EntitlementHandler](https://github.com/rokudev/SceneGraphDeveloperExtensions/blob/master/documentation/1-components.md#entitlementhandler) for easier handling of RokuPay subscriptions. SGDEX v2.5 adds support for subscription [upgrade/downgrade feature](https://developer.roku.com/docs/developer-program/roku-pay/implementation/on-device-upgrade-downgrade.md) which is currently a cert requirement for subscribed Roku channel apps [requirement](https://developer.roku.com/docs/developer-program/certification/certification.md#2-purchases)

The current sample demonstrates a typical use case of subscribed video content that requires some active RokuPay subscription. The sample offers 2 types of subscriptions - Monthly and Annual - both of which have trial periods.

### The logic is the following:
- There are 2 physical RokuPay products mapped for each subscription type - one with trial period and one without trial, so 4 products overall (monthly, monlty with trial, annual, annual with trial) - to be able to offer non-trial subscription product for users that might have purchased trial in the past
- The sample checks active RokuPay subscription. If there is no subscription, then there is `"Subscribe to watch"` button that leads to subscription purchase. If there is active subscription then there is `"Play"` button that allows to play content back and another button to `upgrade/downgrade subscription`

#### Subsciption purchase:
- If the user has no active subscription and never used trial then the sample offers both Monthly and Annual sub with trial products
- If the user has no active subscription but used trial before then the sample offers both Monthly and Annual subs without trial period

#### Subscription with upgrade/downgrade:
- if user had some active subscription then the sample determines which one is that starting from the higher type (Annual)
- if the current subscription is Annual then the sample offers downgrade to Monthly subscription without trial
- if the current subscription is Monthly then the sample offers upgrade to Annual subscription without trial 
- in both cases, `EntitlementHandler` logic populates `"action"` field in config.displayProducts items

## Preparation
In order to run the sample you as a developer need to perform the following steps:

## Part 1: Configuration ChannelStore side

- Enroll in the [Roku Partner Payouts Program](https://developer.roku.com/docs/developer-program/roku-pay/quickstart/partner-payouts.md)
- Create 4 products trial and non-trial for Monthly sub and trial and non-trial for Annual sub in your Dashboard for more details on how to create products please see [this instruction](https://developer.roku.com/docs/developer-program/roku-pay/quickstart/in-channel-products.md#adding-a-new-product), make sure to that the Cleared for Sale check box is selected
- Create a products group and add the above products there to indicate that these are mutually exclusive, for more details hot to add products to the group please see [this instruction](https://developer.roku.com/docs/developer-program/roku-pay/quickstart/in-channel-products.md#adding-product-groups)
- If the products united into a group you need to replace example product codes with actual codes in the attached test sample in the following files([CheckEntitlementHandler.brs](components/content/CheckEntitlementHandler.brs) and [HandlerEntitlement.brs](components/content/HandlerEntitlement.brs))
- Publish the channel under your dev account and make it designated for [billing testing](https://developer.roku.com/docs/developer-program/roku-pay/testing/billing-testing.md) and create [test user](https://developer.roku.com/docs/developer-program/roku-pay/quickstart/test-users.md) - this will allow using Roku Bililling within sideloaded app
- make sure to assign products to your [published channel](https://developer.roku.com/docs/developer-program/roku-pay/quickstart/in-channel-products.md#product-basics) in your dev dashboard

## Part 2: Requirements for the SGDEX side

In order to use RokuBilling and on-device upgrade and downgrade, you need do all of the following steps:
- Create [EntitlementView](https://github.com/rokudev/SceneGraphDeveloperExtensions/blob/master/documentation/1-components.md#entitlementview) and set `mode` interface to `RokuBilling`

```
    EntitlementView = CreateObject("roSGNode", "EntitlementView")
    EntitlementView.mode = "RokuBilling"
```

After creating EntitelmentView SGDEX provide you the information about existing purchases and all products created for the channel app, 
[EntitlementHandler](https://github.com/rokudev/SceneGraphDeveloperExtensions/blob/master/documentation/1-components.md#entitlementhandler) will populate 2 additional fields of config parameter (AA) passed to ConfigureEntitlements(config as Object) function.

```
    config.purchases - raw list (array) of purchases per roChannelStore.GetPurchases()
    config.catalogProducts - raw list (array) of catalog products per roChannelStore.GetCatalog()
```

- Create an EntitlementHandler according to the way of use

These ways will be able to build proper logic to populate config.displayProducts 
that will define exact list of the products to be used in the flow and displayed to the user 
or build proper logic to populate config.isSubscribed that will define status of subscription for user

### Part 2.1: Creating a EntitlementHandler to check status of subscription

In order to check subscription for user accomplish that, ConfigureEntitlements() function 
support new config.isSubscribed flag that you will need to set to true or false to indicate subscribtion of user.

In the UI/Render scope you need to create EntitlementView and specify a `mode` to `"RokuBilling"`
and start observing `isSubscribed` to handel and create UI logic to process status of subscription based on isSubscribed
```
    ent = CreateObject("roSGNode", "EntitlementView")
    ent.mode = "RokuBilling"
    ent.ObserveFieldScoped("isSubscribed", "OnEntitlementSubscriptionChecked")
```

Then you need to create a EntitlementHandler to handle the subscription validation logic and after that you need populate `content` interface EnttitelmentView
```
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        handlerConfigEntitlement: {
            name : "myCheckEntitlementHandler"
        }
    }, true)
    ent.content = content
```

After that you can populate `silentCheckEntitlement` interface to true and its allow you to handling subscription status without UI output(no dialogs), by default `silentCheckEntitlement` value set to false and it's always block UI and show dialog
```
    ent.silentCheckEntitlement = true
```

Next step, you need to built the logic to determine if user is subscribed. You might use config.purchases and config.catalogProducts prepopulated by SGDEX. In case of `silentCheckEntitlement` you need to populate config.isSubscribed with a boolean value - true or false. True will indicate that user is subscribed (has active subscripition), false will indicate no active subscription. The current sample iterates through config.purchases and checks if there is active (not expired) subscription for any of the RokuPay products that the app operates with and sets config.isSubscribed accordinly.

```
sub ConfigureEntitlements(config as Object)
    for each purchase in config.purchases
        if purchase.expirationDate <> invalid
            nowDate = CreateObject("roDateTime")
            expDate = CreateObject("roDateTime")
            expDate.FromISO8601String(purchase.expirationDate)

            ' check active (not expired) purchases
            if expDate.AsSeconds() > nowDate.AsSeconds()
                if purchase.code = "monthly_product_code" or purchase.code = "monthly_trial_product_code"
                    config.isSubscribed = true
                    exit for
                else if purchase.code = "annual_product_code" or purchase.code = "annual_trial_product_code"         
                    config.isSubscribed = true
                    exit for
                end if
            else
                config.isSubscribed = false
            end if
        end if
    end for
end sub
```

### Part 2.2: Creating an EntitlementHandler for using RokuBilling
In order to use RokuBilling and on-device upgrade or downgrade you need to specify config.displayProducts field in you ConfigureEntitlements(config as Object) function 
that will contain products to be actually displayed to the user as-is.

Products without an action field or with any value other than `upgrade or downgrade` will be treated as a *regular purchase*.

In the UI/Render scope you need to create EntitlementView, specify its `mode` to `"RokuBilling"` and observe `isSubscribed` which would be populated by SGDEX internally after subsciption flow finishes. This `isSubscribed` value will indicate if the flow ended up in successful subsciption purchase or upgrade/downgrade. Observing this field in the scene scope allows to build related UX in the channel app depending on the subscription flow result.  

```
    ent = CreateObject("roSGNode", "EntitlementView")
    ent.mode = "RokuBilling"
    ent.ObserveFieldScoped("isSubscribed", "OnIsSubscribedToPlay")
```

Then you need to create a EntitlementHandler to handle the subscription validation logic and after that you need populate `content` interface EnttitelmentView
```
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        handlerConfigEntitlement: {
            name : "myCheckEntitlementHandler"
        }
    }, true)
    ent.content = content
```

Next step, you need create a logic in ConfigureEntitlement(config as Object) function in HandlerEntitlement implementaion file
to offer a user the ability to upgrade or downgrade subscription or provide ability to use trial or regular purchases.

Before configuration displayProducts you need to check all cases related to trial purchases even expired ones 
or check active purchases and based on this result you can create logic for provide products for user
```
    isActiveMonthly = false 'flag to indicate active monthly purchase
    isActiveAnnual = false 'flag to indicate active annual purchase
    isTrialUsed = false 'flag to indicate trial status

    for each purchase in config.purchases
        if purchase.expirationDate <> invalid
            nowDate = CreateObject("roDateTime")
            expDate = CreateObject("roDateTime")
            expDate.FromISO8601String(purchase.expirationDate)
              
            ' check for trial purchases, even expired ones
            if purchase.code = "monthly_trial_product_code" or purchase.code = "annual_trial_product_code"
                isTrialUsed = true
            end if
              
            ' check active (not expired) purchases
            if expDate.AsSeconds() > nowDate.AsSeconds()
                if purchase.code = "monthly_product_code" or purchase.code = "monthly_trial_product_code"
                    isActiveMonthly = true
                else if purchase.code = "annual_product_code" or purchase.code = "annual_trial_product_code"         
                    isActiveAnnual = true
                end if
            end if
        end if
    end for
```

After checking logic you can handling cases based on results and create cases when user don't have yet any subscriptions 
or user have subscriptions and provide for him action for switching between active subscription
```
    if isActiveMonthly = false and isActiveAnnual = false
        ' no active subs, check if trial has been used
        if isTrialUsed
            ' prompt user with non-trial versions of both products
            config.displayProducts = [
                {name:"Monthly sub", code: "monthly_product_code"}
                {name:"Annual sub", code: "annual_product_code"}
            ]
        else
            ' trial wasn't used, prompt user with trial versions of both products
            config.displayProducts = [
                {name: "Monthly trial", code: "monthly_trial_product_code"}
                {name: "Annual trial",  code: "annual_trial_product_code"}
            ]
        end if
    else
        ' have some active subs
        if isActiveAnnual = true
            config.displayProducts = [
                {name: "Monthly product (downgrade)", code: "monthly_trial_product_code", action: "downgrade"}
            ]
        else 'isActiveMonthly = true
            config.displayProducts = [
                {name: "Annual Product (upgrade)", code: "annual_trial_product_code", action: "upgrade"}
            ]
        end if
    end if
```

Also, there is `OnPurchaseSuccess()` function in the EntitlementHandler that can be overridden by developer to perform additonal API calls or other business logic once subscripiton flow ended successfully. In the current sample this function just prints out RokuPay transaction data.
```
sub OnPurchaseSuccess(transactionData as Object)
    ? "OnPurchaseSuccess"
    ? transactionData
end sub
```
###### Copyright (c) 2020 Roku, Inc. All rights reserved.
