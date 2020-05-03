' Copyright (c) 2019 Roku, Inc. All rights reserved.

' README:
' MediaView is a SGDEX component to play video items or playlists
' In channel developer create MediaView,
' set content - it is a playlist, has childs with items
' to configure starting item, there is jumpToItem field see OnJumpToItem field
' and to configure to play - set control to "play"
' there is possibility to set "buffering" control
'   video = CreateObject("roSGNode", "MediaView")
'   video.content = content
'   video.jumpToItem = index
'   video.control = "play"

sub Init()
    ' Perform content setting/loading actions when content was set
    m.top.ObserveField("content", "OnContentSet")

    ' Start playing video when corresponding control is set
    m.top.ObserveField("control", "OnControlSet")

    ' Set focus on media when view was shown
    m.top.ObserveField("wasShown", "OnMediaWasShown")

    ' jumpToItem - field to navigate between items in playlist
    ' with most cases it will be set once, before MediaView is shown
    m.top.ObserveField("jumpToItem", "OnJumpToItem")

    ' When MediaView is closed we need to stop Media Node,
    ' Stop RAF task if it exist
    m.top.ObserveField("wasClosed", "OnMediaWasClosed")

    m.top.ObserveField("preloadContent", "OnPreloadContent")

    ' When is mode changing we need to recreate mediaNode
    m.top.ObserveField("mode", "OnMediaModeChange")

    ' When content is loaded and changing isContentList field we need to recreate mediaNode
    m.top.ObserveField("isContentList", "OnIsContentListChange")

    m.top.ObserveField("disableScreenSaver", "OnDisableScreenSaver")

    m.top.ObserveFieldScoped("focusedChild", "OnFocusedChildChange")

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
        playing_error: OnErrorState
        playing_completed: OnCompletedPlayback ' user set content to invalid
        playing_paused: OnPausedPlayback
        paused_playing: OnResumedPlayback
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

    CreateStateMachineNode() ' node to handle processing all states and their transitions
    CreateMediaNode()
    m.spinner = m.top.FindNode("spinner")
    m.spinnerGroup = m.top.FindNode("spinnerGroup")

    m.buttonBar = m.top.getScene().buttonBar
    m.isButtonBarVisible = m.buttonBar.visible
    m.renderOverContent = m.buttonBar.renderOverContent
    m.isAutoHideMode = m.buttonBar.autoHide

    if m.isButtonBarVisible and m.top.overhang.height > 72
        m.overhangHeight = m.top.overhang.height
        m.top.overhang.height = 72
    end if

    ' PRIVATE fields for library managers
    m.ContentManager_id = 0
    m.debug = false
    m.endcardContent = invalid
    m.endcardView = invalid
    m.mediaModeSet = false
    m.repeatButtonSelected = false
    m.trickplayVisible = true
    m.RafTask = invalid
    m.endcardAvailable = false
end sub

sub OnFocusedChildChange()
    if m.media <> invalid
        ' Check if endcard isn't shown to avoid focus losting
        if m.top.wasShown and not m.endcardAvailable
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
                    if m.trickplayVisible or m.top.state = "paused"
                        ' show buttonBar if playback paused or trickplay visible
                        m.buttonBar.opacity = 1.0
                    else
                        ' hide buttonBar if playback is running
                        m.buttonBar.opacity = 0.0
                    end if
                end if
                m.media.setFocus(true)
            end if
        else if m.endcardAvailable ' Handle endcardView focuses
            if m.isButtonBarVisible ' safe restoring buttonBar visibility
                m.buttonBar.visible = true
            end if
            m.endCardView.SetFocus(true)
            m.buttonBar.opacity = 1.0 ' show buttonBar over endcardView
        end if
        if m.buttonBar.IsInFocusChain() and m.isButtonBarVisible and not m.top.IsInFocusChain()
            ' if m.buttonBar is focused  -  make it visible
            m.buttonBar.opacity = 1.0
        end if
    end if
end sub

' ************* Creating and clearing functions *************

