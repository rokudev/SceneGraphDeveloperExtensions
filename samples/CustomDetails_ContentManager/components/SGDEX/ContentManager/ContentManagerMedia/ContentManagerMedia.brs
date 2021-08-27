' Copyright (c) 2020 Roku, Inc. All rights reserved.

sub Init()
    'InitContentGetterValues()
end sub

' this function is called outside to set view to this content manager
' this is done so that view doesn' t even have to know about content manager
sub setView(view as Object)
    m.topView = view
    if m.topView <> invalid then
        SetOptionalFields()
        SetUpContentMedia()

        ' Perform content setting/loading actions when content was set
        view.ObserveField("content", "OnContentSet")

        ' Start playing video when corresponding control is set
        view.ObserveField("control", "OnControlSet")

        ' Set focus on media when view was shown
        view.ObserveField("wasShown", "OnMediaWasShown")

        ' jumpToItem - field to navigate between items in playlist
        ' with most cases it will be set once, before MediaView is shown
        view.ObserveField("jumpToItem", "OnJumpToItem")

        ' When MediaView is closed we need to stop Media Node,
        ' Stop RAF task if it exist
        view.ObserveField("wasClosed", "OnMediaWasClosed")

        view.ObserveField("preloadContent", "OnPreloadContent")

        ' When is mode changing we need to recreate mediaNode
        view.ObserveField("mode", "OnMediaModeChange")

        ' When content is loaded and changing isContentList field we need to recreate mediaNode
        view.ObserveField("isContentList", "OnIsContentListChange")

        view.ObserveField("disableScreenSaver", "OnDisableScreenSaver")

        view.ObserveFieldScoped("focusedChild", "OnFocusedChildChange")

        view.ObserveFieldScoped("seek", "OnSeekChanged")

        view.ObserveFieldScoped("shuffle", "OnContentShuffled")

        view.ObserveFieldScoped("buttons", "OnAudioButtonContentChanged")

        view.ObserveFieldScoped("repeatAll", "OnRepeatAllChanged")

        view.ObserveFieldScoped("enableTrickPlay", "OnTrickPlayModeChanged")

        ' AA to pass appropriate states on view top
        m.internalToViewStateAA = {
            ' internalState: MediaView state
            ' if internal state is not specified
            ' then interface state won't change
            none: ""
            buffering: "buffering"
            playing: "playing"
            error: "error"
            paused: "paused"
            stopped: "stopped"
            finished: "finished"
        }

        ' AA to track transtitions between states and handle actions on it
        m.transitions = {
            ' previousState_currentState: FunctionHandler
            none_contentLoading: LoadContent
            none_contentLoaded: OnContentLoaded
            none_completed: OnCompletedPlayback ' user set content to invalid
            contentLoading_contentLoaded: OnContentLoaded
            contentLoading_completed: OnCompletedPlayback  ' user set content to invalid
            contentLoading_endcardClose: OnEndcardCloseTransition
            contentLoaded_contentLoading: LoadContent ' playlist items have their own CH to load content
            contentLoaded_buffering: OnStartBuffering
            contentLoaded_completed: OnCompletedPlayback ' user set content to invalid
            buffering_error: OnErrorState
            buffering_contentLoaded: OnContentLoaded
            buffering_endcardClose: OnEndcardCloseTransition
            buffering_completed: OnCompletedPlayback  ' user set content to invalid
            buffering_playing: OnStartedPlayback
            buffering_finished: ProcessEndState
            playing_contentLoaded: OnContentLoaded
            playing_error: OnErrorState
            playing_completed: OnCompletedPlayback ' user set content to invalid
            playing_paused: OnPausedPlayback
            paused_playing: OnResumedPlayback
            paused_finished: ProcessEndState
            playing_finished: ProcessEndState
            stopped_error: OnErrorState
            stopped_completed: OnCompletedPlayback ' user set content to invalid
            paused_completed: OnCompletedPlayback ' user set content to invalid
            finished_completed: OnCompletedPlayback
            finished_endcardLoaded: OnFinishedEndcardLoadedTransition
            finished_error: OnErrorState
            completed_contentLoaded: OnContentLoaded ' there is next item in playlist
            completed_buffering: OnStartBuffering
            endcardLoaded_endcardVisible: OnEndcardVisibleTransition
            endcardVisible_endcardClose: OnEndcardCloseTransition
            endcardVisible_contentLoaded: OnContentLoaded
            endcardClose_completed: OnEndcardCloseCompletedTransition
            contentLoaded_StartRAFTask: OnStartRAFTaskTransition
            buffering_StartRAFTask: OnStartRAFTaskTransition
            StartRAFTask_buffering: OnStartBuffering
            RAFSuccess_RAFClose: OnRAFCloseTransition
            finished_RAFClose: OnRAFCloseTransition
            StartRAFTask_RAFClose: OnRAFCloseTransition
            StartRAFTask_RAFExit: OnRAFExitTransition
            RAFClose_finished: ProcessEndState
            RAFplaying_RAFerror: OnErrorState
        }

        m.buttonBar = view.getScene().buttonBar
        m.isButtonBarVisible = m.buttonBar.visible
        m.renderOverContent = m.buttonBar.renderOverContent
        m.isAutoHideMode = m.buttonBar.autoHide

        CreateStateMachineNode() ' node to handle processing all states and their transitions
        CreateMediaNode()
        CreateSpinner()

        ' PRIVATE fields for library managers
        m.ContentManager_id = 0
        m.debug = false
        m.endcardContent = invalid
        m.mediaModeSet = (m.topView.mode <> "video")
        m.repeatButtonSelected = false
        m.trickplayVisible = true
        m.endcardAvailable = false
        m.NPNButtonFocused = 0
        m.lastChangedField = ""
    else
        ? "ERROR, Content Manager, received invalid view"
    end if
end sub

sub CreateSpinner()
    m.spinnerGroup = m.topView.FindNode("spinnerGroup")
    if m.spinnerGroup = invalid
        m.spinnerGroup = m.topView.CreateChild("LayoutGroup")
        m.spinnerGroup.SetFields({
            id: "spinnerGroup"
            translation: "[640,360]"
            horizAlignment: "center"
            vertAlignment: "center"
            visible: "false"
        })
        m.spinner = m.spinnerGroup.CreateChild("BusySpinner")
        m.spinner.SetFields({
            id:"spinner"
            uri:  "pkg:/components/SGDEX/Images/loader.png"
            visible: "true"
        })
    else
        m.spinner = m.topView.FindNode("spinner")
    end if
end sub

