
sub ConfigureEntitlements(config as Object)
    for each purchase in config.purchases
        if purchase.expirationDate <> invalid
            nowDate = CreateObject("roDateTime")
            expDate = CreateObject("roDateTime")
            expDate.FromISO8601String(purchase.expirationDate)

            ' check active (not expired) purchases
            if expDate.AsSeconds() > nowDate.AsSeconds()
                ' FIXME: please, replace this codes to created codes in the Developer Dashboard
                if purchase.code = "monthly_product_code" or purchase.code = "monthly_trial_product_code"
                    config.isSubscribed = true
                    exit for
                ' FIXME: please, replace this codes to created codes in the Developer Dashboard
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