sub CreateMediaNode()
    m.isBookmarkHandlerCreated = false
    mode = m.top.mode
    if mode = "video"
        video = m.top.createChild("Video")
        video.id = "video"
        video.width = "1280"
        video.height = "720"
        video.translation = "[0,0]"
        video.enableUI = false
        video.disableScreenSaver = m.top.disableScreenSaver
        video.ObserveFieldScoped("trickPlayBarVisibilityHint", "OnPlayBarVisibilityHintChanged")
        video.ObserveFieldScoped("retrievingBarVisibilityHint", "OnPlayBarVisibilityHintChanged")
        m.media = video
    else if mode = "audio"
        m.npn = m.top.createChild("NowPlayingView")
        audio = m.top.createChild("Audio")
        audio.id = "audio"
        m.media = audio
    end if

    if m.lastThemeAttributes <> invalid and mode = "video"
        SGDEX_SetTheme(m.lastThemeAttributes)
    end if

    m.media.ObserveFieldScoped("position", "OnPositionChanged")
    m.media.ObserveFieldScoped("duration", "OnDurationChanged")
    m.media.ObserveFieldScoped("state", "OnMediaStateChanged") ' to track firmware states
end sub

sub OnPlayBarVisibilityHintChanged(event as Object)
    m.trickplayVisible = event.GetData()

    if m.isButtonBarVisible
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
            if m.top.IsInFocusChain() then m.media.SetFocus(true)
        end if
    end if
end sub

sub ClearMediaNode()
    if m.media <> invalid
        m.media.UnobserveFieldScoped("retrievingBarVisibilityHint")
        m.media.UnobserveFieldScoped("trickPlayBarVisibilityHint")
        m.media.UnobserveFieldScoped("state")
        m.media.UnobserveFieldScoped("position")
        m.media.UnobserveFieldScoped("duration")
        m.media.control = "stop"
        m.media.content = invalid
        if m.npn <> invalid
            m.top.removeChild(m.npn)
            m.npn = invalid
        end if

        'need to keep initial focus
        wasInFocusChain = m.top.IsInFocusChain()

        m.top.removeChild(m.media)
        m.media = invalid

        if wasInFocusChain then m.top.SetFocus(true)
    end if
end sub

' node which catches all state changes and handle actions on it
sub CreateStateMachineNode()
    m.stateNode = m.top.CreateChild("Node")
    m.stateNode.AddField("state", "string", true)
    m.stateNode.AddField("prevState", "string", true)
    m.stateNode.prevState = "none"
    m.stateNode.state = "none"
end sub

sub ClearStateMachineNode()
    if m.stateNode <> invalid
        m.stateNode.UnobserveField("state")
        m.top.removeChild(m.stateNode)
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
    m.top.position = event.GetData()
end sub

' Updates duration in interface
sub OnDurationChanged(event as Object)
    m.top.duration = event.GetData()
end sub

sub ProcessState()
    newState = m.stateNode.state
    prevState = m.stateNode.prevState
    if newState = prevState then return
    m.top.state = GetInternalToViewState(newState)
    m.transition = BuildTransition(prevState, newState) ' key value in m.transitions AA
    handlerFunc = m.transitions[m.transition]
    ' call handler function if it is valid transition
    if handlerFunc <> invalid then handlerFunc()
end sub

' ************* Field observers *************

sub OnContentSet()
    content = m.top.content
    ' Handle case when new content set to MediaView
    isNewContent = content <> invalid and (m.content = invalid or not m.content.isSameNode(content))
    ' save current processing content node
    ' so we can distinguish if new content arrived
    if content = invalid
        ' clear itself if populated with empty/invalid content
        if m.media <> invalid then m.media.content = invalid
        m.top.currentItem = invalid
        SetState("none")
    else if isNewContent and (m.top.control = "play" or m.top.control = "prebuffer")
        m.content = content
        if IsHandlerConfig(content)
            SetState("contentLoading") ' load content using existing ContentHandler
        else
            SetState("contentLoaded")
        end if
        if not m.isBookmarkHandlerCreated then CreateBookmarksHandler()
    end if
end sub

