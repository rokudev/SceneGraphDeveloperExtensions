'------------------------------------------------------------------------------
'           Helper functions
'------------------------------------------------------------------------------

' Helper function - displays usename dialog with "Next" and "Cancel" buttons.
' Only non-empty username is allowed.
' @param username [String] default username to display
' @return [String] username (empty if user pressed "Cancel")
function UserPass__ShowUsernameDialog(username = "" as String) as String
    result = ""

    port = CreateObject("roMessagePort")

    dialog = CreateObject("roSGNode", "KeyboardDialog")
    dialog.title = tr("Please enter your username")
    dialog.text = username
    dialog.buttons = [
        tr("Next")
        tr("Cancel")
    ]
    dialog.ObserveField("buttonSelected", port)
    dialog.ObserveField("wasClosed", port)
    m.top.GetScene().dialog = dialog

    while true
        msg = Wait(0, port)
        field = msg.Getfield()

        if field = "buttonSelected"
            buttonIndex = msg.GetData()
            if buttonIndex = 0
                result = dialog.text
                if result.Len() > 0
                    exit while
                else
                    dialog.keyboard.textEditBox.hintText = "Please enter non-empty value"
                end if
            else
                dialog.close = true
            end if
        else if field = "wasClosed"
            exit while
        end if
    end while

    return result
end function

' Helper function - displays password dialog with "Next", "Show password"
' "Hide password" and "Back" buttons. Only non-empty password is allowed.
' @return [String] password (empty if user pressed "Back")
function UserPass__ShowPasswordDialog()
    result = ""

    port = CreateObject("roMessagePort")

    dialog = CreateObject("roSGNode", "KeyboardDialog")
    dialog.title = tr("Please enter your password")
    dialog.keyboard.textEditBox.secureMode = true
    dialog.buttons = [
        tr("Next")
        tr("Show password")
        tr("Hide password")
        tr("Back")
    ]
    dialog.ObserveField("buttonSelected", port)
    dialog.ObserveField("wasClosed", port)
    m.top.GetScene().dialog = dialog

    while true
        msg = Wait(0, port)
        field = msg.Getfield()

        if field = "buttonSelected"
            buttonIndex = msg.GetData()
            if buttonIndex = 0
                result = dialog.text
                if result.Len() > 0
                    dialog.close = true
                else
                    dialog.keyboard.textEditBox.hintText = "Please enter non-empty value"
                end if
            else if buttonIndex = 1
                dialog.keyboard.textEditBox.secureMode = false
            else if buttonIndex = 2
                dialog.keyboard.textEditBox.secureMode = true
            else
                exit while
            end if
        else if field = "wasClosed"
            exit while
        end if
    end while

    return result
end function

function UserPass__PrepopulateUserEmail(needPrepopulate as Boolean)
    result = "" 'don't prepulate by default
    if needPrepopulate
        port = CreateObject("roMessagePort")
        store = m.top.CreateChild("ChannelStore")
        store.ObserveField("userData", port)
        store.requestedUserData = "email"
        store.command = "getUserData"
        ' wait on user data object
        while true
            event = Wait(0, port)
            if event <> invalid
                userData = event.getData()
                store.UnobserveField("userData")

                userEmail = ""
                if userData <> invalid
                    userEmail = userData.email
                end if

                return userEmail
            end if
        end while
    end if
    return result
end function

'------------------------------------------------------------------------------
'           Handler functions invoked by EntitlementView
'------------------------------------------------------------------------------

' Initiates silent entitlement checking (no UI)
sub UserPass__SilentCheckAuthentication()
    isAuthenticated = CheckAuthentication()
    if isAuthenticated
        ' authenticated? -> remove handler config
        m.top.content.handlerConfigEntitlement = invalid
    end if
    m.top.view.isAuthenticated = isAuthenticated
end sub

' Initiates silent de-authentication (no UI)
sub UserPass__SilentDeAuthenticate()
    isDeAuthenticated = DeAuthenticate()
    if isDeAuthenticated
        ' successfully de-authenticated -> remove handler config
        m.top.content.handlerConfigEntitlement = invalid
    end if
    m.top.view.isAuthenticated = not isDeAuthenticated
end sub

' Initiates authentication flow
sub UserPass__Authenticate()
    isAuthenticated = false

    while true
        username = m.top.view.username
        if username.Len() = 0
            username = UserPass__PrepopulateUserEmail(m.top.view.prepopulateEmail)
            username = UserPass__ShowUsernameDialog(username)
        end if
        if username.Len() > 0
            password = m.top.view.password
            if password.Len() = 0
                password = UserPass__ShowPasswordDialog()
            end if
            if password.Len() > 0
                dialog = CreateObject("roSGNode", "ProgressDialog")
                dialog.title = tr("Please wait...")
                m.top.GetScene().dialog = dialog

                isAuthenticated = Authenticate(username, password)

                dialog.close = true

                if isAuthenticated
                    ' authentication was successful? -> remove handler config
                    m.top.content.handlerConfigEntitlement = invalid
                end if
                exit while
            end if
        else
            exit while
        end if
    end while

    m.top.view.close = true
    m.top.view.isAuthenticated = isAuthenticated
end sub