sub SetOptionalFields()
    fieldsMap = {
        isContentList: {default: true, type: "boolean" }
        mode: {default: "video", type: "string" }
        seek: {default: -1, type: "integer" }
        preloadContent: {default: false, type: "boolean" }
        currentIndex: {default: -1, type: "integer" }
        state: {default: "", type: "string" }
        position: {default: 0, type: "integer" }
        duration: {default: 0, type: "integer" }
        currentItem: {default: invalid, type: "node" }
        enableTrickPlay: {default: true, type: "boolean" }
        repeatOne: {default: false, type: "boolean" }
        repeatAll: {default: false, type: "boolean" }
        shuffle: {default: false, type: "boolean" }
        endcardCountdownTime: {default: 10, type: "integer" }
        alwaysShowEndcards: {default: false, type: "boolean" }
        endcardItemSelected: {default: invalid, type: "node" }
        wasShown: {default: false, type: "boolean" }
        wasClosed: {default: false, type: "boolean" }
        disableScreenSaver: {default: false, type: "boolean" }
        buttons: {default: invalid, type: "node" }
        npn: {default: invalid, type: "node" }
        RafTask: {default: invalid, type: "node" }
        endcardView: {default: invalid, type: "node" }
        media: {default: invalid, type: "node" }
        currentRAFHandler: {default: invalid, type: "assocarray" }
    }

    for each item in fieldsMap.Items()
        key = item.key
        value = item.value.default
        fieldType = item.value.type
        if m.topView.HasField(key) = false
           m.topView.AddField(key, fieldType, true)
           m.topView[key] = value
        end if
    end for
end sub

sub SetUpContentMedia()
    m.contentMedia = GetCustomViewContentMedia()
    if m.contentMedia <> invalid
        m.avoidResetingFields = {
            content: "content"
            isContentList: "isContentList"
            control: "control"
            seek: "seek"
            enableTrickPlay: "enableTrickPlay"
            loop: "repeatAll"
            disableScreenSaver: "disableScreenSaver"
        }
        fields = m.contentMedia.GetFields()
        for each field in fields
            if field = "focusedChild"
                m.contentMedia.ObserveFieldScoped(field, "OnFocusedChildChanged")
            else
                m.contentMedia.ObserveFieldScoped(field, "ProxyToMediaNodeFieldObserver")
            end if
        end for
    end if
end sub

' Set focus to internal video node if developer's proxy node was focused
sub OnFocusedChildChanged()
    if m.topView.media <> invalid
        m.topView.media.SetFocus(m.contentMedia.IsInFocusChain() = true)
    end if
end sub

' Content manager field has changed
' This is to control content manager loading process
sub onControlChanged(event as Object)
    actions = {
        start: InitPlayback
    }
    data = event.GetData()

    if data <> invalid and actions[data] <> invalid then
        functionToRun = actions[data]
        FunctionToRun()
    end if
end sub

sub OnConfigFieldNameChanged()
    if m.top.configFieldName <> ""
        m.Handler_ConfigField = m.top.configFieldName
    end if
end sub

' Invoke observers of required fields
sub InitPlayback()
    if m.topView <> invalid
        if m.contentMedia <> invalid
            if m.contentMedia.content <> invalid
                m.topView.content = m.contentMedia.content
            else
                OnContentSet()
            end if
            OnJumpToItem()
            if m.topView.control <> "play" and m.topView.control <> "prebuffer"
                if m.contentMedia.HasField("control")
                    if m.contentMedia.control <> "none"
                        m.topView.control = m.contentMedia.control
                    else
                        m.contentMedia.control = m.topView.control
                        OnControlSet()
                    end if
                else
                    OnControlSet()
                end if
            end if
            if m.contentMedia.HasField("enableTrickPlay")
                if m.contentMedia.enableTrickPlay <> true
                    m.topView.enableTrickPlay = m.contentMedia.enableTrickPlay
                else
                    m.contentMedia.enableTrickPlay = m.topView.enableTrickPlay
                end if
            end if
            if m.contentMedia.HasField("loop")
                if m.contentMedia.loop <> false
                    m.topView.repeatAll = m.contentMedia.loop
                else
                    m.contentMedia.loop = m.topView.repeatAll
                end if
            end if
            if m.contentMedia.HasField("disableScreenSaver")
                if m.contentMedia.disableScreenSaver <> false
                    m.topView.disableScreenSaver = m.contentMedia.disableScreenSaver
                else
                    m.contentMedia.disableScreenSaver = m.topView.disableScreenSaver
                end if
            end if
        else
            OnContentSet()
            OnJumpToItem()
            if m.topView.control <> "play" and m.topView.control <> "prebuffer"
                OnControlSet()
            end if
        end if
    end if
end sub

' This is a helper function that returns contentMedia (if any) of the custom media view.
' If the view is native MediaView or there is no contentMedia, returns invalid
function GetCustomViewContentMedia() as Object
    result = invalid
    ' is the view a custom/non-native media?
    if m.topView.contentManagerType <> invalid and m.topView.contentManagerType = "media"
        result = m.topView.FindNode("contentMedia")
    end if
    return result
end function

sub OnFocusedChildChange()
    if m.topView.media <> invalid
        customEndcardLayout = m.topView.FindNode("endcardLayout")
        isCustomEndcard = customEndcardLayout <> invalid and customEndcardLayout.visible
        isNativeEndcard = m.endcardAvailable
        isEndcard = isCustomEndcard or isNativeEndcard
        ' Check if endcard isn't shown to avoid focus losting
        if m.topView.wasShown and not isEndcard
            if GetCurrentMode() = "video" and m.isButtonBarVisible
                if m.renderOverContent    ' renderOverContent = true
                    if m.isAutoHideMode    ' renderOverContent = true && autoHide = true
                        if m.trickplayVisible
                            ' show buttonBar if playback paused || trickplayVisible
                            m.buttonBar.opacity = 1.0
                        else
                            ' hide buttonBar hint of playback is running
                            m.buttonBar.opacity = 0.0
                        end if
                    else    ' renderOverContent = true && autoHide = false
                        ' show buttonBar over playback
                        m.buttonBar.opacity = 1.0
                    end if
                else    ' renderOverContent = false
                    if m.trickplayVisible or m.topView.state = "paused"
                        ' show buttonBar if playback paused or trickplay visible
                        m.buttonBar.opacity = 1.0
                    else
                        ' hide buttonBar if playback is running
                        m.buttonBar.opacity = 0.0
                    end if
                end if
                m.topView.media.setFocus(true)
            end if
        else if isEndcard ' Handle endcardView focuses
            if m.isButtonBarVisible ' safe restoring buttonBar visibility
                m.buttonBar.visible = true
            end if
            if isCustomEndcard and customEndcardLayout.IsInFocusChain() = false
                customEndcardLayout.SetFocus(true)
            else if isNativeEndcard
                m.topView.endCardView.SetFocus(true)
            end if
            m.buttonBar.opacity = 1.0 ' show buttonBar over endcardView
        end if
        if m.buttonBar.IsInFocusChain() and m.isButtonBarVisible and not m.topView.IsInFocusChain()
            ' if m.buttonBar is focused  -  make it visible
            m.buttonBar.opacity = 1.0
        end if
        if GetCurrentMode() = "audio" and m.isButtonBarVisible
            m.topView.media.setFocus(true)
        end if
    end if
end sub

' ************* Creating and clearing functions *************