sub OnControlSet(event as Object)
    control = event.GetData()
    if (control = "play" or control = "prebuffer")
        if GetState() = "none" or (GetState() = "none" and isCSASEnabled())
            if m.top.content <> invalid then OnContentSet()
        else if GetState() = "contentLoaded" and (control = "play" or control = "prebuffer")
            SetState("buffering")
        else if GetState() = "buffering" and control = "play"' video is preloaded and already in buffering state, so it is ready to play
            StartPlayback(control)
        else if GetState() = "StartRAFTask" and isCSASEnabled()
            if m.RafTask <> invalid and m.RafTask.renderNode <> invalid
                m.RAFTask.renderNode.control = control
            end if
        else if GetState() = "stopped" or GetState() = "paused"
            m.media.control = control
        end if
    else 'handling control field when user set control programmatically
        if isCSASEnabled() and m.RafTask <> invalid and m.RafTask.renderNode <> invalid
            m.RAFTask.renderNode.control = control
        else if m.media <> invalid
            m.media.control = control
        end if
    end if
end sub

sub OnMediaWasShown(event as Object)
    wasShown = event.GetData()

    if wasShown = true and m.top.IsInFocusChain()
        m.media.SetFocus(true)
    end if
end sub

sub OnMediaWasClosed(event as Object)
    ClearMediaNode()
    ClearStateMachineNode()
    if m.RafTask <> Invalid
        m.RafTask.control = "stop"
        if isCSASEnabled() and (m.RAFTask.renderNode <> invalid and m.RAFTask.renderNode.GetChild(0) <> invalid and m.RAFTask.renderNode.GetChild(0).id = "contentVideo") then
            m.RAFTask.renderNode.getchild(0).content = invalid ' Force stopping RafContentRenderer's videoNode
        end if

        'Removing RAF playback if it exist to avoid RAF error on deeplink
        RAFRenderer = m.top.GetScene().GetChild(m.top.GetScene().GetChildCount()-1)
        if RAFRenderer <> invalid and LCase(RAFRenderer.id) = "rafrender" then
            RAFRenderer.getChild(0).content = invalid ' Reseting RAF video node content to kill it
            RAFRenderer = invalid
        end if
        m.RafTask = invalid
    end if
    m.buttonBar.visible = m.isButtonBarVisible
    m.buttonBar.opacity = 1.0
    if m.overhangHeight <> invalid
        m.top.overhang.height = m.overhangHeight
    end if
end sub

sub OnPreloadContent(event as Object)
    topPreloadContent = event.GetData()
    if topPreloadContent = true and m.media <> invalid
        m.top.control = "prebuffer"
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
    if m.top.preloadContent and HasNextItemInPlaylist()
        ' cancel prebuffering of next item in playlist
        ClearMediaNode()
        CreateMediaNode()
    end if
    if m.top.isContentList then m.top.currentIndex--
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
        m.top.currentIndex--
        m.top.endcardItemSelected = endcardRowContent.GetChild(col)
        SetState("endcardClose")
    end if
end sub

' When jumpToItem set we move to specified media to play
sub OnJumpToItem()
    content = m.top.content
    ' check of content is available, and there is a child to play
    if m.top.jumpToItem >= 0 and m.media <> invalid
        m.top.currentIndex = m.top.jumpToItem
        m.media.content = invalid
        if GetState() = "contentLoaded"
            OnContentLoaded() ' updating currentItem and content for media node to workaround race condition when content set before jumpToItem and(or) preloadContent
        else if GetState() <> "contentLoading" and GetState() <> "none"
            SetState("contentLoaded")
        end if
    end if
end sub

sub OnMediaModeChange(event as Object)
    mode = event.GetData()
    if m.media <> invalid and (mode = "audio" or mode = "video")
        m.mediaModeSet = true ' flag to make sure that mode is not a default value
        if not GetCurrentMode() = mode
            ClearMediaNode()
            CreateMediaNode()
        end if
    end if
end sub

sub OnIsContentListChange(event as Object)
    isContentList = event.GetData()
    if m.media <> invalid and m.media.content <> invalid
        ' if content is already loaded and then we set isContentList field
        ' then we need to handle content according to set value
        SetState("contentLoaded") ' does all required steps to handle isContentList value
    end if
end sub

