sub Init()
    m.Handler_ConfigField = "HandlerConfigDetails"
    m.debug = false
    m.ContentManager_id = 0
    m.detailsLoadingMap = {}
    m.DetailsContentManager_id = 1
end sub

sub OnConfigFieldNameChanged()
    if m.top.configFieldName <> ""
        m.Handler_ConfigField = m.top.configFieldName
    end if
end sub

' this function is called outside to set view to this content manager
' this is done so that view doesn' t even have to know about content manager
sub setView(view as Object)
    m.topView = view
    if m.topView <> invalid
        ' try to locate child UI node having id=contentRendererId to use one
        ' for the content rendering behind the scenes
        m.contentRenderer = m.topView.FindNode(m.top.contentRendererId)
        
        SetOptionalFields()
        CreateSpinner()

        m.topView.ObserveField("wasShown", "OnWasShown")
        m.topView.ObserveField("itemFocused", "OnItemFocusedChanged")
        m.contentObserverIsSet = false

        ' Reference to current ContentNode which populated to DetailsView
        ' To differentiate ContentNode change and ContentNode field change
        m.currentContentNode = invalid
    else
        ? "ERROR, Content Manager, received invalid view"
    end if
end sub

sub CreateSpinner()
    m.spinner = m.topView.FindNode("spinner")
end sub