sub CreateMediaNode()
    m.isBookmarkHandlerCreated = false
    mode = m.topView.mode
    isCustomView = (m.topView.HasField("contentManagerType") = true)

    if mode = "video"
        video = CreateObject("roSGNode", "Video")
        if isCustomView
            m.topView.InsertChild(video, 0)
        else
            m.topView.AppendChild(video)
        end if
        video.width = "1280"
        video.height = "720"
        video.translation = "[0,0]"
        InitMediaWithContentMediaFields(video)
        video.id = "video"
        video.disableScreenSaver = m.topView.disableScreenSaver
        video.enableUI = false
        video.ObserveFieldScoped("trickPlayBarVisibilityHint", "OnPlayBarVisibilityHintChanged")
        video.ObserveFieldScoped("retrievingBarVisibilityHint", "OnPlayBarVisibilityHintChanged")
        m.topView.media = video
    else if mode = "audio"
        if isCustomView
            audio = CreateObject("roSGNode", "Video")
            m.topView.InsertChild(audio, 0)
        else
            m.topView.npn = m.topView.viewContentGroup.createChild("NowPlayingView")
            audio = CreateObject("roSGNode", "CustomAudioNode")
            m.topView.AppendChild(audio)
            m.topView.FindNode("background").visible = false
        end if
        audio.width = "1280"
        audio.height = "720"
        audio.translation = "[0,0]"
        audio.enableUI = true
        InitMediaWithContentMediaFields(audio)
        audio.id = "audio"
        audio.disableScreenSaver = m.topView.disableScreenSaver
        if m.topView.isContentList
            audio.contentIsPlaylist = m.topView.isContentList
            audio.loop = m.topView.repeatAll
            audio.ObserveFieldScoped("contentIndex","OnAudioContentIndexChanged")
        end if
        audio.ObserveFieldScoped("keyPressed", "OnAudioKeyPressed")
        audio.ObserveFieldScoped("trickPlayBarVisibilityHint", "OnPlayBarVisibilityHintChanged")
        audio.ObserveFieldScoped("retrievingBarVisibilityHint", "OnPlayBarVisibilityHintChanged")
        m.topView.media = audio
    end if
    m.previousMode = mode
    if m.contentMedia <> invalid
        fields = m.topView.media.GetFields()
        for each field in fields
            if field <> "focusedChild" and IsSameType(m.contentMedia[field], m.topView.media[field]) = true
                m.topView.media.ObserveFieldScoped(field, "MediaNodeToProxyFieldObserver")
            end if
        end for
    end if

    m.topView.media.ObserveFieldScoped("position", "OnPositionChanged")
    m.topView.media.ObserveFieldScoped("duration", "OnDurationChanged")
    m.topView.media.ObserveFieldScoped("state", "OnMediaStateChanged") ' to track firmware states
end sub

function GetContentMediaPos()
    children = m.topView.getChildren(-1,0)
    videoNodePos = -1
    for i = 0 to children.Count()-1
        child = children[i]
        if child.id = "contentMedia"
            videoNodePos = i
        end if
    end for
    return videoNodePos
end function

sub InitMediaWithContentMediaFields(node)
    if m.contentMedia = invalid
        return
    end if
    fields = m.contentMedia.GetFields()
    for each field in fields
        if node.HasField(field) and (field <> "clippingRect" or m.previousMode = m.topView.mode) and m.avoidResetingFields[field] = invalid
            newValue = m.contentMedia[field]
            prevValue = node[field]
            if IsSameType(newValue, prevValue) = true and IsSameValue(newValue, prevValue) = false
                node[field] = newValue
            end if
        end if
    end for
end sub

sub MediaNodeToProxyFieldObserver(event as Object)
    field = event.GetField()
    value = event.GetData()
    if m.contentMedia <> invalid and m.contentMedia.HasField(field)
        m.contentMedia[field] = value
    end if
end sub

sub ProxyToMediaNodeFieldObserver(event as Object)
    field = event.GetField()
    value = event.GetData()
    if m.topView.media <> invalid and m.topView.media.HasField(field)
        if IsSameType(value, m.topView.media[field]) = true and IsSameValue(value, m.topView.media[field]) = false
            if m.avoidResetingFields.DoesExist(field)
                m.topView[m.avoidResetingFields[field]] = value
            else
                m.topView.media[field] = value
            end if
        end if
    end if
end sub

function IsSameValue(newValue, currentValue) as Boolean
    isSameValue = false
    valueType = LCase(type(newValue))
    if valueType = "rosgnode"
        isSameValue = newValue.isSameNode(currentValue)
    else if valueType = "roassociativearray" or valueType = "roarray"
        isSameValue = FormatJSON(newValue) = FormatJSON(currentValue)
    else if valueType = "rohttpagent"
        isSameValue = false
    else
        isSameValue = newValue = currentValue
    end if
    return isSameValue
end function

function IsSameType(contentMediaValue, nodeValue) as Boolean
    contentMediaFieldType = type(contentMediaValue)
    nodeFieldType = type(nodeValue)
    return contentMediaFieldType = nodeFieldType
end function

sub OnPlayBarVisibilityHintChanged(event as Object)
    m.trickplayVisible = event.GetData()

    if GetCurrentMode() = "audio"
        if m.topView.npn <> invalid
            if m.trickplayVisible
                m.topView.npn.playBarVisible = false
                m.topView.media.clippingRect = [0, 600, 1280, 120]
            else
                m.topView.npn.playBarVisible = true
                m.topView.media.clippingRect = [0, 720, 1280, 720]
            end if
        end if
    else if m.isButtonBarVisible
        if m.trickplayVisible
            if (m.renderOverContent and m.isAutoHideMode)
                m.buttonBar.opacity = 1.0
            else if not m.renderOverContent
                m.buttonBar.opacity = 1.0
            end if
        else if not m.buttonBar.IsInFocusChain()
            if (m.renderOverContent and m.isAutoHideMode)
                m.buttonBar.opacity = 1.0
            end if
            if m.topView.IsInFocusChain() then m.topView.media.SetFocus(true)
        end if
    end if
end sub

sub ClearMediaNode()
    if m.topView.media <> invalid
        m.topView.media.UnobserveFieldScoped("retrievingBarVisibilityHint")
        m.topView.media.UnobserveFieldScoped("trickPlayBarVisibilityHint")
        m.topView.media.UnobserveFieldScoped("state")
        m.topView.media.UnobserveFieldScoped("position")
        m.topView.media.UnobserveFieldScoped("duration")

        if m.contentMedia <> invalid
            fields = m.topView.media.GetFields()
            for each field in fields
                if field <> "focusedChild"
                    m.topView.media.UnobserveFieldScoped(field)
                end if
            end for
        end if

        if m.topView.mode = "video"
            m.topView.media.control = "stop" 'for backward compatibility
        end if

        m.topView.media.content = invalid
        if m.topView.npn <> invalid
            m.NPNButtonFocused = m.topView.npn.jumpToItem
            m.topView.FindNode("background").visible = true
            if m.topView.hasField("viewContentGroup")
                m.topView.viewContentGroup.RemoveChild(m.topView.npn)
            else
                m.topView.RemoveChild(m.topView.npn)
            end if
            m.topView.npn = invalid
        end if

        'need to keep initial focus
        wasInFocusChain = m.topView.IsInFocusChain()

        m.topView.removeChild(m.topView.media)
        m.topView.media = invalid

        if wasInFocusChain then m.topView.SetFocus(true)
    end if
