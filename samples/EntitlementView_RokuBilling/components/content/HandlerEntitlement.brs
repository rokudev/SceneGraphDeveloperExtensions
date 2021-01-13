' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' !!! THE PRODUCT CODES USED IN THIS FILE ARE EXAMPLES !!!
' For the sample channel to work, you must update them to match products
' that you set up in your develper account.

sub ConfigureEntitlements(config as Object)
    isActiveMonthly = false
    isActiveAnnual = false
    isTrialUsed = false
      
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
                {name: "Monthly product (downgrade)", code: "monthly_product_code", action: "downgrade"}
            ]
        else 'isActiveMonthly = true
            config.displayProducts = [
                {name: "Annual Product (upgrade)", code: "annual_product_code", action: "upgrade"}
            ]
        end if
    end if
end sub

sub OnPurchaseSuccess(transactionData as Object)
    ? "OnPurchaseSuccess"
    ? transactionData
end sub