sub SetOptionalFields()
    fieldsMap = {
        isContentList: {default: true, type: "boolean" }
        itemFocused: {default: 0, type: "integer" }
        currentItem: {default: invalid, type: "node" }
        wasShown: {default: false, type: "boolean" }
        wasClosed: {default: false, type: "boolean" }
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

sub OnWasShown()
    if m.topView.wasShown
        OnContentSet()

        ' Content observer should be set after DetailsView was shown
        ' in other case there can be race condition with setting
        ' content and isContentList fields
        if not m.contentObserverIsSet
            m.topView.ObserveField("content", "OnContentSet")
            m.contentObserverIsSet = true
        end if
    end if
end sub

sub OnContentSet()
    if m.topView.content <> invalid
        ' Handles if callback triggered by changing field of ContentNode or
        ' replace with new ContentNode by saving reference to m.currentContentNode
        if (m.currentContentNode = invalid or not m.currentContentNode.isSameNode(m.topView.content))
            if m.topView.isContentList
                ' apply view content to m.contentRenderer, if any, for rendering
                if m.contentRenderer <> invalid
                    m.contentRenderer.content = m.topView.content
                end if
                
                ' check if we have empty root content with proper HandlerConfig
                if m.topView.content[m.Handler_ConfigField] <> invalid and m.topView.content.GetChildCount() = 0
                    ' Show loading indicator
                    ' Content should be visible
                    ShowBusySpinner(true)
                    config = m.topView.content[m.Handler_ConfigField]
                    callback = {
                        config: config
                        onReceive: sub(data)
                            gthis = GetGlobalAA()
                            if data <> invalid and data.GetChildCount() > 0
                                ' invalidate CH config field on the view content
                                if gthis.topView.content <> invalid
                                    gthis.topView.content[gthis.Handler_ConfigField] = invalid
                                end if
                                ' replace data if needed
                                if not data.IsSameNode(gthis.topView.content) then gthis.topView.content = data
                                ' fire focus change that will redraw UI and tell developer which item is focused
                                OnItemFocusedChanged()
                            end if
                        end sub

                        onError: sub(data)
                            gthis = GetGlobalAA()
                            if gthis.topView.content[gthis.Handler_ConfigField] <> invalid
                                m.config = gthis.topView.content[gthis.Handler_ConfigField]
                                gthis.topView.content[gthis.Handler_ConfigField] = invalid
                            end if
                            GetContentData(m, m.config, gthis.topView.content)
                        end sub
                    }
                    GetContentData(callback, config, m.topView.content)
                else if m.topView.content.GetChildCount() > 0
                    ' trigger loading of first content
                    m.topView.itemFocused = m.topView.itemFocused
                end if
                ' this is not list of items
                ' check if we need to load extra data for this item
            else if m.topView.content[m.Handler_ConfigField] <> invalid
                ShowBusySpinner(false)
                ' load extra metadata
                LoadMoreContent(m.topView.content, m.topView.content[m.Handler_ConfigField])
            else ' This is single item that has everything loaded
                ' update current item so developer would know that everything is loaded
                m.topView.currentItem = m.topView.content
                ' disable spinner as the content has been fully loaded
                ShowBusySpinner(false)
            end if

            m.currentContentNode = m.topView.content
        end if
    else
        ShowBusySpinner(false)
    end if
end sub

sub OnItemFocusedChanged()
    focusedItem = m.topView.itemFocused
    if m.topView.isContentList
        content = m.topView.content.GetChild(focusedItem)
        if content <> invalid
            HandlerConfigDetails = content[m.Handler_ConfigField]
            ' if we have details to load then load them, else set item to details
            if HandlerConfigDetails <> invalid
                content[m.Handler_ConfigField] = invalid
                LoadMoreContent(content, HandlerConfigDetails)
                m.topView.currentItem = invalid
            else
                ' disable spinner as the content has been fully loaded
                ShowBusySpinner(false)
                m.topView.currentItem = content
            end if
        end if
    else
        ' ?"this is not list"
        ' TODO add logic here if needed
    end if
end sub

sub LoadMoreContent(content, HandlerConfig)
    ShowBusySpinner(true)

    callback = {
        config: HandlerConfig
        content: content
        view: m.topView

        lastFocusedItem: m.topView.itemFocused
        detailsLoadingMap_ID: m.DetailsContentManager_id

        ' this flag tells utilities not to fire error when we content doesn' t have children
        ' because one item on details View doesn' t have children
        mAllowEmptyResponse: true

        onReceive: function(data)
            m.SetContent(data)
        end function

        onError: function(data)
            gThis = GetGlobalAA()
            if m.content[gThis.Handler_ConfigField] <> invalid
                m.config = m.content[gThis.Handler_ConfigField]
                m.content[gThis.Handler_ConfigField] = invalid
            end if
            GetContentData(m, m.config, m.content)
        end function

        setContent: sub(content)
            gThis =  GetGlobalAA()
            gThis.detailsLoadingMap.Delete(content.detailsLoadingMap_ID.Tostr())
            if m.lastFocusedItem = gthis.topView.itemFocused
                gthis.topView.currentItem = content
                ' disable spinner as the content has been fully loaded
                ShowBusySpinner(false)
                m.content[gThis.Handler_ConfigField] = invalid
            end if
        end sub
    }
    isAlreadyLoading = false
    if content <> invalid
        if not content.HasField("detailsLoadingMap_ID")
            content.Addfields({ detailsLoadingMap_ID: m.DetailsContentManager_id })
            m.DetailsContentManager_id++

        ' Check If we already load this item, if yes then skip loading
        else if m.detailsLoadingMap[content.detailsLoadingMap_ID.Tostr()] <> invalid
            isAlreadyLoading = true
        else if content.detailsLoadingMap_ID <= 0
            content.detailsLoadingMap_ID = m.DetailsContentManager_id
            m.DetailsContentManager_id++
        end if
        ' don't set this item to already loading map so we don' t have issues with busy spinner
        if not isAlreadyLoading
            key = content.detailsLoadingMap_ID.Tostr()
            m.detailsLoadingMap[key] = content
        end if
    end if
    if not isAlreadyLoading
        GetContentData(callback, HandlerConfig, content)
    end if
end sub

sub ShowBusySpinner(shouldShow)
    if m.spinner <> invalid
        if shouldShow
            if not m.spinner.visible
                m.spinner.visible = true
                m.spinner.control = "start"
            end if
        else
            m.spinner.visible = false
            m.spinner.control = "stop"
        end if
    end if
end sub