end sub

' node which catches all state changes and handle actions on it
sub CreateStateMachineNode()
    m.stateNode = m.topView.CreateChild("Node")
    m.stateNode.AddField("state", "string", true)
    m.stateNode.AddField("prevState", "string", true)
    m.stateNode.id = "stateNode"
    m.stateNode.prevState = "none"
    m.stateNode.state = "none"
end sub

sub ClearStateMachineNode()
    if m.stateNode <> invalid
        m.stateNode.UnobserveField("state")
        m.topView.removeChild(m.stateNode)
        m.stateNode = invalid
    end if
end sub

' ************* Process states functions *************

' observer func to track firmware states when node is playing
sub OnMediaStateChanged(event as Object)
    state = event.GetData()
    if m.stateNode <> invalid and not isCSASEnabled()
        SetState(state)
    end if
end sub

' Updates position in interface
sub OnPositionChanged(event as Object)
    if m.topView.npn <> invalid
        m.topView.npn.position = event.getData()
    end if
    m.topView.position = event.GetData()
end sub

' Updates duration in interface
sub OnDurationChanged(event as Object)
    m.topView.duration = event.GetData()
end sub

' Sets the current position in the video
sub OnSeekChanged()
    seekPosition = m.topView.seek
    if seekPosition <> invalid and seekPosition > -1
        if GetState() <> "none" and GetState() <> "contentLoading"
            m.topView.media.seek = seekPosition
            m.topView.seek = -1
        end if
    end if
end sub

sub OnTrickPlayModeChanged()
    if m.topView.media <> invalid
        m.topView.media.enableTrickPlay = m.topView.enableTrickPlay
    end if
end sub

sub ProcessState()
    newState = m.stateNode.state
    prevState = m.stateNode.prevState
    if newState = prevState then return
    m.topView.state = GetInternalToViewState(newState)
    m.transition = BuildTransition(prevState, newState) ' key value in m.transitions AA
    handlerFunc = m.transitions[m.transition]
    ' call handler function if it is valid transition
    if handlerFunc <> invalid then handlerFunc()
end sub

' ************* Field observers *************

sub OnContentSet()
    content = m.topView.content
    ' Handle case when new content set to MediaView
    isNewContent = content <> invalid and (m.content = invalid or not m.content.isSameNode(content))
    isCustomEndcardVisible = (m.topView.FindNode("endcardLayout") <> invalid and GetState() = "endcardVisible")
    ' save current processing content node
    ' so we can distinguish if new content arrived
    if content = invalid
        ' clear itself if populated with empty/invalid content
        if m.topView.media <> invalid then m.topView.media.content = invalid
        m.topView.currentItem = invalid
        SetState("none")
    else if isNewContent and (isCustomEndcardVisible or (m.topView.control = "play" or m.topView.control = "prebuffer"))
        ' Content handling should be started
        ' if developer set new content to the mediaView while custom endcard is visible
        m.content = content
        if IsHandlerConfig(content)
            SetState("contentLoading") ' load content using existing ContentHandler
        else
            SetState("contentLoaded")
        end if
        if not m.isBookmarkHandlerCreated then CreateBookmarksHandler()
    end if
end sub

sub OnControlSet()
    control = m.topView.control
    if (control = "play" or control = "prebuffer")
        if GetState() = "none" or (GetState() = "none" and isCSASEnabled())
            if m.topView.content <> invalid then OnContentSet()
        else if GetState() = "contentLoaded" and (control = "play" or control = "prebuffer")
            SetState("buffering")
        else if GetState() = "buffering" and control = "play"' video is preloaded and already in buffering state, so it is ready to play
            StartPlayback(control)
        else if GetState() = "StartRAFTask" and isCSASEnabled()
            if m.topView.RafTask <> invalid and m.topView.RafTask.renderNode <> invalid
                m.topView.RafTask.renderNode.control = control
            end if
        else if GetState() = "stopped" or GetState() = "paused"
            m.topView.media.control = control
        else if GetState() = "endcardVisible"
            isCustomEndcard = m.topView.FindNode("endcardLayout") <> invalid 
            if isCustomEndcard and m.topView.preloadContent = false
                ' This is custom endcards visible and preloadContent=false case,
                ' so we need to change internal state to "contentLoaded" in order
                ' to trigger the content handler (if exists) and start playback.
                ' This way developer doesn't need to set jumpToItem=currentIndex
                ' to initiate the playback.
                SetState("contentLoaded")
            end if
        end if
    else 'handling control field when user set control programmatically
        if isCSASEnabled() and m.topView.RafTask <> invalid and m.topView.RafTask.renderNode <> invalid
            m.topView.RafTask.renderNode.control = control
        else if m.topView.media <> invalid
            if control <> "stop" or m.topView.media.state <> "stopped"
                m.topView.media.control = control
            end if
        end if
    end if
end sub

sub OnMediaWasShown(event as Object)
    wasShown = event.GetData()

    if wasShown = true and m.topView.IsInFocusChain()
        m.topView.media.SetFocus(true)
    end if
end sub

sub OnMediaWasClosed(event as Object)
    ClearMediaNode()
    ClearStateMachineNode()
    if m.topView.RafTask <> Invalid
        m.topView.RafTask.control = "stop"
        m.topView.RafTask = invalid
    end if
    m.buttonBar.visible = m.isButtonBarVisible
    m.buttonBar.opacity = 1.0
    if m.overhangHeight <> invalid
        m.topView.overhang.height = m.overhangHeight
    end if
end sub

sub OnPreloadContent(event as Object)
    topPreloadContent = event.GetData()
    if topPreloadContent = true and m.topView.media <> invalid
        m.topView.control = "prebuffer"
    end if
end sub

sub OnEndcardTimerFired(event as Object)
    time = event.getData()
    if time = 0
        m.endcardAvailable = false
        SetState("endcardClose")
    end if
end sub

sub OnRepeatButtonSelected()
    m.endcardAvailable = false

    CancelCurrentContentHandler()
    if m.topView.preloadContent and HasNextItemInPlaylist()
        ' cancel prebuffering of next item in playlist
        ClearMediaNode()
        CreateMediaNode()
    end if
    if m.topView.isContentList then m.topView.currentIndex--
    m.repeatButtonSelected = true
    SetState("endcardClose")
end sub

sub OnEndcardRowItemSelected(event as Object)
    m.endcardAvailable = false
    endcardRowItem = event.GetData()
    row = endcardRowItem[0]
    col = endcardRowItem[1]
    endcardRowContent = m.endcardContent.GetChild(row)
    if row = 0 and col = 0 and HasNextItemInPlaylist()
        SetState("endcardClose")
    else if endcardRowContent <> invalid
        ' currentIndex is increased after video is finished
        ' decrease it here so user will have correct value
        ' in endcardItemSelected callback
        m.topView.currentIndex--
        m.topView.endcardItemSelected = endcardRowContent.GetChild(col)
        SetState("endcardClose")
    end if