sub OnDisableScreenSaver(event as Object)
    if m.top.mode = "video"
        disableScreenSaver = event.GetData()
        if m.media <> invalid and disableScreenSaver <> invalid
            m.media.disableScreenSaver = disableScreenSaver
        end if
    else
        ? "WARNING: disableScreenSaver only works in video mode"
    end if
end sub

' ************* Transition handlers functions *************

sub LoadContent()
    content = m.top.content
    ShowBusySpinner(true)
    if m.endcardView <> invalid or m.top.mode = "audio"
        ' do not show spinner in audio mode and on endcards
        ShowBusySpinner(false)
    end if
    if not IsHandlerConfig(content) and m.top.isContentList
        ' then we need to load content for playlist item with its own ContentHandler
        content = content.GetChild(m.top.currentIndex)
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
    nextItem = Utils_CopyNode(m.top.content.GetChild(m.top.currentIndex))

    if HandlerConfigEndcard <> invalid and HandlerConfigEndcard.name <> ""
        callback = {
            nextItem: nextItem
            content: endcardContent
            config: HandlerConfigEndcard
            mAllowEmptyResponse : true

            onReceive: function(data)
                if data <> invalid
                    if data.GetChildCount() = 0 ' no content received from CH
                        SetState("completed")
                    else
                        if m.nextItem <> invalid and data.getChild(0) <> invalid
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
        if nextItem <> invalid
            rowContent = CreateObject("roSGNode", "ContentNode")
            rowContent.AppendChild(nextItem)
            endcardContent.AppendChild(rowContent)
        end if
        m.endcardContent = endcardContent
        SetState("endcardLoaded")
    end if
end sub

sub StartRafTask(rafHandlerConfig as Object, video as Object) as Object
    callback = {
        view : m.top
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
    m.RafTask = GetContentData(callback, rafHandlerConfig, CreateObject("roSGNode", "ContentNode"))
    if m.RafTask <> Invalid
        m.RafTask.video = video
    end if
end sub

sub OnContentLoaded()
    if m.top.currentIndex < 0 then m.top.currentIndex = 0

    currentItem = GetCurrentLoadedItem()

    if IsHandlerConfig(currentItem)
        SetState("contentLoading")
    else if currentItem <> invalid ' ready to play
        ShowBusySpinner(false)
        m.handlerConfigRAF = invalid
        ExtractRafConfig()
        ' Set content node that we receive to Media Node
        content = currentItem
        UpdateMediaModeByContent()
        m.media.content = content.Clone(false)
        if isCSASEnabled() then
            m.top.currentItem = currentItem
            SetState("StartRAFTask")
        else
            if m.rafHandlerConfig <> invalid and m.RafTask = invalid and m.top.mode = "video" and m.top.preloadContent = false and m.top.wasShown
                m.top.currentItem = currentItem
                SetState("StartRAFTask")
            else if m.top.control = "play" or m.top.control = "prebuffer"
                SetState("buffering")
            end if
        end if
    end if
end sub

function GetCurrentLoadedItem()
    currentItem = invalid

    if m.top.isContentList and m.top.content <> invalid and m.top.content.GetChildCount() > 0
        if HasNextItemInPlaylist()
            currentItem = m.top.content.GetChild(m.top.currentIndex)
        else if m.endcardView <> invalid
            ' we are on endcards and have no next item
            ' prebuffer current one so it will start quickly if user selects repeat
            currentItem = m.top.content.GetChild(m.top.currentIndex - 1)
        end if
    else ' single item
        currentItem = m.top.content
    end if

    return currentItem
end function

sub OnStartBuffering()
    ' Control field is roString type we should change it to String to force firmware to pass
    ' it by value, not reference
    control = m.top.control.toStr()
    if control = "play" or control = "prebuffer"
        if m.endcardView <> invalid
            ' prebuffer content on endcard
            m.media.control = "prebuffer"
        else
            StartPlayback(control)
        end if
    end if
end sub

sub ProcessEndState()
    ' video successfully finished so then we should handle next actions
    currentItem = GetCurrentLoadedItem()
    if m.RafTask = invalid and GetState() = "finished"
        HandlerConfigEndcard = invalid
        if currentItem <> invalid then HandlerConfigEndcard = currentItem.HandlerConfigEndcard
        if HandlerConfigEndcard <> invalid then currentItem.HandlerConfigEndcard = invalid
        ClearMediaNode()
        CreateMediaNode()
        m.top.currentIndex++
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
    if m.top.isContentList and HasNextItemInPlaylist()
        SetState("contentLoaded")
    else
        m.top.close = true
    end if
end sub

sub OnStartedPlayback()

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
    if m.media <> invalid
        errorCode = m.media.errorCode or (m.media.errorMsg <> invalid and m.media.errorMsg <> "")
        if errorCode <> 0
            ? "[SGDEX] media.errorCode == "; m.media.errorCode; " media.errorMsg == "; m.media.errorMsg
        end if
    end if

    m.top.close = true
end sub

sub OnFinishedEndcardLoadedTransition()
    SetState("endcardVisible")
end sub

sub OnEndcardVisibleTransition()
    m.endcardAvailable = true
    if m.spinnerGroup.visible then ShowBusySpinner(false)

    if m.endcardView = invalid
        m.endcardView = CreateObject("roSGNode", "EndcardView")
        m.endcardView.id = "endcardView"
        m.endcardView.translation = "[0, 0]"
        m.endcardView.endcardCountdownTime = m.top.endcardCountdownTime
        m.endcardView.hasNextItemInPlaylist = HasNextItemInPlaylist()
        if m.endcardContent <> invalid
            m.endcardView.content = m.endcardContent
        end if
        if m.lastThemeAttributes <> invalid
            endcardTheme = m.lastThemeAttributes
            sceneTheme = m.top.getScene().actualThemeParameters
            if sceneTheme <> invalid and sceneTheme.endcardView <> invalid
                endcardTheme.Append(sceneTheme.endcardView)
            end if
            m.endcardView.updateTheme = endcardTheme
        end if
        m.endcardView.startTimer = true
        m.endcardView.ObserveFieldScoped("rowItemSelected", "OnEndcardRowItemSelected")
        m.endcardView.ObserveFieldScoped("repeatButtonSelectedEvent", "OnRepeatButtonSelected")
        m.endcardView.ObserveFieldScoped("timerFired", "OnEndcardTimerFired")

        m.top.appendChild(m.endcardView)
        m.endcardView.SetFocus(true)

        if m.top.preloadContent
            m.top.control = "prebuffer"
            SetState("contentLoaded")
        end if
    end if
end sub

sub OnEndcardCloseTransition()
    m.endcardAvailable = false

    m.endcardView.visible = false
    m.endcardContent = invalid

    m.endcardView.UnObserveFieldScoped("rowItemSelected")
    m.endcardView.UnObserveFieldScoped("repeatButtonSelectedEvent")
    m.endcardView.UnObserveFieldScoped("timerFired")

    'need to keep initial focus
    wasInFocusChain = m.top.IsInFocusChain()

    m.top.RemoveChild(m.endcardView)
    m.endcardView = invalid

    if wasInFocusChain then m.top.SetFocus(true)
    SetState("completed")
end sub

sub OnEndcardCloseCompletedTransition()
    ' set control play if we were prebuffering on endcard
    m.top.control = "play"
    if IsContentLoaded()
        hasNextItemToPlay = (HasNextItemInPlaylist() or m.repeatButtonSelected) and m.top.endcardItemSelected = invalid
        m.repeatButtonSelected = false
        if hasNextItemToPlay
            if m.top.preloadContent and m.media.content <> invalid
                SetState("buffering")
            else
                SetState("contentLoaded")
            end if
        else
            m.top.close = true
        end if
    else
        ShowBusySpinner(true)
    end if
end sub

sub OnStartRAFTaskTransition()
    if isCSASEnabled() then
        ' TODO: remove code duplication
        StartRafTask(m.rafHandlerConfig, m.media)
        ' Sharing flag from HandlerConfigRAF to RAFtask
        m.RafTask.useCSAS = (m.rafHandlerConfig.useCSAS = true)
        ' Observing renderNode to theme RAFContentRenderer in CSAS mode
        m.RafTask.ObserveField("renderNode","OnRAFRenderNodeChanged")
        m.media.content = invalid
        if m.RafTask = invalid
            SetState("finished")
        else
            ShowBusySpinner(false)
            m.RafTask.ObserveField("isPlayingAds", "OnRAFPlayingAds")
        end if
    else
        StartRafTask(m.rafHandlerConfig, m.media)
        if m.RafTask = invalid
            SetState("buffering")
        else
            ShowBusySpinner(false)
            m.RafTask.ObserveField("isPlayingAds", "OnRAFPlayingAds")
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
    if m.RafTask <> Invalid
        m.RafTask.video = Invalid
        m.RafTask = Invalid
    end if
    SetState("finished")
end sub

sub OnRAFExitTransition()
    if m.RafTask <> Invalid
        m.RafTask.video = Invalid
        m.RafTask = Invalid
    end if
    m.top.close = true
end sub

sub OnRAFRenderNodeChanged()
    ' Unobserving node to avoid repetative theme set, caused by updating node
    m.RafTask.UnobserveField("renderNode")
    if m.RafTask <> Invalid and isCSASEnabled() and m.lastThemeAttributes <> Invalid then
        SetThemeToRAFRenderNode()
    end if
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
    if m.media <> invalid
        if m.top.IsInFocusChain() then m.media.SetFocus(true)
        if GetCurrentMode() = "video"
            m.media.visible = true
            m.media.enableUI = true
        else
            if control = "stop" or m.renderOverContent then
                m.buttonBar.opacity = 1.0
            else if control = "play"
                m.buttonBar.opacity = 0.0
            end if
        end if
        if control = "play" and m.rafHandlerConfig <> invalid then
            ' start RAFTask on play control if there is rafConfig
            SetState("StartRAFTask")
        else if not isCSASEnabled()
            ' set currentItem interface once we start playback
            m.top.currentItem = GetCurrentLoadedItem()
            m.media.control = control
        end if
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
    m.top.AppendChild(m.spinnerGroup)
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
    topControl = m.top.control
    if (currentItem.handlerConfigRAF <> invalid and currentItem.handlerConfigRAF.name <> "") then
        m.rafHandlerConfig = currentItem.handlerConfigRAF
        currentItem.handlerConfigRAF = invalid
    else if (m.top.content.handlerConfigRAF <> invalid and m.top.content.handlerConfigRAF.name <> "") then
        m.rafHandlerConfig = m.top.content.handlerConfigRAF
    else if (m.top.handlerConfigRAF <> invalid and m.top.handlerConfigRAF.name <> "") then
        m.rafHandlerConfig = m.top.handlerConfigRAF
    end if
end sub

sub CreateBookmarksHandler()
    currentItem = GetCurrentLoadedItem()
    if currentItem <> invalid then
        ' Setting length to MediaView before bookmark handler created
        ' to be able to save bookmarks
        if currentItem.length <> invalid and m.top.duration = 0 then
            m.top.duration = currentItem.length
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
                node.videoView = m.top
            else
                ? "Error: Unable to create handlerConfigBookmarks with type " NodeName
            end if
        else
            ' ? "Error: Invalid handlerConfigBookmarks config"
        end if
    end if
end sub

function NeedToShowEndcards(HandlerConfigEndcard as Object)
    return m.top.alwaysShowEndcards or HandlerConfigEndcard <> invalid
end function

function GetInternalToViewState(newState as String)
    viewState = m.internalToViewStateAA[newState]
    if viewState = invalid
        viewState = m.top.state
    end if
    return viewState
end function

function HasNextItemInPlaylist()
    if m.top.content <> invalid
        return (m.top.content.GetChildCount() > m.top.currentIndex)
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
            m.top.mode = "audio"
        else
            ' To handle case when playing mixed streamFormats in playlist
            if GetCurrentMode() = "audio" then m.top.mode = "video"
        end if

        m.mediaModeSet = false
    end if
end sub

function GetCurrentMode() as String
    if m.media <> invalid
        return m.media.id
    else
        return m.top.mode
    end if
end function

function isCSASEnabled() as Boolean
    return (m.rafHandlerConfig <> invalid and m.rafHandlerConfig.useCSAS = true)
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    key = LCase(key) ' safety check

    if press and GetCurrentMode() = "audio"
        position = Int(m.media.position)
        if key = "play"
            if m.media.state = "playing"
                m.media.control = "pause"
            else
                m.media.control = "resume"
            end if
        else if key = "right" and m.top.isContentList
            SetState("finished")
        else if key = "left" and m.top.isContentList
            m.top.currentIndex -= 2
            SetState("finished")
        else if key = "fastforward"
            if (m.media.duration - position) > 30
                m.media.seek = position + 30
            else
                SetState("finished")
            end if
        else if key = "rewind"
            position = position - 30
            if position < 0 then position = 0
            m.media.seek = position
        else if key = "replay"
            position = position - 10
            if position < 0 then position = 0
            m.media.seek = position
        end if
    end if
    return false
end function

' ************* Theme functions *************

sub SGDEX_SetTheme(theme as Object)
    SGDEX_setThemeFieldstoNode(m, {
        TextColor: {
            media: [
                {
                    trickPlayBar:  [
                        "textColor"
                        "thumbBlendColor"
                        "trackBlendColor"
                        "currentTimeMarkerBlendColor"
                    ]
                    retrievingBar: [
                        "trackBlendColor"
                    ]
                    bufferingBar: [
                        "trackBlendColor"
                    ]
                }
                "bufferingTextColor",
                "retrievingTextColor"
            ]
        }
        progressBarColor: {
            media: [{
                trickPlayBar:  [
                    "filledBarBlendColor"
                ]
                retrievingBar: [
                    "filledBarBlendColor"
                ]
                bufferingBar: [
                    "filledBarBlendColor"
                ]
            }]
        }
    }, theme)

    themeAttributes = {
        ' trickplay Bar customization
        trickPlayBarTextColor:                      { media: { trickPlayBar: "textColor" } }
        trickPlayBarTrackImageUri:                  { media: { trickPlayBar: "trackImageUri" } }
        trickPlayBarTrackBlendColor:                { media: { trickPlayBar: "trackBlendColor" } }
        trickPlayBarThumbBlendColor:                { media: { trickPlayBar: "thumbBlendColor" } }
        trickPlayBarFilledBarImageUri:              { media: { trickPlayBar: "filledBarImageUri" } }
        trickPlayBarFilledBarBlendColor:            { media: { trickPlayBar: "filledBarBlendColor" } }
        trickPlayBarCurrentTimeMarkerBlendColor:    { media: { trickPlayBar: "currentTimeMarkerBlendColor" } }

        ' Buffering Bar customization
        bufferingTextColor:                         { media: "bufferingTextColor" }
        bufferingBarEmptyBarImageUri:               { media: { bufferingBar: "emptyBarImageUri" } }
        bufferingBarFilledBarImageUri:              { media: { bufferingBar: "filledBarImageUri" } }
        bufferingBarTrackImageUri:                  { media: { bufferingBar: "trackImageUri" } }

        bufferingBarTrackBlendColor:                { media: { bufferingBar: "trackBlendColor" } }
        bufferingBarEmptyBarBlendColor:             { media: { bufferingBar: "emptyBarBlendColor" } }
        bufferingBarFilledBarBlendColor:            { media: { bufferingBar: "filledBarBlendColor" } }

        ' Retrieving Bar customization
        retrievingTextColor:                        { media: "retrievingTextColor" }
        retrievingBarEmptyBarImageUri:              { media: { retrievingBar: "emptyBarImageUri" } }
        retrievingBarFilledBarImageUri:             { media: { retrievingBar: "filledBarImageUri" } }
        retrievingBarTrackImageUri:                 { media: { retrievingBar: "trackImageUri" } }

        retrievingBarTrackBlendColor:               { media: { retrievingBar: "trackBlendColor" } }
        retrievingBarEmptyBarBlendColor:            { media: { retrievingBar: "emptyBarBlendColor" } }
        retrievingBarFilledBarBlendColor:           { media: { retrievingBar: "filledBarBlendColor" } }

        ' BIF customization
        focusRingColor:                             { media: { bifDisplay: "frameBgBlendColor" } }
    }

    ' RDE-2876: Workaround to prevent user from  unintentionally changing clock color
    ' when setting explicitly trickPlayBarTextColor and retrievingTextColor fields
    if theme.textColor = invalid and (theme.trickPlayBarTextColor <> invalid or theme.retrievingTextColor <> invalid)
        SGDEX_setThemeFieldstoNode(m, themeAttributes, {
            trickPlayBarTextColor: "0xffffff"
            retrievingTextColor: "0xffffff"
        })
    end if

    SGDEX_setThemeFieldstoNode(m, themeAttributes, theme)
end sub

sub SetThemeToRAFRenderNode()
    SGDEX_setThemeFieldstoNode(m.RAFTask, {
        TextColor: {
            renderNode: [
                {
                    trickPlayBar:  [
                        "textColor"
                        "thumbBlendColor"
                        "trackBlendColor"
                        "currentTimeMarkerBlendColor"
                    ]
                    retrievingBar: [
                        "trackBlendColor"
                    ]
                    bufferingBar: [
                        "trackBlendColor"
                    ]
                }
                "bufferingTextColor",
                "retrievingTextColor"
            ]
        }
        progressBarColor: {
            renderNode: [{
                trickPlayBar:  [
                    "filledBarBlendColor"
                ]
                retrievingBar: [
                    "filledBarBlendColor"
                ]
                bufferingBar: [
                    "filledBarBlendColor"
                ]
            }]
        }
    }, m.lastThemeAttributes)

    themeAttributes = {
        ' trickplay Bar customization
        trickPlayBarTextColor:                      { renderNode: { trickPlayBar: "textColor" } }
        trickPlayBarTrackImageUri:                  { renderNode: { trickPlayBar: "trackImageUri" } }
        trickPlayBarTrackBlendColor:                { renderNode: { trickPlayBar: "trackBlendColor" } }
        trickPlayBarThumbBlendColor:                { renderNode: { trickPlayBar: "thumbBlendColor" } }
        trickPlayBarFilledBarImageUri:              { renderNode: { trickPlayBar: "filledBarImageUri" } }
        trickPlayBarFilledBarBlendColor:            { renderNode: { trickPlayBar: "filledBarBlendColor" } }
        trickPlayBarCurrentTimeMarkerBlendColor:    { renderNode: { trickPlayBar: "currentTimeMarkerBlendColor" } }

        ' Buffering Bar customization
        bufferingTextColor:                         { renderNode: "bufferingTextColor" }
        bufferingBarEmptyBarImageUri:               { renderNode: { bufferingBar: "emptyBarImageUri" } }
        bufferingBarFilledBarImageUri:              { renderNode: { bufferingBar: "filledBarImageUri" } }
        bufferingBarTrackImageUri:                  { renderNode: { bufferingBar: "trackImageUri" } }

        bufferingBarTrackBlendColor:                { renderNode: { bufferingBar: "trackBlendColor" } }
        bufferingBarEmptyBarBlendColor:             { renderNode: { bufferingBar: "emptyBarBlendColor" } }
        bufferingBarFilledBarBlendColor:            { renderNode: { bufferingBar: "filledBarBlendColor" } }

        ' Retrieving Bar customization
        retrievingTextColor:                        { renderNode: "retrievingTextColor" }
        retrievingBarEmptyBarImageUri:              { renderNode: { retrievingBar: "emptyBarImageUri" } }
        retrievingBarFilledBarImageUri:             { renderNode: { retrievingBar: "filledBarImageUri" } }
        retrievingBarTrackImageUri:                 { renderNode: { retrievingBar: "trackImageUri" } }

        retrievingBarTrackBlendColor:               { renderNode: { retrievingBar: "trackBlendColor" } }
        retrievingBarEmptyBarBlendColor:            { renderNode: { retrievingBar: "emptyBarBlendColor" } }
        retrievingBarFilledBarBlendColor:           { renderNode: { retrievingBar: "filledBarBlendColor" } }

        ' BIF customization
        focusRingColor:                             { renderNode: { bifDisplay: "frameBgBlendColor" } }
    }

    SGDEX_setThemeFieldstoNode(m.RAFTask, themeAttributes, m.lastThemeAttributes)
end sub

function SGDEX_GetViewType() as String
    return "mediaView"
end function

sub SGDEX_UpdateViewUI()

end sub