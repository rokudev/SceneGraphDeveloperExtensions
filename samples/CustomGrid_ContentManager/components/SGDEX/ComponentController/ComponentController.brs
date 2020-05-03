' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.stacks = []
    viewManager = CreateObject("roSGNode", "ViewManager")
    m.top.InsertChild(viewManager, 0)

    m.top.observeField("addStack", "OnAddStackChanged")
    m.top.observeField("removeStack", "OnRemoveStackChanged")
    m.top.observeField("selectStack", "OnSelectStackChanged")
    m.top.addStack = "default"

    m.top.observeField("allowCloseChannelOnLastView","OnAllowCloseChannel")
    m.top.allowCloseChannelOnLastView = true
end sub

function Show(config as Object)
    if GetInterface(config, "ifAssociativeArray") = invalid or config.view = invalid then
        ? "Error: Component controller, received wrong config"
        return invalid
    end if

    View = config.view
    contentManager = config.contentManager

    data = {}

    if config.setFocus = invalid
        data.setFocus = true
    else if type(config.setFocus) = "roBoolean"
        data.setFocus = config.setFocus
    else
        ? "Error: Component controller, received wrong config. Field setFocus must be Boolean."
    end if

    subTypesSupported = { GridView: "", SearchView: "" }
    cmTypesSupported = { grid: "" }

    subtype = View.subtype()
    parentType = View.parentSubtype(View.subtype())

    createContentManager = false
    if subtype <> invalid and subTypesSupported[subtype] <> invalid then
        createContentManager = true
    else if parentType <> invalid and subTypesSupported[parentType] <> invalid then
        createContentManager = true
    else if View.contentManagerType <> invalid
        cmType = View.contentManagerType
        createContentManager = (GetInterface(cmType, "ifString") <> invalid and cmTypesSupported[cmType] <> invalid)
    end if

    if createContentManager then
        if contentManager = invalid then contentManager = CreateObject("roSgNode", "ContentManager")
        ' attach this View to this content manager
        contentManager.Parent = m.top.getparent()
        if subtype = "SearchView"
            contentManager.configFieldName = "HandlerConfigSearch"
        else if View.contentManagerType <> invalid
            contentManager.configFieldName = GetConfigFieldName(View.contentManagerType)
        end if

        contentManager.callFunc("setView", View)
        data.contentManager = contentManager
    end if

    m.top.ViewManager.callFunc("runProcedure", {
        fn: "addView"
        fp: [View, data]
    })

    buttonBar = m.top.GetScene().buttonBar
    if data.setFocus = false and buttonBar.visible
        if not buttonBar.IsInFocusChain()
            buttonBar.SetFocus(true)
        else if subtype = "MediaView" and view.mode = "audio"
            timer = m.top.CreateChild("Timer")
            timer.duration = 0.001
            timer.repeat = false
            timer.control = "start"
            timer.ObserveField("fire", "OnMediaTimerFired")
        end if
    end if

    if contentManager <> invalid then
        contentManager.control = "start"
    end if

    'do other stuff for proper registering and unregistering events
end function

function GetConfigFieldName(cmType = "grid" as String) as String
    return "HandlerConfig" + UCase(Left(cmType, 1)) + LCase(Mid(cmType, 2))
end function

sub OnMediaTimerFired()
    buttonBar = m.top.GetScene().buttonBar
    buttonBar.SetFocus(true)
end sub

sub OnCurrentViewChange()
    stack_id = m.top.activeStack
    stack = m.stacks.Peek()
    if stack <> invalid
        if stack_id = stack.id
            m.top.currentView = stack.currentView
        end if
    end if
end sub

sub OnAllowCloseChannel(event as Object)
    allowCloseChannel = event.getData()
    ' need to pass this flag to View stack; it will set scene.exitChannel to true if no Views left
    m.top.ViewManager.allowCloseChannelWhenNoViews = allowCloseChannel
end sub

function onkeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press
        buttonBar = m.top.findNode("buttonBar")
        if buttonBar.visible
            handled = handleButtonBarKeyEvents(buttonBar, key)
        else if key = "back"
            handled = closeView()
        end if
    end if

    return handled
end function

function handleButtonBarKeyEvents(buttonBar as Object, key as String) as Boolean
    ' handle switch focus between the ButtonBar and a showed view
    currentView = m.top.currentView
    if currentView <> invalid
        if (key = "back" or key = "up") and currentView.Subtype() = "MediaView" then
            return handleMediaViewBBKeyEvents(currentView, buttonBar, key)
        else if key = "back" and buttonBar.isInFocusChain()
                return closeView()
        else if  key = "up" and currentView.isInFocusChain()
            buttonBar.SetFocus(true)
            return true
        else if key = "back" and currentView.isInFocusChain()
            buttonBar.SetFocus(true)
            return true
        else if key = "down" and buttonBar.isInFocusChain()
            currentView.SetFocus(true)
            return true
        else if key = "back" and buttonBar.isInFocusChain()
            return closeView()
        end if
    end if
    return false