end sub

' When jumpToItem set we move to specified media to play
sub OnJumpToItem()
    content = m.topView.content
    ' check of content is available, and there is a child to play
    if m.topView.jumpToItem >= 0 and m.topView.media <> invalid
        if not (m.topView.currentIndex = m.topView.jumpToItem and m.topView.media.content <> invalid)
            m.topView.currentIndex = m.topView.jumpToItem
            m.topView.media.content = invalid
            if GetState() = "contentLoaded"
                OnContentLoaded() ' updating currentItem and content for media node to workaround race condition when content set before jumpToItem and(or) preloadContent
            else if GetState() <> "contentLoading" and GetState() <> "none"
                SetState("contentLoaded")
            end if
        end if
    end if
end sub

sub OnContentShuffled()
    shuffle = m.topView.shuffle
    if m.topView.isContentList
        if shuffle
            size = m.topView.content.GetChildCount() - 1
            if size > 0
                'need copy content before shuffling
                if m.unshuffleContent = invalid
                    m.unshuffleContent = m.topView.content
                end if
                shuffledContent = CreateObject("roSGNode", "ContentNode")
                content = m.topView.content.clone(true).GetChildren(-1,0)
                if m.topView.currentIndex >= 0
                    shuffledContent.AppendChild(content[m.topView.currentIndex])
                    content.Delete(m.topView.currentIndex)
                end if

                while content.Count() > 0
                    rndRange = content.Count() - 1
                    index = Rnd(rndRange)
                    shuffledContent.AppendChild(content[index])
                    content.Delete(index)
                end while
                if GetCurrentMode() = "audio"
                    m.newContent = shuffledContent
					m.topView.currentIndex = 0
                    m.IsShuffleTrig = true
                else
                   'need to unobserve content field because when we set shuffled content and
                   'audio is playing, playback will be stopped
                    m.topView.UnObserveField("content")
                    m.topView.content = shuffledContent
                    m.topView.currentIndex = 0
                    m.topView.ObserveField("content", "OnContentSet")
                end if
            end if
        else
            if m.unshuffleContent <> invalid
                if GetCurrentMode() = "audio"
                    m.newContent = m.unshuffleContent
                    m.IsShuffleTrig = true
                else
                    m.topView.UnObserveField("content")
                    m.topView.content = m.unshuffleContent
                    m.topView.ObserveField("content", "OnContentSet")
                end if
                m.unshuffleContent = invalid
            end if
        end if
    end if
end sub

sub OnMediaModeChange(event as Object)
    mode = event.GetData()
    if m.topView.media <> invalid and (mode = "audio" or mode = "video")
        m.mediaModeSet = true ' flag to make sure that mode is not a default value
        if not GetCurrentMode() = mode
            ClearMediaNode()
            CreateMediaNode()
        end if
    end if
end sub

sub OnIsContentListChange(event as Object)
    isContentList = event.GetData()
    if m.topView.media <> invalid and m.topView.media.content <> invalid
        ' if content is already loaded and then we set isContentList field
        ' then we need to handle content according to set value
        SetState("contentLoaded") ' does all required steps to handle isContentList value
    end if
end sub

sub OnDisableScreenSaver(event as Object)
    disableScreenSaver = event.GetData()
    if m.topView.media <> invalid and disableScreenSaver <> invalid
        m.topView.media.disableScreenSaver = disableScreenSaver
    end if
end sub

sub OnRepeatAllChanged(event as Object)
    repeatAll = event.getData()
    if GetCurrentMode() = "audio" and m.topView.media <> invalid and m.topView.isContentList
        if GetState() = "playing" or GetState() = "buffering"
            m.topView.media.control = "pause"
            m.topView.media.loop = repeatAll
            m.topView.media.control = "resume"
        else
            m.topView.media.loop = repeatAll
        end if
    end if
end sub

sub OnAudioContentIndexChanged(event as Object)
    state = GetState()
    audioIndex = event.GetData()
    ' handling states between audio playlist items
    if audioIndex <> m.topView.currentIndex and m.topView.media <> invalid and m.topView.media.state <> "none" and state <> "contentLoaded"
        SetState("finished")
    else if m.IsShuffleTrig = true
        m.topView.media.control = "pause"
        m.topView.content = m.newContent
        OnContentLoaded()
        m.IsShuffleTrig = false
        m.topView.media.control = "resume"
        m.newContent = invalid
    else if state = "playing" or state = "buffering"
        currentItem = m.topView.content.getChild(m.topView.media.contentIndex)
        m.topView.currentIndex = m.topView.media.contentIndex
        m.topView.currentItem = currentItem
        if m.topView.npn <> invalid
            m.topView.npn.content = currentItem.clone(false)
        end if

        if not m.isBookmarkHandlerCreated then CreateBookmarksHandler()
        m.isBookmarkHandlerCreated = false
    end if
end sub

sub OnAudioButtonContentChanged(event as Object)
    content = event.getData()
    if m.topView.npn <> invalid and content <> invalid
        m.topView.npn.buttonContent = content.clone(true)
    end if
end sub

sub OnAudioKeyPressed(event as Object)
    key = event.GetData()
    if GetCurrentMode() = "audio" and m.topView.npn <> invalid
        if key = "right" and m.topView.isContentList
            m.isNavigated = true
            m.topView.control = "play"
            SetState("finished")
        else if key = "left" and m.topView.isContentList
            m.isNavigated = true
            m.topView.control = "play"
            m.topView.currentIndex -= 2
            SetState("finished")
        end if
        if m.topView.buttons <> invalid and m.topView.buttons.GetChildCount() > 0
            if key = "ok"
                m.topView.buttonSelected = m.topView.npn.jumpToItem
            else if key = "up"
                if m.topView.npn.jumpToItem > 0
                    m.topView.npn.jumpToItem -= 1
                else
                    m.topView.npn.jumpToItem = m.topView.buttons.GetChildCount() - 1
                end if
            else if key = "down"
                if m.topView.npn.jumpToItem < m.topView.buttons.GetChildCount() - 1
                    m.topView.npn.jumpToItem += 1
                else
                    m.topView.npn.jumpToItem = 0
                end if
            end if
        end if
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if key = "fastforward" or key = "rewind"
        m.isFF = true
    end if
end function

' ************* Transition handlers functions *************

sub LoadContent()
    content = m.topView.content
    ShowBusySpinner(true)
    customEndcardLayout = m.topView.FindNode("endcardLayout")
    isCustomEndcard = customEndcardLayout <> invalid and customEndcardLayout.visible
    isNativeEndcard = m.topView.endcardView <> invalid
    isEndcard = isCustomEndcard or isNativeEndcard
    if isEndcard and m.topView.preloadContent or m.topView.mode = "audio"
        ' do not show spinner in audio mode and on endcards
        ShowBusySpinner(false)
    end if
    if not IsHandlerConfig(content) and m.topView.isContentList
        ' then we need to load content for playlist item with its own ContentHandler
        content = content.GetChild(m.topView.currentIndex)
    end if

    if content.HandlerConfigVideo <> invalid ' for backward compatibility with VideoView
        handlerConfig = content.HandlerConfigVideo
        content.HandlerConfigVideo = invalid
    else
        handlerConfig = content.HandlerConfigMedia
        content.HandlerConfigMedia = invalid
    end if

    callback = {
        content: content
        config: handlerConfig
        mAllowEmptyResponse: true

        onReceive: function(data)
            SetState("contentLoaded")
        end function

        onError: function(data)
            SetState("error")
        end function
    }

    m.contentHandler = GetContentData(callback, handlerConfig, content)
