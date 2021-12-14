# SGDEX Components:  
* [GridView](#gridview)  
* [ParagraphView](#paragraphview)  
* [EntitlementView](#entitlementview)  
* [SearchView](#searchview)  
* [DetailsView](#detailsview)  
* [TimeGridView](#timegridview)  
* [MediaView](#mediaview)  
* [SlideShowView](#slideshowview)  
* [CategoryListView](#categorylistview)  
* [SGDEXComponent](#sgdexcomponent)  
* [ButtonBar](#buttonbar)  
* [ContentHandler](#contenthandler)  
* [RAFHandler](#rafhandler)  
* [EntitlementHandler](#entitlementhandler)  
* [ComponentController](#componentcontroller)  
* [BaseScene](#basescene)

____

## <a id="gridview"></a>GridView
### <a id="gridview#extends"></a>Extends: [SGDEXComponent](#sgdexcomponent)
### <a id="gridview#description"></a>Description
Grid view represents SGDEX grid that is responsible for:  
- content loading  
- lazy loading of rows and item in row  
- loading pages of content  
- lazy loading rows when user is not navigating

### <a id="gridview#interface"></a>Interface
#### <a id="gridview#fields"></a>Fields
  
* <a id="gridview#fields#rowitemfocused"></a>**rowItemFocused** (vector2d)
    * Updated when focused item changes  
Value is an array containing the index of the row and item that were focused  
  
* <a id="gridview#fields#rowitemselected"></a>**rowItemSelected** (vector2d)
    * Updated when an item is selected  
Value is an array containing the index of the row and item that were selected  
  
* <a id="gridview#fields#jumptorowitem"></a>**jumpToRowItem** (vector2d)
    * Set grid focus to specified item  
Value is an array containing the index of the row and item that should be focused  
This field must be set after setting the content field.  
  
* <a id="gridview#fields#jumptorow"></a>**jumpToRow** (integer)
    * Set grid focus to specified row  
Value is an integer index of the row that should be focused  
This field must be set after setting the content field.  
  
* <a id="gridview#fields#rowpostershapes"></a>**rowPosterShapes** (stringarray)
    * Interface to support different poster shapes for grid rows.  
Value is an array of strings, which set row poster shapes.  
If the array contains fewer elements than the number of rows, then the shape of rest rows will be set to posterShape field 	or to the last value in the array.  
  
* <a id="gridview#fields#currfocusrow"></a>**currFocusRow** (float)
    * The value is a floating point value where the integer part represents the row that overlaps yFocusTOp and the fractional part represents the percentage of the item that overlaps the fixed focus position.  
    * Read Only  
* <a id="gridview#fields#showmetadata"></a>**showMetadata** (boolean)
    * Default value: true
    * Controls whether the view displays metadata for the focused item above the grid  
  
* <a id="gridview#fields#wrap"></a>**wrap** (boolean)
    * Default value: false
    * Controls the items wrap from bottom to top  
  
* <a id="gridview#fields#theme"></a>**theme** (assocarray)
    * Controls the color of visual elements  
	* Possible values  
     * textColor - sets the color of all text elements in the view
     * focusRingColor - set color of focus ring
     * focusFootprintColor - set color for focus ring when unfocused
     * rowLabelColor - sets color for row title
     * itemTextColorLine1 - set color for first row in short description
     * itemTextColorLine2 - set color for second row in short description
     * itemTextBackgroundColor - set a background color for the short description
     * itemBackgroundColor - set color for background rectangle under the poster
     * shortDescriptionLine1Align - set horizontal alignment for short description line 1
     * shortDescriptionLine2Align - set horizontal alignment for short description line 2
     * titleColor - sets color of title
     * descriptionColor - sets color of description text
     * descriptionmaxWidth - sets max width for description
     * descriptionMaxLines - sets max lines for description
     * wrapDividerBitmapUri - sets bitmap for separator between last and first line, usually 9-patch image
     * wrapDividerBitmapBlendColor - set lend the graphic image specified by wrapDivider
     * wrapDividerHeight - sets the height of the divider
     * wrapDividerWidth - sets the width of the divider
     * wrapDividerOffset - sets field that allows the position of the wrap divider to be adjusted relative to its default position
  
* <a id="gridview#fields#style"></a>**style** (string)
    * Styles are used to tell what grid UI will be used  
	* Possible values  
     * standard - This is default grid style
     * hero - This style will display larger posters on the top row of the grid
     * zoom - This style will enable an animated zoom effect when a row gains focus
  
* <a id="gridview#fields#postershape"></a>**posterShape** (string)
    * Controls the aspect ratio of the posters on the grid  
	* Possible values  
     * 16x9
     * portrait
     * 4x3
     * square
  
* <a id="gridview#fields#content"></a>**content** (node)
    * Controls how SGDEX will load the content for the view  


### <a id="gridview#sample"></a>Sample of usage:
    grid = CreateObject("roSGNode", "GridView")
    grid.setFields({
        style: "standard"
        posterShape: "16x9"
    })
    content = CreateObject("roSGNode", "ContentNode")
    content.addfields({
        HandlerConfigGrid: {
            name: "CHRoot"
        }
    })
    grid.content = content

    'this will trigger job to show this View
    m.top.ComponentController.callFunc("show", {
        view: grid
    })



    ' Content metadata field that can be used:

    root = {

        children:[{
            title: "Row title"

            children: [{

                title: "title that will be shown on upper details section"
                description: "Description that will be shown on upper details section"
                hdPosterUrl: "Poster URL that should be shown on grid item"

                releaseDate: "Release date string"
                StarRating: "star rating integer between 0 and 100"

                _gridItemMetaData: "fields that are used on grid"

                shortDescriptionLine1: "first row that will be displayed on grid"
                shortDescriptionLine2: "second row that will be displayed on grid"


                _forShowing_bookmarks_on_grid: "Add these fields to show bookmarks on grid item"
                length: "length of video"
                bookmarkposition: "actual bookmark position"

                _note: "tels if this bar should be hidden, default = true"
                hideItemDurationBar: false

            }]
        }]
    }

    ' If you have to make API call to get list of rows set content like this:

        content = CreateObject("roSGNode", "ContentNode")
        content.addfields({
            HandlerConfigGrid: {
                name: "CHRoot"
            }
        })
        grid.content = content

    ' Where CHRoot is a ContentHandler that is responsible for getting rows for grid

    ' IF you know the structure of your grid but need to load content to rows you can do:

        content = CreateObject("roSGNode", "ContentNode")

        row = CreateObject("roSGNode", "ContentNode")
        row.title = "first row"
        row.addfields({
            HandlerConfigGrid: {
                name: "ContentHandlerForRows"
                fields : {
                    myField1 : "value I need to pass to content handler"
                }
            }
        })
        grid.content = content

    ' Where
    '    1) "ContentHandlerForRows" is content handler that will be called to get content for provided row.
    '    2) fields is AA of values that will be set to ContentHandler so you can pass additional data to ContentHandler
    '    Note. that passing row itself or grid via fields might cause memory leaks

    ' You can set row ContentHandler even when parsing content in "CHRoot", so it will be called when data for that row is needed


___

## <a id="paragraphview"></a>ParagraphView
### <a id="paragraphview#extends"></a>Extends: [SGDEXComponent](#sgdexcomponent)
### <a id="paragraphview#description"></a>Description


### <a id="paragraphview#interface"></a>Interface
#### <a id="paragraphview#fields"></a>Fields
  
* <a id="paragraphview#fields#buttons"></a>**buttons** (node)
    * Content node for buttons node. Has childrens with id and title that will be shown on View.  
  
* <a id="paragraphview#fields#buttonfocused"></a>**buttonFocused** (integer)
    * Tells what button is focused  
    * Read Only  
* <a id="paragraphview#fields#buttonselected"></a>**buttonSelected** (integer)
    * Is set when button is selected by user. Should be observed in channel.  
Can be used for showing next View or start playback or so.  
    * Read Only  
* <a id="paragraphview#fields#jumptobutton"></a>**jumpToButton** (integer)
    * Interface for setting focused button  
    * Write Only  
* <a id="paragraphview#fields#theme"></a>**theme** (assocarray)
    * Controls the color of visual elements  
	* Possible values  
     * textColor - sets the color of all text elements in the view
     * paragraphColor - specify the color of text with type paragraph
     * headerColor - specify the color of text with type header
     * linkingCodeColor - specify the color of text with type linkingCode
     * buttonsFocusedColor - set the color of focused buttons
     * buttonsUnFocusedColor - set the color of unfucused buttons
     * buttonsFocusRingColor - set the color of button focuse ring
  
* <a id="paragraphview#fields#updatetheme"></a>**updateTheme** (assocarray)
    * updateTheme is used to update view specific theme fields  
Usage is same as [theme](#sgdexcomponent) field but here you should only set field that you want to update  
If you want global updates use [BaseScene updateTheme](#basescene)  
  
* <a id="paragraphview#fields#content"></a>**content** (node)
    * Contains content to display on the ParagraphView or HandlerConfigParagraph  


___

## <a id="entitlementview"></a>EntitlementView
### <a id="entitlementview#extends"></a>Extends: [SGDEXComponent](#sgdexcomponent)
### <a id="entitlementview#description"></a>Description
EntitlementView provides developers with easier way of handling entitlements in their apps.  
EntitlementView can work in one of the modes defined by EntitlementView.mode:  
- Roku Pay subscription check/purchase/upgrade/downgrade (mode = "RokuPay_SVOD")  
- Roku Pay transactional purchase (mode = "RokuPay_TVOD")  
- username/password authentication handling/check (mode = "UserPass")  
EntitlementView.mode should be specifically set by developer.  
Developer is able to implement their entitlement related business logic in EntitlementHandler.  
The handler is specified by handlerConfigEntitlement field of the content node assigned to the view.  
"RokuPay_SVOD" mode supports not only regular Roku Pay purchases but also [on-device upgrade/downgrade](https://developer.roku.com/docs/developer-program/roku-pay/implementation/on-device-upgrade-downgrade.md).  
Please see EntitlementHandler documentation for more details.

### <a id="entitlementview#interface"></a>Interface
#### <a id="entitlementview#fields"></a>Fields
  
* <a id="entitlementview#fields#issubscribed"></a>**isSubscribed** (bool)
    * Default value: false
    * [ObserveOnly] sets to true|false and shows if developer is subscribed after:  
1) checking via silentCheckEntitlement=true (see below)  
2) exitting from subscription flow initiated by adding view to View stack  
  
* <a id="entitlementview#fields#silentcheckentitlement"></a>**silentCheckEntitlement** (bool)
    * Default value: false
    * initiates silent entitlement checking (no UI)  
    * Write Only  
* <a id="entitlementview#fields#isauthenticated"></a>**isAuthenticated** (bool)
    * Default value: false
    * [ObserveOnly] sets to true|false and shows if developer is authenticated after:  
1) checking via silentCheckAuthentication=true (see below)  
2) exitting from authentication flow initiated by adding view to View stack  
  
* <a id="entitlementview#fields#orderresult"></a>**orderResult** (assocarray)
    * AA indicating the result of the "RokuPay_TVOD" flow, contains the following fields:   
- isSuccess (Boolean) – indicates whether the flow ended with a successful purchase transaction:  
true – successful purchase.  
false – an error occurred during the flow.  
- purchaseID – only if isSuccess=true, contains transaction ID (String); otherwise will be Invalid  
- contentKey – only if isSuccess=true, can optionally contain contentKey value specified by developer; otherwise invalid  
- errorCode – only if isSuccess=false, can optionally contain code of the error (String); otherwise Invalid  
- errorMessage – only if isSuccess=false, can optionally contain error message (String); otherwise Invalid  
  
* <a id="entitlementview#fields#prepopulateemail"></a>**prepopulateEmail** (bool)
    * Default value: false
    * a boolean telling SGDEX whether it should prompt the user to share their  
Roku account email address and use that value to pre-populate the KeyboardView.  
    * Write Only  
* <a id="entitlementview#fields#silentcheckauthentication"></a>**silentCheckAuthentication** (bool)
    * Default value: false
    * initiates silent authentication checking (no UI)  
    * Write Only  
* <a id="entitlementview#fields#silentdeauthenticate"></a>**silentDeAuthenticate** (bool)
    * Default value: false
    * initiates silent de-authentication (no UI)  
    * Write Only  
* <a id="entitlementview#fields#username"></a>**username** (string)
    * a string field which contains username. This field used in case of  
custom UI for collecting the credentials.  
  
* <a id="entitlementview#fields#password"></a>**password** (string)
    * a string field which contains user password. This field used in case of  
custom UI for collecting the credentials.  
  
* <a id="entitlementview#fields#mode"></a>**mode** (string)
    * a string field to specify the entitlement mode. Supported values are:  
- "RokuPay_SVOD" - Roku Pay subscription check/purchase/update/downgrade;  
- "RokuPay_TVOD" - Roku Pay transactional purchase (TVOD);  
- "UserPass" - user/password based sign-in/sign-out/auth check;  
- "RokuBilling" (deprecated) - same as "RokuPay_SVOD"  
    * Write Only

### <a id="entitlementview#sample"></a>Sample of usage:
    ' ====== Use case 1: silent Roku Pay subscription check ======

    ' ... Scene scope:

    ' In order to do silent subscription check, you need to:
    ' - create the view
    ' - specify "RokuPay_SVOD" mode
    ' - observe its isSubscribed interface that will be populated with subscription check result
    ' - assign content node with the handler config
    ' - trigger silentCheckEntitlement without showing the view
    ent = CreateObject("roSGNode", "EntitlementView")
    ent.mode = "RokuPay_SVOD"
    ent.ObserveField("isSubscribed", "OnIsSubscriptionChecked")
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        handlerConfigEntitlement: {
            name: "mySubscriptionCheckHandler"
        }
    }, true)
    ent.content = content
    ent.silentCheckEntitlement = true

    ' ... mySubscriptionCheckHandler scope:

    sub ConfigureEntitlements(config as Object)
        ' Here you should implement the business logic to check subsciption status.
        '
        ' You may use config.purchases and config.catalogProducts that will be
        ' prepopulated by SGDEX per Roku Channel Store data for your channel.
        '
        ' You need to set config.isSubscribed to true or false in order to indicate
        ' whether user is subscribed or not.
    end sub

    ' ====== Use case 2: Roku Pay subscription flow ======

    ' ... Scene scope:

    ' In order to initiate Roku Pay subscription flow, you need to:
    ' - create the view
    ' - specify "RokuPay_SVOD" mode
    ' - observe its isSubscribed interface that will be populated with subscription flow result
    ' - assign content node with the handler config
    ' - show the view
    ent = CreateObject("roSGNode", "EntitlementView")
    ent.mode = "RokuPay_SVOD"
    ent.ObserveField("isSubscribed", "OnIsSubscribed")
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        handlerConfigEntitlement: {
            name: "mySubscriptionHandler"
        }
    }, true)
    ent.content = content
    m.top.ComponentController.callFunc("show", {view: ent})

    ' ... mySubscriptionHandler scope:

    sub ConfigureEntitlements(config as Object)
        ' Here you should implement the business logic to determine which subscription
        ' products to show to the user.

        ' You may use config.purchases and config.catalogProducts that will be
        ' prepopulated by SGDEX per Roku Channel Store data for your channel.

        ' You need to populate config.displayProducts with the list of products
        ' to be displayed to the user and be available for selection.

        ' Each item in config.displayProducts should be an AA containing
        ' product _code_ per Channel Store data and, optionally, _name_ and _action_,
        ' for instance:

        config.displayProducts = [
            ' a subscription purchase product (no action field)
            {name: "Subscription 1", code: "mytestsub1"},

            ' a subscription upgrade product, it should belong to a product group
            ' configured in the Roku Developer dashboard
            {name: "Subscription 2 (upgrade)", code: "mytestsub2", action: "upgrade"},

            ' a subscription downgrade product, it should belong to a product group
            ' configured in the Roku Developer dashboard
            {name: "Subscription 3 (downgrade)", code: "mytestsub3", action: "downgrade"}
        ]
    end sub

    ' ====== Use case 3: silent authentication check ======

    ' ... Scene scope:

    ' In order to do silent authentication check, you need to:
    ' - create the view
    ' - specify "UserPass" mode
    ' - observe its isAuthenticated interface that will be populated with auth check result
    ' - assign content node with the handler config
    ' - trigger silentCheckAuthentication without showing the view
    ent = CreateObject("roSGNode", "EntitlementView")
    ent.mode = "UserPass"
    ent.ObserveField("isAuthenticated", "OnIsAuthChecked")
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        handlerConfigEntitlement: {
            name: "myAuthHandler"
        }
    }, true)
    ent.content = content
    ent.silentCheckAuthentication = true

    ' ... myAuthHandler scope:

    function CheckAuthentication() as Boolean
        ' Here you should implement the business logic to validate user auth status
        ' and return true if user is authenticated, false if not
    end function

    ' ====== Use case 4: silent de-authentication ======

    ' ... Scene scope:

    ' In order to do silent de-authentication, you need to:
    ' - create the view
    ' - specify "UserPass" mode
    ' - observe its isAuthenticated interface that will be populated with auth status result
    ' - assign content node with the handler config
    ' - trigger silentDeAuthenticate without showing the view
    ent = CreateObject("roSGNode", "EntitlementView")
    ent.mode = "UserPass"
    ent.ObserveField("isAuthenticated", "OnIsAuth")
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        handlerConfigEntitlement: {
            name: "myAuthHandler"
        }
    }, true)
    ent.content = content
    ent.silentDeAuthenticate = true

    ' ... myAuthHandler scope:

    function DeAuthenticate() as Boolean
        ' Here you should implement the business logic to de-authenticate user
        ' (API calls etc) and return result of the operation:
        ' - true if successfully de-authenticated
        ' - false if not de-authenticated
        ' EntitlementView.isAuthenticated will be populated with the value opposite to
        ' this return value
    end function

    ' ====== Use case 5: user/password authentication flow ======

    ' ... Scene scope:

    ' In order to initiate user/password authentication flow, you need to:
    ' - create the view
    ' - specify "UserPass" mode
    ' - observe its isAuthenticated interface that will be populated with auth flow result
    ' - assign content node with the handler config
    ' - show the view
    ent = CreateObject("roSGNode", "EntitlementView")
    ent.mode = "UserPass"
    ent.ObserveField("isAuthenticated", "OnIsAuth")
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        handlerConfigEntitlement: {
            name: "myAuthHandler"
        }
    }, true)
    ent.content = content
    m.top.ComponentController.callFunc("show", {view: ent})

    ' ... myAuthHandler scope:

    function Authenticate(username as String, password as String) as Boolean
        ' Here you should implement the business logic for authentication based on username
        ' and password (API calls etc) and return result of the operation:
        ' - true if successfully authenticated
        ' - false if not authenticated
        ' EntitlementView.isAuthenticated will be populated with this return value
    end function

    ' ====== Use case 6: Roku Pay transactional purchase (TVOD) flow ======

    ' ... Scene scope:

    ' In order to initiate transactional purchase flow, you need to:
    ' - create the view
    ' - specify "RokuPay_TVOD" mode
    ' - observe its orderResult interface that will be populated with TVOD flow result
    ' - assign content node with the handler config
    ' - show the view
    ent = CreateObject("roSGNode", "EntitlementView")
    ent.mode = "RokuPay_TVOD"
    ent.ObserveField("orderResult", "OnOrderResult")
    content = CreateObject("roSGNode", "ContentNode")
    content.Update({
        handlerConfigEntitlement: {
            name: "myTVODHandler"
            orderRequest: {  'this is optional, can be done in ConfigureEntitlements() in the handler scope (see below)
                code: "mytvodproduct1"  'Roku Pay one-time purchase product ID
                price: "0.99"           'price to be charged, without currency sign
                priceDisplay: "0.99"    'price to be displayed
                title: "TVOD product 1" 'title of the product to be shown on user's invoices for the purchased item
            }
        }
    }, true)
    ent.content = content
    m.top.ComponentController.callFunc("show", {view: ent})

    ' ... myTVODHandler scope:
    
    sub ConfigureEntitlements(config as Object)
        ' Here you can optionally implement business logic to set config.orderRequest
        ' if orderRequest wasn't specified on the associated handlerConfigEntitlement
        ' or redefine it, if needed
    end function

    function ConfirmOrder(orderInfo as Object) as Boolean
        ' This is the place to implement business logic to either proceed or not
        ' with the transaction requested by orderRequest. 
        
        ' In order to confirm and proceed with the transaction, true should be returned.
        
        ' If return value is false then transaction will not be performed.
        ' Prior to returning false, you can optionally specify orderInfo.errorCode
        ' and orderInfo.errorMessage (both values shoudl be strings) to be reflected in
        ' EntitlementView.orderResult and OnPurchaseFailure() errorInfo
    end function
    
    sub OnPurchaseSuccess(purchaseInfo as Object)
        ' Here you can optionally implement business logic (API calls etc)
        ' in response to the successful transaction
    end sub
    
    sub OnPurchaseFailure(errorInfo as Object)
        ' Here you can optionally implement business logic (API calls etc)
        ' in response to the failed transaction
    end sub


___

## <a id="searchview"></a>SearchView
### <a id="searchview#extends"></a>Extends: [SGDEXComponent](#sgdexcomponent)
### <a id="searchview#description"></a>Description
SearchView requires firmware v9.1 or newer

### <a id="searchview#interface"></a>Interface
#### <a id="searchview#fields"></a>Fields
  
* <a id="searchview#fields#rowitemfocused"></a>**rowItemFocused** (vector2d)
    * Default value: [-1,-1]
    * Read only  
Updated when grid focused item changes  
Value is an array containing the index of the row and item that were focused  
  
* <a id="searchview#fields#rowitemselected"></a>**rowItemSelected** (vector2d)
    * Read only  
Updated when an item on the grid with result is selected  
Value is an array containing the index of the row and item that were selected  
  
* <a id="searchview#fields#shownoresultslabel"></a>**showNoResultsLabel** (boolean)
    * Default value: true
    * If set to true and there is no search results then label with text  
specified in noResultsLabelText field will be shown instead of the grid  
  
* <a id="searchview#fields#noresultslabeltext"></a>**noResultsLabelText** (string)
    * Default value: No results
    * Specifies the text which will be shown in case if there is  
no search results and showNoResultsLabel is true  
  
* <a id="searchview#fields#hinttext"></a>**hintText** (string)
    * Specifies a string to be displayed if the length of the input text is zero  
The typical usage of this field is to prompt the user about what to enter  
  
* <a id="searchview#fields#query"></a>**query** (string)
    * Read only  
The text entered by the user  
  
* <a id="searchview#fields#rowpostershapes"></a>**rowPosterShapes** (stringarray)
    * Interface to support different poster shapes for grid rows.  
Value is an array of strings, which set row poster shapes.  
If the array contains fewer elements than the number of rows, then the shape of rest rows will be set to posterShape field 	or to the last value in the array.  
  
* <a id="searchview#fields#theme"></a>**theme** (assocarray)
    * Controls the color of visual elements  
	* Possible values  
     * textColor - sets the color of all text elements in the view
     * focusRingColor - sets the color of focus ring
     * keyboardKeyColor - sets the color of the key labels and icons when the Keyboard node does not have the focus
     * keyboardFocusedKeyColor - sets the color of the key labels and icons when the Keyboard node has the focus
     * textBoxTextColor - sets the color of the text string displayed in the TextBox
     * textBoxHintColor - sets the color of the hint text string
     * noResultsLabelColor - sets the color of the label which is shown when there is no results
     * rowLabelColor - sets the color for row titles
     * focusFootprintColor - sets color for focus ring when unfocused
     * itemTextColorLine1 - sets color for first row in short description
     * itemTextColorLine2 - sets color for second row in short description
     * itemTextBackgroundColor - set a background color for the short description
     * itemBackgroundColor - set color for background rectangle under the poster
     * shortDescriptionLine1Align - set horizontal alignment for short description line 1
     * shortDescriptionLine2Align - set horizontal alignment for short description line 2
  
* <a id="searchview#fields#updatetheme"></a>**updateTheme** (assocarray)
    * updateTheme is used to update view specific theme fields  
Usage is same as [theme](#sgdexcomponent) field but here you should only set field that you want to update  
If you want global updates use [BaseScene updateTheme](#basescene)  
  
* <a id="searchview#fields#postershape"></a>**posterShape** (string)
    * Controls the aspect ratio of the posters on the result grid  
	* Possible values  
     * 16x9
     * portrait
     * 4x3
     * square
  
* <a id="searchview#fields#content"></a>**content** (node)
    * Controls how SGDEX will load the content for search result  


### <a id="searchview#sample"></a>Sample of usage:
    Content metadata field that can be used:
    root = {
        children:[{
            title: "Row title"
            children: [{
                title: "title that will be shown on upper details section"
                description: "Description that will be shown on upper details section"
                hdPosterUrl: "Poster URL that should be shown on grid item"

                releaseDate: "Release date string"
                StarRating: "star rating integer between 0 and 100"

                gridItemMetaData: "fields that are used on grid"

                shortDescriptionLine1: "first row that will be displayed on grid"
                shortDescriptionLine2: "second row that will be displayed on grid"

                _forShowing_bookmarks_on_grid: "Add these fields to show bookmarks on grid item"
                length: "length of video"
                bookmarkposition: "actual bookmark position"

                _note: "tels if this bar should be hidden, default = true"
                hideItemDurationBar: false
            }]
        }]
    }

    ' If you have to make API call to get search result you should observe query field and
    ' perform loading content like this:

    searchView = CreateObject("roSGNode", "SearchView")
    searchView.ObserveFieldScoped("query", "OnSearchQuery")

    sub OnSearchQuery(event as Object)
        query = event.GetData()
        content = CreateObject("roSGNode", "ContentNode")
        if query.Len() > 2 ' only search if user has typed at least three characters
            content.AddFields({
                HandlerConfigSearch: {
                    name: "CHRoot"
                    query: query
                }
            })
        end if
        ' setting the content with handlerConfigSearch will trigger creation
        ' of grid view and its content manager
        ' setting an empty content node clears the grid
        event.GetRoSGNode().content = content
    end sub

    ' Where CHRoot is a ContentHandler that is responsible for getting search results for grid


___

## <a id="detailsview"></a>DetailsView
### <a id="detailsview#extends"></a>Extends: [SGDEXComponent](#sgdexcomponent)
### <a id="detailsview#description"></a>Description
buttons support same content meta-data fields as Label list, so you can set title and small icon for each button  
fields description:  
TITLE - string  The label for the list item  
HDLISTITEMICONURL - uri The image file for the icon to be displayed to the left of the list item label when the list item is not focused  
HDLISTITEMICONSELECTEDURL - uri The image file for the icon to be displayed to the left of the list item label when the list item is focused

### <a id="detailsview#interface"></a>Interface
#### <a id="detailsview#fields"></a>Fields
  
* <a id="detailsview#fields#buttons"></a>**buttons** (node)
    * Content node for buttons node. Has childrens with id and title that will be shown on View.  
  
* <a id="detailsview#fields#iscontentlist"></a>**isContentList** (bool)
    * Default value: true
    * Tells details view how your content is structured  
if set to true it will take children of _content_ to display on View  
if set to false it will take _content_ and display it on the View  
    * Write Only  
* <a id="detailsview#fields#allowwrapcontent"></a>**allowWrapContent** (bool)
    * Default value: true
    * defines logic of showing content when pressing left on first item, or pressing right on last item.  
if set to true it will start from start from first item (when pressing right) or last item (when pressing left)  
    * Write Only  
* <a id="detailsview#fields#currentitem"></a>**currentItem** (node)
    * Current displayed item. This item is set when Content Getter finished loading extra meta-data  
    * Read Only  
* <a id="detailsview#fields#itemfocused"></a>**itemFocused** (integer)
    * tells what item is currently focused  
  
* <a id="detailsview#fields#itemloaded"></a>**itemLoaded** (bool)
    * itemLoaded is set to true when currentItem field is populated with new content node when content available or loaded  
  
* <a id="detailsview#fields#jumptoitem"></a>**jumpToItem** (integer)
    * Default value: 0
    * Manually focus on desired item. This field must be set after setting the content field.  
    * Write Only  
* <a id="detailsview#fields#buttonfocused"></a>**buttonFocused** (integer)
    * Tells what button is focused  
    * Read Only  
* <a id="detailsview#fields#buttonselected"></a>**buttonSelected** (integer)
    * Is set when button is selected by user. Should be observed in channel.  
Can be used for showing next View or start playback or so.  
    * Read Only  
* <a id="detailsview#fields#jumptobutton"></a>**jumpToButton** (integer)
    * Interface for setting focused button  
    * Write Only  
* <a id="detailsview#fields#theme"></a>**theme** (assocarray)
    * Controls the color of visual elements  
	* Possible values  
     * textColor - sets the color of all text elements in the view
     * focusRingColor - set color of focus ring
     * focusFootprintColor - set color for focus ring when unfocused
     * rowLabelColor - sets color for row title
     * descriptionColor -set the color of descriptionLabel
     * actorsColor -set the color of actorsLabel
     * ReleaseDateColor -set the the color for ReleaseDate
     * RatingAndCategoriesColor -set the color of categories
     * buttonsFocusedColor - set the color of focused buttons
     * buttonsUnFocusedColor - set the color of unfucused buttons
     * buttonsFocusRingColor - set the color of button focuse ring
     * buttonsSectionDividerTextColor - set the color of section divider


___

## <a id="timegridview"></a>TimeGridView
### <a id="timegridview#extends"></a>Extends: [SGDEXComponent](#sgdexcomponent)
### <a id="timegridview#description"></a>Description
TimeGridView represents SGDEX view that is responsible for:  
- Rendering TimeGrid node  
- content loading with different content models  
- loading channels content when user is navigating  
- lazy loading of channels in IDLE

### <a id="timegridview#interface"></a>Interface
#### <a id="timegridview#fields"></a>Fields
  
* <a id="timegridview#fields#contentstarttime"></a>**contentStartTime** (integer)
    * Alias to the TimeGrid contentStartTime field  
The earliest time that the TimeGrid can be moved to  
  
* <a id="timegridview#fields#maxdays"></a>**maxDays** (integer)
    * Alias to the TimeGrid maxDays field  
Specifies the total width of the TimeGrid in days  
  
* <a id="timegridview#fields#rowitemselected"></a>**rowItemSelected** (array)
    * Updated when user selects a program from the TimeGrid  
Value is an array of indexes represents [channelIndex, programIndex]  
updated simultaneously with channelSelected and programSelected  
  
* <a id="timegridview#fields#jumptorow"></a>**jumpToRow** (integer)
    * Set grid focus to specified row  
Value is an integer index of the row that should be focused  
This field must be set after setting the content field.  
    * Write Only  
* <a id="timegridview#fields#jumptorowitem"></a>**jumpToRowItem** (vector2d)
    * Set grid focus to specified item in a row  
Value is an array containing the index of the row and item that should be focused  
This field must be set after setting the content field.  
    * Write Only

### <a id="timegridview#sample"></a>Sample of usage:
    timeGrid = CreateObject("roSGNode", "TimeGridView")
    content = CreateObject("roSGNode", "ContentNode")
    content.addfields({
        HandlerConfigTimeGrid: {
            name: "HCTimeGrid"
        }
    })
    timeGrid.content = content
    timeGrid.observeField("rowItemSelected", "OnTimeGridRowItemSelected")

    m.top.ComponentController.callFunc("show", {
        view: timeGrid
    })


___

## <a id="mediaview"></a>MediaView
### <a id="mediaview#extends"></a>Extends: [SGDEXComponent](#sgdexcomponent)
### <a id="mediaview#description"></a>Description
Media View is a component that provide pre-defined approach to play video or audio  
It incapsulates different features:  
- Playback of video or audio  
- Playback of playlist or one item;  
- Two different UI modes for audio and video items;  
- Ability to set mixed content (both video and audio);  
- Loading of content via HandlerConfigMedia before playback;  
- Showing Endcards View after playback ends;  
- Loading of endcard content via HandlerConfigEndcard some time before playback ends to provide smooth user experience;  
- Handling of RAF - handlerConfigRAF should be set in content node;  
- State field is aliased to make tracking of states easier;  
- Themes support  
### Limitations  
- When using MediaView in audio mode with a list of content, you must populate the *url* field  
  of **all** items in the playlist before starting playback.

### <a id="mediaview#interface"></a>Interface
#### <a id="mediaview#fields"></a>Fields
  
* <a id="mediaview#fields#mode"></a>**mode** (string)
    * Default value: video
    * Defines view mode to properly display media content on the view  
  
* <a id="mediaview#fields#endcardcountdowntime"></a>**endcardCountdownTime** (integer)
    * Default value: 10
    * Endcard countdown time. How much endcard is shown until next video start  
  
* <a id="mediaview#fields#endcardloadtime"></a>**endcardLoadTime** (integer)
    * Default value: 10
    * Time to end when endcard content start load  
  
* <a id="mediaview#fields#alwaysshowendcards"></a>**alwaysShowEndcards** (bool)
    * Default value: false
    * Config to know should Media View show endcards with default next item and Repeat button  
even if there is no content getter specified by developer  
  
* <a id="mediaview#fields#iscontentlist"></a>**isContentList** (bool)
    * Default value: true
    * Sets the operating mode of the view.  
 When true, the playlist of content is represented by the children of the root ContentNode.  
 When false, the root ContentNode itself is treated as a single piece of content.  
 This field must be set before setting the content field.  
  
* <a id="mediaview#fields#jumptoitem"></a>**jumpToItem** (integer)
    * Default value: 0
    * Jumps to item in playlist  
  This field must be set after setting the content field.  
  
* <a id="mediaview#fields#control"></a>**control** (string)
    * Default value: none
    * Control "play" and "prebuffer" makes library start to load content from Content Getter  
if any other control - set it directly to video node  
  
* <a id="mediaview#fields#preloadcontent"></a>**preloadContent** (boolean)
    * Default value: false
    * Trigger to notify that next item in playlist should be preloaded while Endcard view is shown  
  
* <a id="mediaview#fields#endcardtrigger"></a>**endcardTrigger** (boolean)
    * Default value: false
    * Trigger to notify channel that endcard loading is started  
  
* <a id="mediaview#fields#currentindex"></a>**currentIndex** (integer)
    * Default value: -1
    * Field to know what is index of current item - index of child in content Content Node  
  
* <a id="mediaview#fields#state"></a>**state** (string)
    * Media Node state  
  
* <a id="mediaview#fields#position"></a>**position** (int)
    * Default value: 0
    * Playback position in seconds  
  
* <a id="mediaview#fields#duration"></a>**duration** (int)
    * Default value: 0
    * Playback duration in seconds  
  
* <a id="mediaview#fields#seek"></a>**seek** (int)
    * Default value: -1
    * The value is the number seconds from the beginning of the stream  
    * Write Only  
* <a id="mediaview#fields#currentitem"></a>**currentItem** (node)
    * If change this field manually, unexpected behaviour can occur.  
    * Read Only  
* <a id="mediaview#fields#enabletrickplay"></a>**enableTrickPlay** (boolean)
    * Default value: true
    * Enables/Disables trick play  
  
* <a id="mediaview#fields#endcarditemselected"></a>**endcardItemSelected** (node)
    * Content node of endcard item what was selected  
  
* <a id="mediaview#fields#repeatone"></a>**repeatOne** (bool)
    * Default value: false
    * Working only for audio mode  
  
* <a id="mediaview#fields#repeatall"></a>**repeatAll** (bool)
    * Default value: false
    * Working only in playlist mode  
  
* <a id="mediaview#fields#shuffle"></a>**shuffle** (bool)
    * Default value: false
    * Working only for audio mode in playlist mode  
  
* <a id="mediaview#fields#disablescreensaver"></a>**disableScreenSaver** (boolean)
    * Default value: false
    * This is an alias of the video node's field of the same name  
  https://sdkdocs.roku.com/display/sdkdoc/Video#Video-MiscellaneousFields  
  
* <a id="mediaview#fields#buttons"></a>**buttons** (node)
    * Only appies to audio mode.  
  Content node for buttons node. Has childrens with id and title that will be shown on View.  
  
* <a id="mediaview#fields#buttonselected"></a>**buttonSelected** (int)
    * Default value: -1
    * Is set when button is selected by user. Should be observed in channel.  
    * Read Only  
* <a id="mediaview#fields#theme"></a>**theme** (assocarray)
    * Theme is used to change color of grid view elements  
<b>Note.</b> you can set TextColor and focusRingColor to have generic theme and only change attributes that shouldn't use it.  
<b>Possible fields:</b>  
<b>General fields</b>  
	* Possible values  
     * TextColor - set text color for all texts on video and endcard views
     * progressBarColor - set color for progress bar
     * focusRingColor - set color for focus ring on endcard view
     * backgroundColor - set background color for endcards view
     * backgroundImageURI - set background image url for endcards view
     * endcardGridBackgroundColor -set background color for grid for endcard items  
<b>Video player fields:</b>
     * trickPlayBarTextColor - Sets the color of the text next to the trickPlayBar node indicating the time elapsed/remaining.
     * trickPlayBarTrackImageUri - A 9-patch or ordinary PNG of the track of the progress bar, which surrounds the filled and empty bars. This will be blended with the color specified by the trackBlendColor field, if set to a non-default value.
     * trickPlayBarTrackBlendColor - This color is blended with the graphical image specified by trackImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.
     * trickPlayBarThumbBlendColor - Sets the blend color of the square image in the trickPlayBar node that shows the current position, with the current direction arrows or pause icon on top. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.
     * trickPlayBarFilledBarImageUri - A 9-patch or ordinary PNG of the bar that represents the completed portion of the work represented by this ProgressBar node. This is typically displayed on the left side of the track. This will be blended with the color specified by the filledBarBlendColor field, if set to a non-default value.
     * trickPlayBarFilledBarBlendColor - This color will be blended with the graphical image specified in the filledBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.
     * trickPlayBarCurrentTimeMarkerBlendColor - This is blended with the marker for the current playback position. This is typically a small vertical bar displayed in the TrickPlayBar node when the developer is fast-forwarding or rewinding through the video.  
<b>Buffering Bar customization</b>
     * bufferingTextColor - The color of the text displayed near the buffering bar defined by the bufferingBar field, when the buffering bar is visible. If this is 0, the system default color is used. To set a custom color, set this field to a value other than 0x0.
     * bufferingBarEmptyBarImageUri - A 9-patch or ordinary PNG of the bar presenting the remaining work to be done. This is typically displayed on the right side of the track, and is blended with the color specified in the emptyBarBlendColor field, if set to a non-default value.
     * bufferingBarFilledBarImageUri - A 9-patch or ordinary PNG of the bar that represents the completed portion of the work represented by this ProgressBar node. This is typically displayed on the left side of the track. This will be blended with the color specified by the filledBarBlendColor field, if set to a non-default value.
     * bufferingBarTrackImageUri - A 9-patch or ordinary PNG of the track of the progress bar, which surrounds the filled and empty bars. This will be blended with the color specified by the trackBlendColor field, if set to a non-default value.
     * bufferingBarTrackBlendColor - This color is blended with the graphical image specified by trackImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.
     * bufferingBarEmptyBarBlendColor - A color to be blended with the graphical image specified in the emptyBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.
     * bufferingBarFilledBarBlendColor - This color will be blended with the graphical image specified in the filledBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.  
<b>Retrieving Bar customization</b>
     * retrievingTextColor - Same as bufferingTextColor but for retrieving bar
     * retrievingBarEmptyBarImageUri - Same as bufferingBarEmptyBarImageUri but for retrieving bar
     * retrievingBarFilledBarImageUri - Same as bufferingBarFilledBarImageUri but for retrieving bar
     * retrievingBarTrackImageUri - Same as bufferingBarTrackImageUri but for retrieving bar
     * retrievingBarTrackBlendColor - Same as bufferingBarTrackBlendColor but for retrieving bar
     * retrievingBarEmptyBarBlendColor - Same as bufferingBarEmptyBarBlendColor but for retrieving bar
     * retrievingBarFilledBarBlendColor - Same as bufferingBarFilledBarBlendColor but for retrieving bar  
<b>BIF customization</b>
     * focusRingColor - a color to be blended with the image displayed behind individual BIF images displayed on the screen  
<b>Endcard & Nowplaying view theme attributes</b>
     * buttonsFocusedColor - button focused text color
     * buttonsUnFocusedColor - button unfocused text color
     * buttonsfocusRingColor - button background color  
<b>grid attributes</b>
     * rowLabelColor - grid row title color
     * focusRingColor - grid focus ring color
     * focusFootprintBlendColor - grid unfocused focus ring color
     * itemTextColorLine1 - text color for 1st row on endcard item
     * itemTextColorLine2 - text color for 2nd row on endcard item
     * timerLabelColor - Color of remaining timer  
<b> Audio mode text attributes</b>
     * albumColor - set color for albom name
     * titleColor - set color for title
     * artistColor - set color for artist
     * releaseDateColor - set color for release date


___

## <a id="slideshowview"></a>SlideShowView
### <a id="slideshowview#extends"></a>Extends: [SGDEXComponent](#sgdexcomponent)
### <a id="slideshowview#description"></a>Description
- SlideShowView displays a collection of images to the user  
- SlideShowView can be populated with content directly by setting its _content_  
field or by using a ContentHandler.  
- SlideShowView can be configured in a variety of ways using the fields documented below.

### <a id="slideshowview#interface"></a>Interface
#### <a id="slideshowview#fields"></a>Fields
  
* <a id="slideshowview#fields#iscontentlist"></a>**isContentList** (bool)
    * Default value: true
    * Tells SlideShowView how your content is structured  
if set to true it will take children of content to display on View  
if set to false it will take content and display it on the View  
This field must be set before setting the content field.  
  
* <a id="slideshowview#fields#slideduration"></a>**slideDuration** (integer)
    * Default value: 10
    * Number of seconds each slide is displayed  
Default value is 10  
  
* <a id="slideshowview#fields#textoverlayvisible"></a>**textOverlayVisible** (bool)
    * Default value: true
    * Controls whether the text overlay is displayed.  
  
* <a id="slideshowview#fields#textoverlayholdtime"></a>**textOverlayHoldTime** (float)
    * Default value: 5
    * Number of milliseconds to display the text overlay for each slide.  
  
* <a id="slideshowview#fields#displaymode"></a>**displayMode** (string)
    * Default value: scale-to-fit
    * Sets the mode for displaying slideshow images  
Valid display modes are:  
scale-to-fit – scale image to fit horizontally or vertically as appropriate while still maintaining aspect ratio. (Default)  
scale-to-fill – scale image to completely fill the rectangle of the bounding frame  
zoom-to-fill – scales and crops image to maintain aspect ratio and completely fill the rectangle of the bounding frame.  
no-scale – The bitmap will be loaded at the image's original resolution.  
If the Poster's width and height differ from the bitmap's resolution,  
it will be scaled to fill the Poster's dimensions. Aspect ratio is not preserved.  
  
* <a id="slideshowview#fields#jumptoitem"></a>**jumpToItem** (integer)
    * Default value: 0
    * Jumps to item in list of images. This field must be set after setting the content field.  
    * Write Only  
* <a id="slideshowview#fields#currentindex"></a>**currentIndex** (integer)
    * Default value: 0  
    * Read Only  
* <a id="slideshowview#fields#loop"></a>**loop** (bool)
    * Default value: true
    * Controls whether SlideshowVIew loops through content repeatedly.  
  
* <a id="slideshowview#fields#closeafterlastslide"></a>**closeAfterLastSlide** (bool)
    * Default value: false
    * If set to true and loop is false, the SlideShowView will close after last slide is shown.  
    * Write Only  
* <a id="slideshowview#fields#control"></a>**control** (string)
    * Default value: none
    * Field for setting control. Possible values: play, pause.  
  
* <a id="slideshowview#fields#theme"></a>**theme** (assocarray)  
	* Possible values  
     * TitleColor - set text color for title shown on view
     * DescriptionColor - set text color for description shown on view
     * TextOverlayBackgroundColor - set background color for overlay text
     * BackgroundColor - set background color for endcards view
     * PauseIconColor - set color for pause icon
     * PlayIconColor - set color for play icon
     * BusySpinnerColor - set color for busy spinner shown on loading


### <a id="slideshowview#sample"></a>Sample of usage:
    SlideShow = CreateObject("roSGNode", "SlideShowView")
    SlideShow.posterShape = "square"

    content = CreateObject("roSGNode", "ContentNode")
    content.Addfields({
        ' set up a ContentHandler for the view
        HandlerConfigSlideShow: {
            name: "CHImages"
        }
    })

    SlideShow.content = content

    ' this will trigger job to show this View
    m.top.ComponentController.CallFunc("show", {
        view: SlideShow
    })



___

## <a id="categorylistview"></a>CategoryListView
### <a id="categorylistview#extends"></a>Extends: [SGDEXComponent](#sgdexcomponent)
### <a id="categorylistview#description"></a>Description
CategoryListView represents SGDEX category list view that shows two lists: one for categories another for items in category

### <a id="categorylistview#interface"></a>Interface
#### <a id="categorylistview#fields"></a>Fields
  
* <a id="categorylistview#fields#initialposition"></a>**initialPosition** (vector2d)
    * Default value: [0, 0]
    * Tells where set initial focus on itemsList: 1st coordinate = category, 2st coordinate = item in this category  
  
* <a id="categorylistview#fields#selecteditem"></a>**selectedItem** (vector2d)
    * Array with 2 ints - section and item in current section that was selected  
    * Read Only  
* <a id="categorylistview#fields#focuseditem"></a>**focusedItem** (int)
    * Current focued item index (within all categories)  
    * Read Only  
* <a id="categorylistview#fields#focuseditemincategory"></a>**focusedItemInCategory** (int)
    * Current focued item index from current focusedCategory  
  
* <a id="categorylistview#fields#focusedcategory"></a>**focusedCategory** (int)
    * Current focused category index.  
  
* <a id="categorylistview#fields#ffrwpagesize"></a>**ffrwPageSize** (int)
    * Default value: 0
    * This value defines page size for scrolling with ff/rw buttons.  
 If value is 0 (default), FF/RW buttons will switch to next/prev section.  
 If value is > 0, FF/RW buttons will scroll ffrwPageSize items down/up through sections borders.  
  
* <a id="categorylistview#fields#jumptoitem"></a>**jumpToItem** (int)
    * Jumps to item in items list (within all categories).  
  This field must be set after setting the content field.  
    * Write Only  
* <a id="categorylistview#fields#animatetoitem"></a>**animateToItem** (int)
    * Animates to item in items list (within all categories).  
    * Write Only  
* <a id="categorylistview#fields#jumptocategory"></a>**jumpToCategory** (int)
    * Jumps to category.  
    * Write Only  
* <a id="categorylistview#fields#animatetocategory"></a>**animateToCategory** (int)
    * Animates to category.  
    * Write Only  
* <a id="categorylistview#fields#jumptoitemincategory"></a>**jumpToItemInCategory** (int)  
    * Write Only  
* <a id="categorylistview#fields#animatetoitemincategory"></a>**animateToItemInCategory** (int)
    * Animates to item in current category.  
    * Write Only  
* <a id="categorylistview#fields#theme"></a>**theme** (assocarray)
    * Theme is used to change color of grid view elements  
Note. you can set TextColor and focusRingColor to have generic theme and only change attributes that shouldn't use it.  
Possible fields:  
TextColor - changes color for all text fields in category list  
focusRingColor - changes color of focus rings for both category and item list  
categoryFocusedColor - set focused text color for category  
categoryUnFocusedColor - set unfocused text color for category  
itemTitleColor - set item title color  
itemDescriptionColor - set item description color  
categoryfocusRingColor - set color for category list focus ring  
itemsListfocusRingColor - set color for item list focus ring  
  
* <a id="categorylistview#fields#content"></a>**content** (node)
    * In order to build proper content node tree you have to stick to this model:  
Possible fields:  
Category fields:  
Title - Title that will be displayed for category name  
CONTENTTYPE - Must be set to SECTION  
HDLISTITEMICONURL - The image file for the icon to be displayed to the left of the list item label when the list item is not focused  
HDLISTITEMICONSELECTEDURL - The image file for the icon to be displayed to the left of the list item label when the list item is focused  
HDGRIDPOSTERURL - The image file for the icon to be displayed to the left of the section label when the View resolution is set to HD.  
Item List fields:  
title - Title to be shown  
description - Description for item, max 4 lines  
hdPosterUrl - image url for item  


### <a id="categorylistview#sample"></a>Sample of usage:
    CategoryList = CreateObject("roSGNode", "CategoryListView")
    CategoryList.posterShape = "square"

    content = CreateObject("roSGNode", "ContentNode")
    content.Addfields({
        HandlerCategoryList: {
            name: "CGSeasons"
        }
    })

    CategoryList.content = content
    CategoryList.ObserveField("selectedItem", "OnEpisodeSelected")

    ' this will trigger job to show this View
    m.top.ComponentController.CallFunc("show", {
        view: CategoryList
    })

    <b>Advanced loading logic</b>

    root = {
        HandlerConfigCategoryList: {
            _description: "Content handler that will be called to populate categories if they are not created"
            name: "Component name that extends [ContentHandler](#ContentHandler)"
            fields: {
                field: "any field that you want to set in this component when it's created"
            }
        }
        _comment: "categories"
        children: [{
            title: "Category that is prepopulated"
            contentType: "section"
            children: [{
                title: "Title to be shown"
                description: "Description for item, max 4 lines"
                hdPosterUrl: "image url for item"
            }]
            _optionalFields: "Fields that can be used for category"
            HDLISTITEMICONURL: "icon that will be shown left to category when not focused"
            HDLISTITEMICONSELECTEDURL: "icon that will be shown left to category title when focused"
            HDGRIDPOSTERURL: "icon that will be shown left to title in item list"
        }, {
            title: "Category that requires content to be loaded"
            contentType: "section"
            HandlerConfigCategoryList: {
                _description: "Content handler that will be called if there are no children in category"
                name: "Component name that extends [ContentHandler](#ContentHandler)"
                fields: {
                    field: "any field that you want to set in this component when it's created"
                }
            }
        }, {
            title: "Category that has children but they need metadata (non serial model)"
            contentType: "section"
            HandlerConfigCategoryList: {
                _description: "Content handler that will be called if "
                name: "Component name that extends [ContentHandler](#ContentHandler)"
                _note: "use bigger value for page size to improve performance"
                _mandatatory: "This field is required in order to work"

                pageSize: 2
                fields: {
                    field: "any field that you want to set in this component when it's created"
                }
            }
            children: [{title: "Title to be shown"}
                {title: "Title to be shown"}
                {title: "Title to be shown"}
                {title: "Title to be shown"}]
        }, {
            title: "Category has children but there are more items that can be loaded"
            contentType: "section"
            HandlerConfigCategoryList: {
                _description: "Content handler will be called when focused near end of category"
                name: "Component name that extends [ContentHandler](#ContentHandler)"
                _mandatatory: "This field is required in order to work"
                hasMore: true
                fields: {
                    field: "any field that you want to set in this component when it's created"
                }
            }
            children: [{
                title: "Title to be shown"
                description: "Description for item, max 4 lines"
                hdPosterUrl: "image url for item"
            }]
        }]
    }

    CategoryList = CreateObject("roSGNode", "CategoryListView")
    CategoryList.posterShape = "square"

    content = CreateObject("roSGNode", "ContentNode")
    content.update(root)

    CategoryList.content = content

    ' this will trigger job to show this View
    m.top.ComponentController.CallFunc("show", {
        view: CategoryList
    })



___

## <a id="sgdexcomponent"></a>SGDEXComponent
### <a id="sgdexcomponent#extends"></a>Extends: Group
### <a id="sgdexcomponent#description"></a>Description
Base component for SGDEX views that adds common fields and handles theme params passing to view,  
 each view is responsible for populating proper params to it's views

### <a id="sgdexcomponent#interface"></a>Interface
#### <a id="sgdexcomponent#fields"></a>Fields
  
* <a id="sgdexcomponent#fields#theme"></a>**theme** (assocarray)
    * Theme is used to set view specific theme fields, this is used to set initial theme, if you want to update any value use updateTheme  
Commmon attributes for all view:  
*textColor - Set text color to all supported labels  
*focusRingColor - Set focus ring color  
*progressBarColor - Set color for progress bars  
*backgroundImageURI - Set url to background image  
*backgroundColor - Set background color  
*busySpinnerColor - Set loading spinner color  
*OverhangTitle - text that will be displayed in overhang title  
*OverhangTitleColor - Color of overhang title  
*OverhangShowClock - toggle showing of overhang clock  
*OverhangShowOptions - show options on overhang  
*OverhangOptionsAvailable - tells if options are available. Note this is only visual field and doesn't affect if developer implements options  
*OverhangVisible - set if overhang should be visible  
*OverhangLogoUri - url to overhang logo  
*OverhangBackgroundUri - overhang background url  
*OverhangOptionsText - text that will be show in options  
*OverhangHeight - height of overhang  
*OverhangBackgroundColor - overhang background color  
Usage:  
To set global theme attributes refer to [BaseScene](#basescene)  
To set view specific fields use:  
view = CreateObject("roSGNode", "GridView")  
view.theme = {  
textColor: "FF0000FF"  
}  
  
* <a id="sgdexcomponent#fields#updatetheme"></a>**updateTheme** (assocarray)
    * updateTheme is used to update view specific theme fields  
Usage is same as [theme](#sgdexcomponent) field but here you should only set field that you want to update  
If you want global updates use [BaseScene updateTheme](#basescene)  
  
* <a id="sgdexcomponent#fields#style"></a>**style** (string)
    * is used to tell view what style should be used, style is view specific  
  
* <a id="sgdexcomponent#fields#postershape"></a>**posterShape** (string)
    * is used to tell view what poster shape should be used for posters that are rendered on view  
  
* <a id="sgdexcomponent#fields#content"></a>**content** (node)
    * Main field for setting content  
content tree is specific to each view and is handled by view itself  
  
* <a id="sgdexcomponent#fields#close"></a>**close** (boolean)
    * Control field to tell View Manager to close this View manually.  
Is desined for authentication flows or other flows when set of Views should be closed after some action.  
  
* <a id="sgdexcomponent#fields#wasclosed"></a>**wasClosed** (boolean)
    * Observe this to know when view is closed and removed from View Manager  
  
* <a id="sgdexcomponent#fields#savestate"></a>**saveState** (boolean)
    * Observe this to know when view is hiding and new top view is being opened  
  
* <a id="sgdexcomponent#fields#wasshown"></a>**wasShown** (boolean)
    * Observe this to know when view was shown for first time or restored after top view was closed  


___

## <a id="buttonbar"></a>ButtonBar
### <a id="buttonbar#extends"></a>Extends: Group
### <a id="buttonbar#description"></a>Description
ButtonBar provides an easy way to display a collection of buttons over any view

### <a id="buttonbar#interface"></a>Interface
#### <a id="buttonbar#fields"></a>Fields
  
* <a id="buttonbar#fields#content"></a>**content** (node)
    * СontentNode for ButtonBar. This node should have a child for each button to be displayed.  
 You can also populate this node using an SGDEX ContentHandler  
  
* <a id="buttonbar#fields#alignment"></a>**alignment** (string)
    * Default value: top
    * Possible values: "top", "left".  
 Controls the position of ButtonBar  
  
* <a id="buttonbar#fields#itemfocused"></a>**itemFocused** (integer)
    * Default value: 0
    * Updated when the focused button changes.  
 Developers can observe this field in their channels to react to the  
 user navigating from button to button  
    * Read Only  
* <a id="buttonbar#fields#itemselected"></a>**itemSelected** (integer)
    * Default value: 0
    * Updated when a button is selected.  
 Developers can observe this field in their channels to react to the  
 user selecting a button.  
    * Read Only  
* <a id="buttonbar#fields#jumptoitem"></a>**jumpToItem** (integer)
    * Default value: 0
    * Set this field to force focus to a specific button.  
 This field must be set after setting the content field.  
    * Write Only  
* <a id="buttonbar#fields#autohide"></a>**autoHide** (bool)
    * Default value: false
    * Controls whether the ButtonBar is hidden when it does not have focus.  
 When ButtonBar is hidden, a hint will be displayed in its place.  
    * Write Only  
* <a id="buttonbar#fields#overlay"></a>**overlay** (bool)
    * Default value: false
    * Controls whether ButtonBar slides over the screen's content  
    * Write Only  
* <a id="buttonbar#fields#renderovercontent"></a>**renderOverContent** (bool)
    * Default value: false
    * Controls whether ButtonBar is displayed over playing content.  
 Note, the autoHide hint will not be displayed over playing content  
 when ButtonBar is hidden even if renderOverContent is true.  
    * Write Only  
* <a id="buttonbar#fields#enablefootprint"></a>**enableFootprint** (bool)
    * Default value: true
    * Controls whether the footprint is displayed  
    * Write Only  
* <a id="buttonbar#fields#footprintstyle"></a>**footprintStyle** (string)
    * Default value: focus
    * Possible values: "focus", "selection".  
 Controls which button gets the footprint, the last focused  
 button or the last selected button.  
    * Write Only  
* <a id="buttonbar#fields#theme"></a>**theme** (assocarray)  
	* Possible values  
     * buttonColor - controls the color of button backgrounds
     * buttonTextColor - controls the color of button text
     * focusedButtonColor - controls the color of the focused button's background
     * focusedButtonTextColor - controls the color of the focused button's text
     * footprintButtonColor - controls the color of the footprint button's background
     * footprintButtonTextColor - controls the color of the footprint button's text


### <a id="buttonbar#sample"></a>Sample of usage:
    // MainScene.brs
    m.top.buttonBar.visible = true
    m.top.buttonBar.renderOverContent = true
    m.top.buttonBar.autoHide = true
    m.top.buttonBar.content = retrieveButtonBarContent()
    m.top.buttonBar.ObserveField("itemSelected", "OnButtonBarItemSelected")

    function retrieveButtonBarContent() as Object
        buttonBarContent = CreateObject("roSGNode", "ContentNode")
        buttonBarContent.Update({
            children: [{
                title: "Item 1"
            }, {
                hdPosterUrl: "https://example.com/icon.jpg"
            }, {
                title: "Item 2"
            }, {
                title: "Item 3"
            }, {
                title: "Item 4"
            }]
        }, true)

        return buttonBarContent
    end function

    sub OnButtonBarItemSelected(event as Object)
        ' This is where you can handle a selection event
    end sub


___

## <a id="contenthandler"></a>ContentHandler
### <a id="contenthandler#extends"></a>Extends: Task
### <a id="contenthandler#description"></a>Description
Content Handlers are responsible for all content loading tasks in SGDEX.  
When you extend a Content Handler, you must implement a function called GetContent().  
This function is where you will do things like make API requests and build ContentNodes  
to be rendered in your SGDEX views.

### <a id="contenthandler#interface"></a>Interface
#### <a id="contenthandler#fields"></a>Fields
  
* <a id="contenthandler#fields#content"></a>**content** (node)
    * This is the field you should modify in your GetContent() function  
by adding/updating the ContentNodes being rendered by the associated view.  
  
* <a id="contenthandler#fields#offset"></a>**offset** (int)
    * When working with paged data, this will reflect which page of content  
SGDEX is expecting the ContentHandler to populate.  
  
* <a id="contenthandler#fields#pagesize"></a>**pageSize** (int)
    * When working with paged data, this will reflect the number of items  
SGDEX is expecting the ContentHandler to populate.  
  
* <a id="contenthandler#fields#query"></a>**query** (string)
    * When working with SearchView, this will contain search query passed in config.  
  
* <a id="contenthandler#fields#failed"></a>**failed** (bool)
    * Default value: false
    * When your ContentHandler fails to load the requested content  
you should set this field to TRUE in your GetContent() function. This will  
force SGDEX to re-try the ContentHandler.  
In this case, you can also optionally set a new HandlerConfig to the content field.  
That will cause SGDEX to use the new config when it re-tries the ContentHandler.  
If you do not update the HandlerConfig, SGDEX will re-use the original one for subsequent tries.  
  
* <a id="contenthandler#fields#handlerconfig"></a>**HandlerConfig** (assocarray)
    * This is a copy of the config that was used to invoke the ContentHandler.  


### <a id="contenthandler#sample"></a>Sample of usage:
    ' SimpleContentHandler.xml
    <?xml version="1.0" encoding="UTF-8"?>
    <component name="SimpleContentHandler" extends="ContentHandler" >
      <script type="text/brightscript" uri="pkg:/components/content/SimpleContentHandler.brs" />
    </component>

    ' SimpleContentHandler.brs
    sub GetContent()
      m.top.content.SetFields({
        title: "Hello World"
      })
    end sub


___

## <a id="rafhandler"></a>RAFHandler
### <a id="rafhandler#extends"></a>Extends: Task
### <a id="rafhandler#description"></a>Description
RAFHandler is responsible for making all business logic related to Ads playing.  
developer extends this Handler in channel and can override ConfigureRAF(adIface as Object) sub.  
Reference to Raf library instance will be passed to ConfigureRAF sub.  
In ConfigureRAF developer can make any configuraion that supported by RAF.



### <a id="rafhandler#sample"></a>Sample of usage:
    sub ConfigureRAF(adIface)
        ' Detailed RAF docs: https://sdkdocs.roku.com/display/sdkdoc/Integrating+the+Roku+Advertising+Framework
        adIface.SetAdUrl("http://www.some.ad.url.com")
        adIface.SetContentGenre("General Variety")
        adIface.SetContentLength(1200) ' in seconds
        ' Nielsen specific data
        adIface.EnableNielsenDAR(true)
        adIface.SetNielsenProgramId("CBAA")
        adIface.SetNielsenGenre("GV")
        adIface.SetNielsenAppId("P123QWE-1A2B-1234-5678-C7D654348321")
    end sub


___

## <a id="entitlementhandler"></a>EntitlementHandler
### <a id="entitlementhandler#extends"></a>Extends: Task
### <a id="entitlementhandler#description"></a>Description
In order to use EntitlementView in the channel app, you need to implement your handler extended from EntitlementHandler.  
  
EntitlementHandler allows developer to implement their business logic for  
- handling RokuPay subscription (Roku Billing)  
- handling username/password authentication  
  
depending on EntitlementView.mode.  
  
In EntitlementView.mode = "RokuBilling", developer is able to override the following functions:  
- sub ConfigureEntitlements(config as Object)  [Required]  
- sub OnPurchaseSuccess(transactionData as Object)  [Optional]  
  
"RokuBilling" mode now supports not only regular RokuPay purchase but also [on-device upgrade/downgrade](https://developer.roku.com/docs/developer-program/roku-pay/implementation/on-device-upgrade-downgrade.md).  
Developer must populate config.catalogProducts in their ConfigureEntitlements(config) implementation to specify products to be offered to the user for purchase or upgrade/downgrade.  
  
sub ConfigureEntitlements(config as Object)  
- provides config object prepopulated with config.catalogProducts and config.purchases  
- you must override this function in your handler extended from EntitlementHandler  
- config.catalogProducts - contains array of catalog products per roChannelStore.GetCatalog()  
- config.purchases - contains array of purchases per roChannelStore.GetPurchases()  
- for silentCheckEntitlement flow you must specify config.isSubscribed: true if user has active subscription, false otherwise  
- for subscription purchase/upgrade/downgrade flow you must populate config.displayProducts with the list of products to be displayed to the user  
  
Each item in config.displayProducts should be AA containing the following fields  
- code [String] product code  
- name [String] optional, product display name; if not specified, SGDEX will use the Channel Store data  
- action [String] optional, allows to specify product action for on-device upgrade/downgrade; supported values are "upgrade" and "downgrade", case insensitive  
  
If _action_ is set to "upgrade" or "downgrade" then  
- SGDEX assumes this is a product for upgrade or downgrade operation, respectively, not for a regular purchase  
- if user selects this product then SGDEX initiates upgrade/downgrade operation, essentially subscription change to this product instead of a regular purchase  
- on the Channel Store side, developer must add products to be used for upgrade/downgrade [to a product group](https://developer.roku.com/docs/developer-program/roku-pay/quickstart/in-channel-products.md#adding-product-groups) in order to indicate that these are mutually exclusive  
  
if _action_ is not specified or set to some unsupported value then SGDEX treats this as a regular purchase product, not for upgrade/downgrade.  
  
sub OnPurchaseSuccess(transactionData as Object)  
- if overridden, allows developer to implement some business logic on subscription purchase success  
- transactionData - AA containing RokuPay transaction data per Channel Store response  
- default implementation does nothing  
  
In EntitlementView.mode = "UserPass", developer is able to override the following functions  
- function CheckAuthentication() as Boolean  
- function Authenticate(username as String, password as String) as Boolean  
- function DeAuthenticate() as Boolean   
  
CheckAuthentication()  
- here you should implement the business logic to validate user authentication state (silentCheckAuthentication)  
- return value should be true if user is authenticated, false otherwise  
  
Authenticate(username, password)  
- here you should implement the business logic for authentication by username and password  
- return value should be true if successfully authenticated, false otherwise  
  
DeAuthenticate()  
 - here you should implement the business logic to de-authenticate user (silentDeAuthenticate)  
 - return value should indicate result of the operation and be true if successfully de-authenticated, false otherwise  
  
See EntitlementView documentation for usage samples.

### <a id="entitlementhandler#interface"></a>Interface
#### <a id="entitlementhandler#fields"></a>Fields
  
* <a id="entitlementhandler#fields#content"></a>**content** (node)
    * Content node from EntitlementView will be passed here, developer can use it in handler.  
  
* <a id="entitlementhandler#fields#view"></a>**view** (node)
    * View is a reference to EntitlementView where this Handler is created.  


___

## <a id="componentcontroller"></a>ComponentController
### <a id="componentcontroller#extends"></a>Extends: Group
### <a id="componentcontroller#description"></a>Description
ComponentController (CC) is a node that responsible to make basic View interaction logic.  
From developer side, CC is used to show Views, view stacks for different use cases.  
There are 2 flags to handle close behaviour:  
allowCloseChannelOnLastView:bool=true and allowCloseLastViewOnBack:bool=true  
and 4 fields to operate with view stacks that makes available multi stack functionality :  
addStack:string, removeStack:string, selectStack:string, activeStack:string

### <a id="componentcontroller#interface"></a>Interface
#### <a id="componentcontroller#fields"></a>Fields
  
* <a id="componentcontroller#fields#buttonbar"></a>**buttonBar** (node)
    * Default value: invalid
    * A reference to the button bar node (default ButtonBar is created by the SGDEX)  
  
* <a id="componentcontroller#fields#currentview"></a>**currentView** (node)
    * holds the reference to view that is currently shown.  
Can be used for checking in onkeyEvent  
  
* <a id="componentcontroller#fields#allowclosechannelonlastview"></a>**allowCloseChannelOnLastView** (boolean)
    * Default value: true
    * If developer set this flag channel closes when press back or set close=true on last view  
  
* <a id="componentcontroller#fields#allowcloselastviewonback"></a>**allowCloseLastViewOnBack** (boolean)
    * Default value: true
    * If developer set this flag the last View will be closed and developer can open another in wasClosed callback  
  
* <a id="componentcontroller#fields#addstack"></a>**addStack** (string)
    * WRITE-ONLY. Adds new stack assuming given value as new stack ID and makes it active.   
If there is already stack with such ID (e.g. "default" which always exists) it will become active and a new stack is not added.  
  
* <a id="componentcontroller#fields#removestack"></a>**removeStack** (string)
    * WRITE-ONLY. Accepts stack ID.   
If there is a stack with such ID, it gets removed from ComponentController.   
If active stack gets removed, ComponentController automatically switches to the previously active stack.  
  
* <a id="componentcontroller#fields#selectstack"></a>**selectStack** (string)
    * WRITE-ONLY. Accepts stack ID.   
If there is a stack with such ID, ComponentController switches to it and makes it active. Otherwise does nothing.  
  
* <a id="componentcontroller#fields#activestack"></a>**activeStack** (string)
    * READ-ONLY. ID of the active stack.  

#### <a id="componentcontroller#functions"></a>Functions
* <a id="componentcontroller#functions#show"></a>**show**
    * Function that has to be called when you want to add view to view stack, and set focus to view* <a id="componentcontroller#functions#setup"></a>**setup**
    * A function that allows to set up the view and initiate related content manager prior adding it to the stack with "show" function.   
This is optional as the view gets set up automatically behind the scenes once added to the stack.

### <a id="componentcontroller#sample"></a>Sample of usage:
    ' in Scene context in channel
    m.top.ComponentController.callFunc("show", {
        view: View
        setFocus: true
    })
 

___

## <a id="basescene"></a>BaseScene
### <a id="basescene#extends"></a>Extends: Scene
### <a id="basescene#description"></a>Description
Developer should extend BaseScene and work in it's context.  
Function show(args) should be overrided in channel.

### <a id="basescene#interface"></a>Interface
#### <a id="basescene#fields"></a>Fields
  
* <a id="basescene#fields#componentcontroller"></a>**ComponentController** (node)
    * Reference to ComponentController node that is created and used inside library  
    * Read Only  
* <a id="basescene#fields#buttonbar"></a>**buttonBar** (node)
    * Reference to the button bar node (default ButtonBar is created by the SGDEX)  
  
* <a id="basescene#fields#exitchannel"></a>**exitChannel** (bool)
    * Exits channel if set to true  
    * Write Only  
* <a id="basescene#fields#theme"></a>**theme** (assocarray)
    * Theme is used to customize the appearance of all SGDEX views.  
For common fields see [SGDEXComponent](#sgdexcomponent)  
For view specific theming, see each view's documentation  
<b>Theme can be set to several levels</b>  
<b>Any view:</b>  
<code>  
scene.theme = {  
&nbsp;&nbsp;global: {  
&nbsp;&nbsp;&nbsp;&nbsp;textColor: "FF0000FF"  
&nbsp;&nbsp;}  
}  
</code>  
Set's all text colors to red  
<b>Type of view</b>  
<code>  
scene.theme = {  
&nbsp;&nbsp;gridView: {  
&nbsp;&nbsp;&nbsp;&nbsp;textColor: "FF0000FF"  
&nbsp;&nbsp;}  
}  
</code>  
Set's all grids text color to red  
<b>Instance specific:</b>  
use view's theme field to set it's theme  
<code>  
view = CreateObject("roSGNode", "GridView")  
view.theme = {  
&nbsp;&nbsp;textColor: "FF0000FF"  
}  
</code>  
this grid will only have text color red  
All theme fields are combined and used by view when created, so you can set  
<code>  
scene.theme = {  
&nbsp;&nbsp;   global: {  
&nbsp;&nbsp;&nbsp;&nbsp;textColor: "FF0000FF"  
&nbsp;&nbsp;}  
&nbsp;&nbsp;gridView: {  
&nbsp;&nbsp;&nbsp;&nbsp;textColor: "00FF00FF"  
&nbsp;&nbsp;}  
}  
view1 = CreateObject("roSGNode", "GridView")  
view2 = CreateObject("roSGNode", "GridView")  
view.2theme = {  
&nbsp;&nbsp;textColor: "FFFFFFFF"  
}  
detailsView= CreateObject("roSGNode", "DetailsView")  
</code>  
In this case  
view1 - will have texts in 00FF00FF  
view2 - will have FFFFFFFF  
detailsView - will take textColor from global and it will be FF0000FF  
  
* <a id="basescene#fields#updatetheme"></a>**updateTheme** (assocarray)
    * Field to update themes by passing the config  
Structure of config is same as for [theme](#basescene) field.  
You should only pass fields that should be updated not all theme fields.  
Note. if you want to change a lot of fields change them with as smaller amount of configs as you can, it wouldn't redraw views too often then.  


### <a id="basescene#sample"></a>Sample of usage:
    // MainScene.xml
    <?xml version="1.0" encoding="UTF-8"?>
    <component name="MainScene" extends="BaseScene" >
        <script type="text/brightscript" uri="pkg:/components/MainScene.brs" />
    </component>

    // MainScene.brs
    sub Show(args)
        homeGrid = CreateObject("roSGNode", "GridView")
        homeGrid.content = GetContentNodeForHome() ' implemented by developer
        homeGrid.ObserveField("rowItemSelected","OnGridItemSelected")
        'this will trigger job to show this View
        m.top.ComponentController.callFunc("show", {
            view: homeGrid
        })
    end sub



___

