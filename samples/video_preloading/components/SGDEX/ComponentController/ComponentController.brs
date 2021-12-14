' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.stacks = []
    viewManager = CreateObject("roSGNode", "ViewManager")
    m.top.InsertChild(viewManager, 0)

    ' initialize button bar container
    m.bbContainer = m.top.FindNode("buttonBarContainer")
    m.bbRendererId = "contentButtonBar"

    m.top.observeField("addStack", "OnAddStackChanged")
    m.top.observeField("removeStack", "OnRemoveStackChanged")
    m.top.observeField("selectStack", "OnSelectStackChanged")
    m.top.addStack = "default"

    m.top.observeField("allowCloseChannelOnLastView","OnAllowCloseChannel")
    m.top.allowCloseChannelOnLastView = true

    m.preloadMediaView = invalid
end sub

' A callback for handing button bar change
sub OnButtonBarChanged(event as Object)
    newButtonBar = event.GetData()
    if newButtonBar = invalid
        ' don't allow to invalidate m.top.buttonBar, fall back to the existing
        ' button bar cached to m.buttonBar
        m.top.buttonBar = m.buttonBar
    else if m.buttonBar = invalid or not newButtonBar.IsSameNode(m.buttonBar)
        ' got a new button bar, need to replace the value cached in m.buttonBar
        m.buttonBar = newButtonBar
        SetButtonBarOptionalFields(newButtonBar)
        
        ' put it to the bbContainer
        m.bbContainer.RemoveChildIndex(0)
        m.bbContainer.AppendChild(newButtonBar)
        
        ' assign content manager and initiate content loading
        m.bbContentManager = CreateObject("roSGNode", "ContentManagerDetails")
        m.bbContentManager.configFieldName = "handlerConfigButtonBar"
        m.bbContentManager.contentRendererId = m.bbRendererId
        m.bbContentManager.CallFunc("setView", newButtonBar)
        m.top.buttonBar.wasShown = true
    end if
end sub

' A helper function to initialize button bar optional fields
sub SetButtonBarOptionalFields(buttonBar as Object)
    fieldsMap = {
        alignment: {default: "top", type: "string" }
        overlay: {default: false, type: "boolean" }
        renderOverContent: {default: false, type: "boolean" }
        autoHide: {default: false, type: "boolean" }
    }

    for each item in fieldsMap.Items()
        key = item.key
        value = item.value.default
        fieldType = item.value.type
        if buttonBar.HasField(key) = false
            buttonBar.AddField(key, fieldType, true)
            buttonBar[key] = value
        end if
    end for
end sub

' A helper function to handle setting focus to the button bar properly
sub FocusButtonBar()
    if m.top.buttonBar <> invalid and m.bbRendererId <> invalid
        bbRenderer = m.top.buttonBar.FindNode(m.bbRendererId)
        if bbRenderer <> invalid
            ' button bar has renderer node? -> set focus to it
            bbRenderer.SetFocus(true)
        else
            ' otherwise set focus to the button bar itself
            m.top.buttonBar.SetFocus(true)
        end if
    end if
end sub

function Setup(config as Object)
    if m.preloadMediaView <> invalid and m.preloadMediaView.contentManager <> invalid
        m.preloadMediaView.contentManager = invalid
        m.preloadMediaView.RemoveField("contentManager")
    end if
    m.preloadMediaView = invalid

    view = config.view
    if view.contentManager = invalid
        contentManager = InitContentManagerHelper(config)
        if contentManager <> invalid
            contentManager.Parent = m.top.getparent()
            contentManager.callfunc("setView", view)
            view.Update({contentManager: contentManager}, true)
            if contentManager.subtype() = "ContentManagerMedia"
                m.preloadMediaView = view
            end if
            contentManager.control = "start"
        end if
    end if
end function