end sub

sub LoadEndcardContent(endcardContent as Object, HandlerConfigEndcard as Object)
    nextItem = Utils_CopyNode(m.topView.content.GetChild(m.topView.currentIndex))
    customEndcardLayout = m.topView.FindNode("endcardLayout")
    isCustomEndcard = customEndcardLayout <> invalid
    if HandlerConfigEndcard <> invalid and HandlerConfigEndcard.name <> ""
        callback = {
            nextItem: nextItem
            content: endcardContent
            config: HandlerConfigEndcard
            mAllowEmptyResponse : true
            isCustomEndcard: isCustomEndcard
            onReceive: function(data)
                if data <> invalid
                    if data.GetChildCount() = 0 ' no content received from CH
                        SetState("completed")
                    else
                        if m.nextItem <> invalid and data.getChild(0) <> invalid and m.isCustomEndcard = false
                            ' insert next item in playlist
                            data.GetChild(0).InsertChild(m.nextItem, 0)
                        end if
                        GetGlobalAA().endcardContent = data
                        ShowBusySpinner(false)
                        SetState("endcardLoaded")
                    end if
                else
                    ' Then do not show EndcardView
                    SetState("completed")
                end if
            end function

            onError: function(data)
                GetGlobalAA().endcardContent = m.endcardContent
                ShowBusySpinner(false)
                SetState("endcardLoaded")
            end function
        }
        m.contentHandlerEndcard = GetContentData(callback, HandlerConfigEndcard, endcardContent)
        if m.contentHandlerEndcard = invalid then SetState("completed") 'if endcard handler was not created then just go to the next video
    else
        if isCustomEndcard = false
            if nextItem <> invalid
                rowContent = CreateObject("roSGNode", "ContentNode")
                rowContent.AppendChild(nextItem)
                endcardContent.AppendChild(rowContent)
            end if
            m.endcardContent = endcardContent
        end if
        SetState("endcardLoaded")
    end if
end sub

sub StartRafTask(rafHandlerConfig as Object, video as Object) as Object
    callback = {
        view : m.topView
        onReceive: function(data)
            m.onResult(data)
        end function

        onError: function(data)
            if m.view.state = "finished" or GetState() = "RAFSuccess" then
                m.onResult(data)
            else
                SetState("RAFExit")
            end if
        end function

        onResult: function(data)
            SetState("RAFClose")
        end function
    }
    m.topView.RafTask = GetContentData(callback, rafHandlerConfig, CreateObject("roSGNode", "ContentNode"))
    if m.topView.RafTask <> Invalid
        m.topView.RafTask.video = video
    end if
end sub

sub OnContentLoaded()
    if m.topView.currentIndex < 0 then m.topView.currentIndex = 0

    currentItem = GetCurrentLoadedItem()

    if IsHandlerConfig(currentItem)
        SetState("contentLoading")
    else if currentItem <> invalid ' ready to play
        ShowBusySpinner(false)
        m.handlerConfigRAF = invalid
        ExtractRafConfig()
        ' Set content node that we receive to Media Node
        content = currentItem.clone(false)
        UpdateMediaModeByContent()
        if m.topView.npn <> invalid
            if m.topView.buttons <> invalid
                m.topView.npn.buttonContent = m.topView.buttons.clone(true)
                m.topView.npn.jumpToItem = m.NPNButtonFocused
            end if
            m.topView.npn.content = content
        end if
        if GetCurrentMode() = "audio" and m.topView.isContentList
           'reseting content of video node causes execution timeout on low-end devices,
            'but if we invalidate content before, it doesn't happen
            if m.topView.media <> invalid and m.topView.media.contentIndex = -1 and m.IsShuffleTrig = true or m.isFF = true and m.isNavigated = true
                'turning shuffle off and navigating causes a lot of OnContentSet() calls,
                'that leads to execution timeout on low-end devices
                if m.isNavigated = true
                    m.topView.UnobserveField("content")
                end if
                m.topView.media.content = invalid
            end if
            m.topView.media.content = m.topView.content

            if m.isNavigated = true
                m.topView.ObserveField("content", "OnContentSet")
                m.isNavigated = false
            end if
        else
            m.topView.media.content = content
        end if
        if not m.isBookmarkHandlerCreated then CreateBookmarksHandler()
        if isCSASEnabled() then
            m.topView.currentItem = currentItem
            SetState("StartRAFTask")
        else
            if m.topView.currentRAFHandler <> invalid and m.topView.RafTask = invalid and m.topView.mode = "video" and m.topView.preloadContent = false and m.topView.wasShown
                m.topView.currentItem = currentItem
                SetState("StartRAFTask")
            else if m.topView.control = "play" or m.topView.control = "prebuffer" or m.topView.control = "resume"
                SetState("buffering")
            end if
        end if
    end if
end sub

function GetCurrentLoadedItem()
    currentItem = invalid

    if m.topView.isContentList and m.topView.content <> invalid and m.topView.content.GetChildCount() > 0
        if HasNextItemInPlaylist()
            currentItem = m.topView.content.GetChild(m.topView.currentIndex)
        else if m.topView.endcardView <> invalid
            ' we are on endcards and have no next item
            ' prebuffer current one so it will start quickly if user selects repeat
            currentItem = m.topView.content.GetChild(m.topView.currentIndex - 1)
        end if
    else ' single item
        currentItem = m.topView.content
    end if

    return currentItem
end function

sub OnStartBuffering()
    ' Control field is roString type we should change it to String to force firmware to pass
    ' it by value, not reference
    control = m.topView.control.toStr()
    if control = "play" or control = "prebuffer" or control = "resume"
        customEndcardLayout = m.topView.FindNode("endcardLayout")
        isCustomEndcard = customEndcardLayout <> invalid and customEndcardLayout.visible
        isNativeEndcard = m.topView.endcardView <> invalid
        if isNativeEndcard or (isCustomEndcard and m.topView.preloadContent = true)
            ' prebuffer content on endcard
            m.topView.media.control = "prebuffer"
        else
            if GetCurrentMode() = "video" and control = "resume"
                StartPlayback("play")
            else
                StartPlayback(control)
            end if
        end if
    end if
end sub