end function

function handleMediaViewBBKeyEvents(mediaView as Object, buttonBar as Object, key as String) as Boolean
    isAbleToFocusBB = mediaView.state = "paused" or mediaView.state = "buffering" or buttonBar.renderOverContent
    if buttonBar.visible and mediaView.isInFocusChain() and isAbleToFocusBB then
        buttonBar.SetFocus(true)
        return true
    else if key <> "up"
        return closeView()
    end if
end function

' handles closing View in View stack
' if no View left, closes scene and exits channel
function closeView() as Boolean
    ' developer should receive back button when all Views are closed

    ' save flags locally because developer can change it in wasClosed callback
    allowCloseLastViewOnBack = m.top.allowCloseLastViewOnBack
    allowCloseChannelOnLastView = m.top.allowCloseChannelOnLastView

    result = m.top.ViewManager.ViewCount > 1

    ' allowCloseLastViewOnBack is checked here because if it is set to true we need to close the View even it is last View in stack
    if result or allowCloseLastViewOnBack
        m.top.ViewManager.callFunc("runProcedure", {
            fn: "closeView"
            fp: ["", {}]
        })

        ' result is bool if count of Views is 2 or more, so View in stach is closed and back button successfully handled
        if result then return true

        ' if last View is closed check if developer opens a new one in wasClosed callback, if so, back is handled
        if allowCloseLastViewOnBack and not allowCloseChannelOnLastView
            if m.top.ViewManager.ViewCount > 0 then return true
        end if

        if allowCloseLastViewOnBack then
            return false
        end if
    end if
    return not allowCloseChannelOnLastView
end function

sub OnAddStackChanged(event as Object)
    stack_id = event.getData()
    if stack_id <> ""
        index = FindElementIndexInArray(m.stacks, stack_id)
        if index > -1
            ?"SGDEX: STACK """stack_id""" ALREADY EXISTS"
            MoveElementToTail(m.stacks, index)
            ReplaceCurrentViewManager(m.stacks.Peek())
        else
            ViewManager = CreateObject("roSGNode", "ViewManager")
            ViewManager.ObserveField("currentView", "OnCurrentViewChange")
            ViewManager.allowCloseChannelWhenNoViews = m.top.allowCloseChannelOnLastView
            ViewManager.id = stack_id
            m.stacks.Push(ViewManager)
            ReplaceCurrentViewManager(m.stacks.Peek())
        end if
    end if
end sub

sub OnRemoveStackChanged(event as Object)
    stack_id = event.getData()
    if stack_id <> ""
        index = FindElementIndexInArray(m.stacks, stack_id)
        if index > -1
            removeStack = m.stacks[index]
            result = false
            if removeStack.id <> "default"
                result = m.stacks.Delete(index)
            end if
            if result
                stack = m.stacks.Peek()
                if stack <> invalid
                    ReplaceCurrentViewManager(stack)
                end if
            end if
        else
            ?"SGDEX: STACK """stack_id""" NOT FOUND"
        end if
    end if
end sub

sub OnSelectStackChanged(event as Object)
    stack_id = event.getData()
    if stack_id <> ""
        index = FindElementIndexInArray(m.stacks, stack_id)
        if index > -1
            MoveElementToTail(m.stacks, index)
            ReplaceCurrentViewManager(m.stacks.Peek())
            m.top.currentView = m.top.ViewManager.currentView
        else
            ?"SGDEX: STACK """stack_id""" NOT FOUND "
        end if
    end if
end sub

sub ReplaceCurrentViewManager(viewManager as Object)
    if viewManager <> invalid
        m.top.activeStack = viewManager.id
        m.top.ViewManager = viewManager
        if viewManager.id <> m.top.GetChild(0).id ' to avoid replacing the node by itself
            m.top.ReplaceChild(viewManager, 0)
        end if

        buttonBar = m.top.findNode("buttonBar")
        isButtonBarFocused = buttonBar.visible and buttonBar.isInFocusChain()
        ' if buttonBar is focused and active stack is changed
        ' keep focus on BB
        if not isButtonBarFocused
            if  m.top.ViewManager.currentView <> invalid
                m.top.ViewManager.currentView.setFocus(true)
            else
                m.top.ViewManager.setFocus(true)
            end if
        end if
    end if
end sub

sub MoveElementToTail(array As Object, index as Integer)
    item = array[index]
    if item <> invalid
        array.Delete(index)
        array.Push(item)
    end if
end sub

function FindElementIndexInArray(array As Object, value As Object) As Integer
    for i = 0 to (array.Count() - 1)
        compareValue = array[i]
        if compareValue <> invalid
            if lcase(compareValue.id) = lcase(value)
                return i
            end if
        end if
    end for
    return -1
end function