function Show(config as Object)
    if GetInterface(config, "ifAssociativeArray") = invalid or config.view = invalid then
        ? "Error: Component controller, received wrong config"
        return invalid
    end if

    View = config.view

    data = {}

    if config.setFocus = invalid
        data.setFocus = true
    else if type(config.setFocus) = "roBoolean"
        data.setFocus = config.setFocus
    else
        ? "Error: Component controller, received wrong config. Field setFocus must be Boolean."
    end if

    contentManager = view.contentManager
    if contentManager <> invalid
        data.contentManager = contentManager
        view.contentManager = invalid
        view.RemoveField("contentManager")
    else
        contentManager = InitContentManagerHelper(config)
        if contentManager <> invalid
            contentManager.Parent = m.top.getparent()
            contentManager.callFunc("setView", View)
            data.contentManager = contentManager
        end if
    end if

    m.top.ViewManager.callFunc("runProcedure", {
        fn: "addView"
        fp: [View, data]
    })

    buttonBar = m.buttonBar
    if data.setFocus = false and buttonBar.visible and not buttonBar.IsInFocusChain()
        FocusButtonBar()
    end if
    if contentManager <> invalid then
        contentManager.control = "start"
    end if

    'do other stuff for proper registering and unregistering events
end function

function InitContentManagerHelper(config) as Object
    View = config.view
    contentManager = config.contentManager

    subTypesSupported = {
        GridView: "ContentManager",
        SearchView: "ContentManager",
        TimeGridView: "ContentManagerTimeGrid",
        MediaView: "ContentManagerMedia",
        DetailsView: "ContentManagerDetails"
    }

    cmTypesSupported = {
        grid: {
            nodeType: "ContentManager"
            configName: "HandlerConfigGrid"
        }
        timegrid: {
            nodeType: "ContentManagerTimeGrid"
            configName: "HandlerConfigTimeGrid"
        }
        media: {
            nodeType: "ContentManagerMedia"
            configName: "HandlerConfigMedia"
        }
        details: {
            nodeType: "ContentManagerDetails"
            configName: "HandlerConfigDetails"
        }
    }

    subtype = View.subtype()
    parentType = View.parentSubtype(View.subtype())
    cmType = View.contentManagerType
    ' Create content manager for SGDEX views
    if subTypesSupported[subtype] <> invalid
        contentManager = CreateObject("roSgNode", subTypesSupported[subtype])
        if subtype = "SearchView"
            contentManager.configFieldName = "HandlerConfigSearch"
        end if
    ' else create content manager for custom view if it' supported
    else if cmType <> invalid and GetInterface(cmType, "ifString") <> invalid and cmTypesSupported[cmType] <> invalid
        contentManager = CreateObject("roSgNode", cmTypesSupported[cmType]["nodeType"])
        contentManager.configFieldName = cmTypesSupported[cmType]["configName"]
    else if cmType <> invalid and cmTypesSupported[cmType] = invalid
        print "[SGDEX] Content Manager was not created. Please specify correct value for contentManagerType view interface."
    else
        print "[SGDEX] Content Manager was not created"
    end if

    return contentManager
end function

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
        buttonBar = m.buttonBar
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
        if (key = "back" or (key = "up" and buttonBar.alignment = "top")) and currentView.Subtype() = "MediaView" and currentView.mode = "audio" then
            return handleMediaViewBBKeyEvents(currentView, buttonBar, key)
        else if key = "back"
            if buttonBar.isInFocusChain()
                return closeView()
            else if currentView.isInFocusChain()
                FocusButtonBar()
                return true
            end if
        else if buttonBar.alignment = "top"
            if key = "up" and currentView.isInFocusChain()
                FocusButtonBar()
                return true
            else if key = "down" and buttonBar.isInFocusChain()
                currentView.SetFocus(true)
                return true
            end if
        else if buttonBar.alignment = "left"
            if key = "left" and currentView.isInFocusChain()
                if currentView.Subtype() <> "MediaView" and currentView.isContentList <> true
                    FocusButtonBar()
                    return true
                end if
            else if key = "right" and buttonBar.isInFocusChain()
                currentView.SetFocus(true)
                return true
            end if
        end if
    end if
    return false
end function

function handleMediaViewBBKeyEvents(mediaView as Object, buttonBar as Object, key as String) as Boolean
    isAbleToFocusBB = mediaView.state = "paused" or mediaView.state = "buffering" or buttonBar.renderOverContent
    if buttonBar.visible and mediaView.isInFocusChain() and isAbleToFocusBB then
        FocusButtonBar()
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

        buttonBar = m.buttonBar
        isButtonBarFocused = buttonBar <> invalid and buttonBar.visible and buttonBar.isInFocusChain()
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