sub ProcessEndState()
    ' video successfully finished so then we should handle next actions
    currentItem = GetCurrentLoadedItem()
    if m.topView.RafTask = invalid and GetState() = "finished"
        HandlerConfigEndcard = invalid
        if currentItem <> invalid then HandlerConfigEndcard = currentItem.HandlerConfigEndcard
        if HandlerConfigEndcard <> invalid then currentItem.HandlerConfigEndcard = invalid

        ' skip incrementing currentIndex if repeatOne mode enabled
        if m.topView.mode = "audio"
            if not m.topView.repeatOne
                m.topView.media.contentIndex = -1
                m.topView.currentIndex++
            end if
        else
            ClearMediaNode()
            CreateMediaNode()
            m.topView.currentIndex++
        end if
        if NeedToShowEndcards(HandlerConfigEndcard) and GetCurrentMode() = "video"
            endcardContent = CreateObject("roSGNode", "ContentNode")
            if HandlerConfigEndcard <> invalid then ShowBusySpinner(true)
            LoadEndcardContent(endcardContent, HandlerConfigEndcard)
        else
            SetState("completed")
        end if
    end if
end sub

sub OnCompletedPlayback()
    if m.topView.isContentList and HasNextItemInPlaylist()
        SetState("contentLoaded")
    else if m.topView.repeatAll and m.topView.isContentList
        m.topView.currentIndex = 0
        SetState("contentLoaded")
    else
        m.topView.close = true
    end if
end sub

sub OnStartedPlayback()
    m.isFF = false
end sub

sub OnPausedPlayback()
    m.trickplayVisible = true
    if m.isButtonBarVisible then
        m.buttonBar.opacity = 1.0
    end if
end sub

sub OnResumedPlayback()
    if m.isButtonBarVisible and (not m.renderOverContent) then
        m.buttonBar.opacity = 0.0
    end if
end sub


sub OnErrorState()
    if m.topView.media <> invalid
        errorCode = m.topView.media.errorCode or (m.topView.media.errorMsg <> invalid and m.topView.media.errorMsg <> "")
        if errorCode <> 0
            ? "[SGDEX] media.errorCode == "; m.topView.media.errorCode; " media.errorMsg == "; m.topView.media.errorMsg
        end if
    end if

    m.topView.close = true
end sub

sub OnFinishedEndcardLoadedTransition()
    SetState("endcardVisible")
end sub

sub OnEndcardVisibleTransition()
    if m.spinnerGroup.visible then ShowBusySpinner(false)
    ' Use custom endcard if developer provides layout with 'endcardLayout' id.
    customEndcardLayout = m.topView.FindNode("endcardLayout")
    isCustomEndcard = customEndcardLayout <> invalid
    if isCustomEndcard
        m.topView.control = "none"
        ' Content field is optional for developer
        if customEndcardLayout.HasField("content")
            customEndcardLayout.content = m.endcardContent
        end if
        ' Show endcards and set focus to it
        customEndcardLayout.visible = true
        m.topView.appendChild(customEndcardLayout)
        customEndcardLayout.SetFocus(true)
        StartPrebufferingOnEndcard()
    else if m.topView.endcardView = invalid
        m.endcardAvailable = true
        m.topView.endcardView = CreateObject("roSGNode", "EndcardView")
        m.topView.endcardView.id = "endcardView"
        m.topView.endcardView.translation = "[0, 0]"
        m.topView.endcardView.endcardCountdownTime = m.topView.endcardCountdownTime
        m.topView.endcardView.hasNextItemInPlaylist = HasNextItemInPlaylist()
        if m.endcardContent <> invalid
            m.topView.endcardView.content = m.endcardContent
        end if

        m.topView.endcardView.startTimer = true
        m.topView.endcardView.ObserveFieldScoped("rowItemSelected", "OnEndcardRowItemSelected")
        m.topView.endcardView.ObserveFieldScoped("repeatButtonSelectedEvent", "OnRepeatButtonSelected")
        m.topView.endcardView.ObserveFieldScoped("timerFired", "OnEndcardTimerFired")

        m.topView.appendChild(m.topView.endcardView)
        m.topView.endcardView.SetFocus(true)
        StartPrebufferingOnEndcard()
    end if
end sub

sub StartPrebufferingOnEndcard()
    if m.topView.preloadContent
        m.topView.control = "prebuffer"
        SetState("contentLoaded")
    end if
end sub

sub OnEndcardCloseTransition()
    m.endcardAvailable = false

    m.topView.endcardView.visible = false
    m.endcardContent = invalid

    m.topView.endcardView.UnObserveFieldScoped("rowItemSelected")
    m.topView.endcardView.UnObserveFieldScoped("repeatButtonSelectedEvent")
    m.topView.endcardView.UnObserveFieldScoped("timerFired")

    'need to keep initial focus
    wasInFocusChain = m.topView.IsInFocusChain()

    m.topView.RemoveChild(m.topView.endcardView)
    m.topView.endcardView = invalid

    if wasInFocusChain then m.topView.SetFocus(true)
    SetState("completed")
end sub

sub OnEndcardCloseCompletedTransition()
    ' set control play if we were prebuffering on endcard
    m.topView.control = "play"
    if IsContentLoaded()
        hasNextItemToPlay = (HasNextItemInPlaylist() or m.repeatButtonSelected) and m.topView.endcardItemSelected = invalid
        m.repeatButtonSelected = false
        if hasNextItemToPlay
            if m.topView.preloadContent and m.topView.media.content <> invalid
                SetState("buffering")
            else
                SetState("contentLoaded")
            end if
        else
            m.topView.close = true
        end if
    else
        ShowBusySpinner(true)
    end if
end sub

sub OnStartRAFTaskTransition()
    if isCSASEnabled() then
        ' TODO: remove code duplication
        StartRafTask(m.topView.currentRAFHandler, m.topView.media)
        ' Sharing flag from HandlerConfigRAF to RAFtask
        m.topView.RafTask.useCSAS = (m.topView.currentRAFHandler.useCSAS = true)
        m.topView.media.content = invalid
        if m.topView.RafTask = invalid
            SetState("finished")
        else
            ShowBusySpinner(false)
            m.topView.RafTask.ObserveField("isPlayingAds", "OnRAFPlayingAds")
        end if
    else
        if m.topView.RafTask = invalid or m.topView.RafTask.video = invalid
            StartRafTask(m.topView.currentRAFHandler, m.topView.media)
            if m.topView.RafTask = invalid
                SetState("buffering")
            else
                ShowBusySpinner(false)
                m.topView.RafTask.ObserveField("isPlayingAds", "OnRAFPlayingAds")
            end if
        end if
    end if
end sub

sub OnRAFPlayingAds(event as Object)
    isPlayingAds = event.GetData()
    if isPlayingAds
        SetState("RAFPlaying")
    else
        SetState("RAFSuccess")
    end if
end sub

sub OnRAFCloseTransition()
    if m.topView.RafTask <> Invalid
        m.topView.RafTask.video = Invalid
        m.topView.RafTask = Invalid
    end if
    SetState("finished")
end sub

sub OnRAFExitTransition()
    if m.topView.RafTask <> Invalid
        m.topView.RafTask.video = Invalid
        m.topView.RafTask = Invalid
    end if
    m.topView.close = true
end sub

' ************* Utils functions *************

sub SetState(state as String)
    ' if state node is invalid it means that MediaView was closed by the user
    if m.stateNode <> invalid
        m.stateNode.prevState = m.stateNode.state
        m.stateNode.state = state
        ProcessState()
    end if
