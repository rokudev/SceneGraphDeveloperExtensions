# RCL view stack support
RCL supports out of the box stacking of views. This means that you can add as many views to stack and RCL will handle back button closing of screen and will add support for events when view is:
*   opened
*   closed
*   hidden because next view is displayed 

And manual closing support.

ViewStack is designed to work with any RSG component or RCL view.

Component Controller also has several fields to help in development

        
*   allowCloseChannelOnLastView - If user set this flag channel closes when press back or set close=true on last view 

*   allowCloseLastViewOnBack - If user set this flag the last screen will be closed when user presses back and developer can open another view in wasClosed callback

*   currentView - link to view that is currently shown by ViewStack (This view represents view that is shown by ViewStack, if you show another view without using ViewStack it wouldn't be reflected here)

# Focus handling
View stack handles basic focus when view is opened or restores focus when it's closed.
According to Roku best practices view should handle focus by itself so ViewStack set focus to view like view.setFocus(true).

Your view should implement focus handling as follows:

    sub init()
        m.viewThatHasFocus = m.top.findNode("viewThatHasFocus")
        m.top.observeField("focusedChild","OnFocusChildChange")
    end sub
    
    sub OnFocusChildChange()
        if m.top.isInFocusChain() and not m.viewThatHasFocus.hasFocus() then
            m.viewThatHasFocus.setFocus(true)
        end if
    end sub

Don't set focus to view before adding it to ViewStack as it will set focus to passed view 


# Notes
*   Dialogs are not supported by ViewStack, use scene.dialog field for it

## Samples

### Open new view
If you want to add new view to stack use such code:

    sub Show(args)
        homeGrid = CreateObject("roSGNode", "GridView")
        homeGrid.content = GetContentNodeForHome() ' implemented by user
        
        'This will add your view to stack
        m.top.ComponentController.callFunc("show", {
            view: homeGrid
        })
    end sub 
    

### Receive event when your view get's closed
If you want to be notified when view is closed either manually or by user pressing back observeField wasClosed
    
    sub onShowLoginPage()
        loginView = CreateObject("roSGNode", "MyLoginView")
        loginView.observeField("wasClosed", "onLoginFinished")
        'This will add your view to stack
        m.top.ComponentController.callFunc("show", {
            view: loginView
        })
    
    end sub
    
    sub onLoginFinished(event as Object)
        loginView = event.getRosgNode()
        
        if loginView.isSuccess then
            ShowVideoPlayer()
        else
            'do your logic
        end if
    end sub
    
### Close view manually
Sometimes you need to close view manually, for example when showing login flow after success login. To do so use close field of view. <b>Note</b> close field is added by ViewStack.

Also you can close any view not only top one.

    sub onShowLoginPage()
        banner = CreateObject("roSGNode", "MyBannerView")
        banner.observeField("wasClosed", "onBannerClosed")
        
        m.timer = CreateObject("roSGNode", "Timer")
        'if user doesn't perform anything close the view
        m.timer.duration = 20
        m.timer.control = "start"
        m.timer.observeField("fire", "closeBanner")
        'This will add your view to stack
        m.top.ComponentController.callFunc("show", {
            view: banner
        })
        m.banner = banner
    end sub
    
    sub closeBanner()
        m.banner.close = true
    end sub
    
    sub onBannerClosed()
        'Show next view
    end sub
    
###### Copyright (c) 2018 Roku, Inc. All rights reserved.