end sub

function GetState() as String
    state = ""
    if m.stateNode <> invalid then state = m.stateNode.state
    return state
end function

function BuildTransition(prevState as String, newState as String) as String
    return prevState + "_" + newState
end function

sub CancelCurrentContentHandler()
    if m.contentHandler <> invalid and not IsContentLoaded()
        m.contentHandler.control = "stop"
    end if
end sub

' Return false if content handler is running
' Return true otherwise
function IsContentLoaded()
    isLoaded = true
    if m.contentHandler <> invalid and m.contentHandler.state = "run"
        ' if content handler is running the content is not loaded yet
        isLoaded = false
    end if
    return isLoaded
end function

sub StartPlayback(control as String)
    if m.topView.media <> invalid
        if m.topView.IsInFocusChain() then m.topView.media.SetFocus(true)
        if GetCurrentMode() = "video"
            m.topView.media.visible = true
            if m.contentMedia = invalid or m.contentMedia.HasField("enableUI") = false
                m.topView.media.enableUI = true
            else
                m.topView.media.enableUI = m.contentMedia.enableUI
            end if
        else
            if control = "stop" or m.renderOverContent then
                m.buttonBar.opacity = 1.0
            else if control = "play"
                m.buttonBar.opacity = 0.0
            end if
        end if
        if control = "play" and m.topView.currentRAFHandler <> invalid then
            ' start RAFTask on play control if there is rafConfig
            m.topView.currentItem = GetCurrentLoadedItem()
            SetState("StartRAFTask")
        else if not isCSASEnabled()
            ' set currentItem interface once we start playback
            m.topView.currentItem = GetCurrentLoadedItem()
            if GetCurrentMode() = "audio" and m.topView.isContentList
                ' audio playlist mode - don't set control="play" if the content
                ' is already playing (state="playing") to avoid playback failures
                ' for some media formats
                isAlreadyPlaying = (control = "play" and m.topView.media.state = "playing")
                if not isAlreadyPlaying then
                    m.topView.media.control = control
                end if
                m.topView.media.nextContentIndex = -1
                m.topView.media.nextContentIndex = m.topView.currentIndex
                m.topView.media.control = "skipcontent"
                seekToPos = m.topView.currentItem.playStart
                if seekToPos <> invalid and seekToPos > 0
                    m.topView.seek = seekToPos
                else
                    seekToPos = m.topView.currentItem.bookmarkPosition
                    if seekToPos <> invalid and seekToPos > 0
                        m.topView.seek = seekToPos
                    end if
                end if
            else
                ' not the audio playlist - always set the control
                ' for backward compatibility
                m.topView.media.control = control
            end if
        end if
        if m.topView.seek <> invalid and m.topView.seek > -1
            OnSeekChanged()
        end if

        m.topView.media.enableTrickPlay = m.topView.enableTrickPlay
    end if
end sub

' checks if ContentNode is populated with HandlerConfig
function IsHandlerConfig(contentNode as Object) as Boolean
    if contentNode <> invalid
        return (contentNode.HandlerConfigMedia <> invalid) or (contentNode.HandlerConfigVideo <> invalid)
    end if
end function

sub ShowBusySpinner(shouldShow as Boolean)
    ' make spinner a last child, so it will be rendered
    m.topView.AppendChild(m.spinnerGroup)
    if shouldShow then
        if not m.spinnerGroup.visible then
            m.spinnerGroup.visible = true
            m.spinner.control = "start"
        end if
    else
        m.spinnerGroup.visible = false
        m.spinner.control = "stop"
    end if
end sub

sub ExtractRafConfig()
    currentItem = GetCurrentLoadedItem()
    topControl = m.topView.control
    if (currentItem.handlerConfigRAF <> invalid and currentItem.handlerConfigRAF.name <> "") then
        m.topView.currentRAFHandler = currentItem.handlerConfigRAF
        currentItem.handlerConfigRAF = invalid
    else if (m.topView.content.handlerConfigRAF <> invalid and m.topView.content.handlerConfigRAF.name <> "") then
        m.topView.currentRAFHandler = m.topView.content.handlerConfigRAF
    else if (m.topView.handlerConfigRAF <> invalid and m.topView.handlerConfigRAF.name <> "") then
        m.topView.currentRAFHandler = m.topView.handlerConfigRAF
    end if
end sub

sub CreateBookmarksHandler()
    currentItem = GetCurrentLoadedItem()
    if currentItem <> invalid then
        ' Setting length to MediaView before bookmark handler created
        ' to be able to save bookmarks
        if currentItem.length <> invalid and m.topView.duration = 0 then
            m.topView.duration = currentItem.length
        end if
        handlerConfigBookmarks = currentItem.handlerConfigBookmarks
        ' bookmark config field had name BookmarksHandler till v2.0
        ' to be backward compatible check old field if new wasn`t set
        if handlerConfigBookmarks = invalid then handlerConfigBookmarks = currentItem.BookmarksHandler
        if handlerConfigBookmarks <> invalid and handlerConfigBookmarks.name <> invalid then
            node = GetNodeFromChannel(handlerConfigBookmarks.name)
            if node <> invalid then
                m.isBookmarkHandlerCreated = true
                if handlerConfigBookmarks.fields <> invalid then node.setFields(handlerConfigBookmarks.fields)
                node.videoView = m.topView
            else
                ? "Error: Unable to create handlerConfigBookmarks with type " NodeName
            end if
        else
            ' ? "Error: Invalid handlerConfigBookmarks config"
        end if
    end if
end sub

function NeedToShowEndcards(HandlerConfigEndcard as Object)
    return m.topView.alwaysShowEndcards or HandlerConfigEndcard <> invalid
end function

function GetInternalToViewState(newState as String)
    viewState = m.internalToViewStateAA[newState]
    if viewState = invalid
        viewState = m.topView.state
    end if
    return viewState
end function

function HasNextItemInPlaylist()
    if m.topView.content <> invalid
        return (m.topView.content.GetChildCount() > m.topView.currentIndex)
    else
        return false
    end if
end function

sub UpdateMediaModeByContent()
    ' if there is item content and the mode was not set explicitly, then get mode by streamformat from the content
    currentItem = GetCurrentLoadedItem()
    if currentItem <> invalid and not m.mediaModeSet
        streamFormat = currentItem.streamFormat
        isStreamFormatValid = streamFormat <> invalid and streamFormat <> "(null)"
        isAudioStream = streamFormat = "wma" or streamFormat = "mka" or streamFormat = "mp3"

        if isStreamFormatValid and isAudioStream
            m.topView.mode = "audio"
        else
            ' To handle case when playing mixed streamFormats in playlist
            if GetCurrentMode() = "audio" then m.topView.mode = "video"
        end if
        m.mediaModeSet = false
    end if
end sub

function GetCurrentMode() as String
    if m.topView.media <> invalid
        return m.topView.media.id
    else
        return m.topView.mode
    end if
end function

function isCSASEnabled() as Boolean
    return (m.topView.currentRAFHandler <> invalid and m.topView.currentRAFHandler.useCSAS = true)
end function
