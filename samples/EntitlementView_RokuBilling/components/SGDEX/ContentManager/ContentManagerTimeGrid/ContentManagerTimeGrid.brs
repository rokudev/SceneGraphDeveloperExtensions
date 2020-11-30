' Copyright (c) 2018 Roku, Inc. All rights reserved.
sub init()
    InitContentGetterValues()
    m.MAX_RADIUS = 45
    m.debug = false
    m.Handler_ConfigField = "HandlerConfigTimeGrid"
    m.SectionKeyField = "CM_row_ID_Index"

    m.lazyLoadingTimer = CreateObject("roSGNode", "Timer")
    m.lazyLoadingTimer.repeat = false
    m.lazyLoadingTimer.duration = 3
    m.lazyLoadingTimer.observeField("fire", "StartContentLoading")
end sub

sub setView(view as Object)
    m.topView = view
    if m.topView <> invalid then
        'add control observers so we don't start any background job when view is not visible
        view.ObserveField("content", "OnContentChange")
        view.ObserveField("focusedChild", "OnFocusedChild")
        view.observeField("posterShape", "OnPosterShapeChange")

        m.view = m.topView.FindNode("contentTimeGrid")
        m.view.observeField("channelFocused", "channelFocused")
        m.view.observeField("programFocused", "programFocused")
        m.view.observeField("leftEdgeTargetTime", "onLeftEdgeTimeChanged")
        m.view.observeField("isScrolling", "onLeftEdgeTimeChanged")
    else
        ? "ERROR, Content Manager, received invalid view"
    end if
end sub

sub OnConfigFieldNameChanged()
    if m.top.configFieldName <> ""
        m.Handler_ConfigField = m.top.configFieldName
    end if
end sub

sub OnFocusedChild()
    if m.topView.isInFocusChain() and not m.view.hasFocus() then
        m.view.setFocus(true)
    end if
end sub

sub OnContentChange()
    if m.topView.content <> invalid
        if not m.topView.content.IsSameNode(m.view.content) and not m.topView.content.IsSameNode(m.content) then
            m.content = m.topView.content
            PopulateLoadingFlags(m.topView.content)
            if m.topView.content[m.Handler_ConfigField] <> invalid and m.topView.content.GetChildCount() = 0
                config = m.topView.content[m.Handler_ConfigField]
                callback = {
                    config: config
                    content: m.topView.content
                    onReceive: sub(data)
                        OnRootContentLoaded()
                    end sub

                    onError: sub(data)
                        config = m.config
                        gthis = GetGlobalAA()
                        if m.content[gthis.Handler_ConfigField] <> invalid then
                            config = m.content[gthis.Handler_ConfigField]
                        end if

                        GetContentData(m, config, m.content)
                    end sub
                }
                GetContentData(callback, config, m.topView.content)
            else if m.topView.content.GetChildCount() > 0
                OnRootContentLoaded()
            end if
        end if
    end if
end sub

sub OnRootContentLoaded()
    ' remove root config
    m.topView.content[m.Handler_ConfigField] = invalid
    m.topView.content.isLoaded = true

    requiredRowsCount = 3
    numrowsToLoad = GetNumRowsToLoad()

    nonEmptyRows = 0

    if requiredRowsCount > m.topView.content.getChildCount() then
        requiredRowsCount = m.topView.content.getChildCount()
    end if

    MarkRows()
    for each row in m.topView.content.GetChildren(-1, 0)
        PopulateLoadingFlags(row)
        if row.GetChildCount() > 0 then
            nonEmptyRows++
            row.isLoaded = true
            row.isLoading = false
            row.isFailed = false
        else
            if row[m.Handler_ConfigField] <> invalid then
                ' row needs to be loaded
                callback = {
                    row : row
                    onReceive : sub(data)
                        ClearPageFails(m.row, 0)
                        RemovePageFromQueue(m.row, 0)
                        TryToSetContent()
                    end sub
                }
                LoadContentForRow(row, callback)
            end if
        end if
        if numrowsToLoad <= 0 then
            ' we are loading start amount of rows
            exit for
        end if
        numRowsToLoad--
    end for

    canSetContent = true 'nonEmptyRows >= requiredRowsCount

    if canSetContent then
        m.view.content = m.topView.content
    else
        ShouldTryToSetContentOnLoad(true)
    end if
end sub

sub LoadContentForRow(row, callback = invalid as Object)
    aditionalParams = {}
    shouldDeleteHandlerConfig = not IsInsertionMode(row[m.Handler_ConfigField])

    simpleLoadFunction = sub(data, isSuccess)
        if GetGlobalAA().debug then ? "received row content="m.row.title
        m.row.isLoading = false
        m.row.isLoaded = isSuccess
        if m.callback <> invalid
            if isSuccess or m.callback.onError = invalid
                if m.callback.onReceive <> invalid then m.callback.OnReceive(data)
            else if m.callback.onError <> invalid then
                m.callback.OnError(data)
            end if
            ' if no extra callback was passed and we failed then we have to restore config
        else if not isSuccess then
            Handler_ConfigField = GetGlobalAA().Handler_ConfigField

            if m.row[Handler_ConfigField] = invalid then
                m.row[Handler_ConfigField] = m.config
            end if
        end if
    end sub

    functionToUse = simpleLoadFunction

    rowIndex = invalid
    itemIndex = -2
    config = row[m.Handler_ConfigField]

    callback = {
        ' this will be used for sorting
        itemIndex: itemIndex
        ' extra callback if needed
        callback: callback
        ' current loading row
        row: row
        ' simple load function that executes basic functionality
        simpleLoadFunction: simpleLoadFunction
        ' config that is used to retrieve content
        config: config

        functionToUse: functionToUse
        onReceive: sub(data)
            m.FunctionToUse(data, true)
        end sub
        onError: sub(data)
            m.FunctionToUse(data, false)
        end sub
    }

    QueueGetContentData(callback, config, row, aditionalParams, true)
    addPageToQueue(row, 0)
    if shouldDeleteHandlerConfig then row[m.Handler_ConfigField] = invalid

    row.isLoaded = false
    row.isLoading = true
    row.isFailed = false
end sub

function GetNumRowsToLoad()
    return 5
end function

sub doPrioritySort()
    if m.topView.content <> invalid then
        focusedChannel = m.topView.channelFocused
        focusedItem = m.topView.programFocused
        if focusedItem = invalid or focusedItem < 0 then focusedItem = 0
        if focusedChannel = invalid or focusedChannel < 0 then focusedChannel = 0
        if m.debug then ? "new priority for rows near "focusedChannel
        rowPriority = 10
        itemPriority = 10
        rows = m.topView.content.GetChildren( - 1, 0)
        for each taskObject in m.waitingQueue
            ' set new priority
            rowId = taskObject.id[0]
            itemId = taskObject.id[1]
            row = rows[rowId]

            if row <> invalid then
                focusedItem = getFocusedItem(row, 0)

                diffRow = Abs(focusedChannel - rowId)
                diffItem = Abs(focusedItem - itemId)
                ' calculate distance from end of row
                secondItemDiff = diffItem

                secondItemDiff = row.GetChildCount() - itemId + focusedItem
                ' take smallest distance
                if diffItem > secondItemDiff then diffItem = secondItemDiff
                diff = diffItem
                if diff < diffRow then diff = diffRow
                taskObject.priority = diff + rowPriority * diffRow + diffItem * itemPriority
            end if
        end for
        ' sort the queue
        m.waitingQueue.SortBy("priority", "r")
    end if
end sub

sub LoadInsertionContent(pageToLoad, row)
    mapKey = pageToLoad.index
    shouldDeleteHandlerConfig = not IsInsertionMode(row[m.Handler_ConfigField])
    if not isPageAlreadyInQueue(row, mapKey)
        callback = {
            ' this will be used for sorting
            itemIndex: mapKey
            ' extra callback if needed
            row: row
            ' simple load function that executes basic functionality

            onReceive: sub(data)
                ClearPageFails(m.row, m.itemIndex)
                RemovePageFromQueue(m.row, m.itemIndex)
            end sub

            onError: sub(data)
                ClearPageFails(m.row, m.itemIndex)
                RemovePageFromQueue(m.row, m.itemIndex)
            end sub
        }

        fields = {
            startTime: pageToLoad.pageNum
            offset: pageToLoad.index + 1 'we need to insert content after this point
            endTime: pageToLoad.endTime
        }
        'just simple check if everything is done correctly
        if fields.startTime < fields.endTime OR (fields.startTime > 0 AND fields.endTime = 0) then
            config = row[m.Handler_ConfigField]
            if m.debug then ? "adding page to queue"
            QueueGetContentData(callback, config, row, fields, true)
            addPageToQueue(row, mapKey)
            if shouldDeleteHandlerConfig then row[m.Handler_ConfigField] = invalid
        end if
    end if
end sub

sub ShouldTryToSetContentOnLoad(should as Boolean)
    m._tryToSetContentOnLoad = should
end sub

Sub TryToSetContent()
    if m._tryToSetContentOnLoad = true AND not IsContentSet() then
        requiredRowsCount = 3
        nonEmptyRows = 0
        content = m.topView.content
        rowCount = content.getChildCount()

        for each row in content.GetChildren(-1, 0)
            if row.getChildCount() > 0 OR row.isFailed = true then nonEmptyRows++
        end for

        if nonEmptyRows >= requiredRowsCount OR nonEmptyRows = rowCount then
            m.topView.content = content
        end if
    end if
End Sub

Function IsContentSet() as Boolean
    return m.topView.content <> invalid
End Function

function channelFocused(event as Object)
    RestartLazyLoadingTimer()
    if m.view <> invalid
        ChannelProgramFocused(m.view.channelFocused, m.view.programFocused)
    end if
end function

function programFocused(event as Object)
    RestartLazyLoadingTimer()
    if m.view <> invalid
        ChannelProgramFocused(m.view.channelFocused, m.view.programFocused)
    end if
end function

Sub RestartLazyLoadingTimer()
    m.lazyLoadingTimer.control = "stop"
    m.lazyLoadingTimer.control = "start"
End Sub

' ChannelProgramFocused is invoked when either channelFocused or programFocused was changed
' Used for loading content when user navigates vertically
' And updating the item details panel
sub ChannelProgramFocused(currentRowIndex as Integer, currentItemIndex as Integer)
    row = invalid
    if m.view.content <> invalid then
        row = m.view.content.GetChild(currentRowIndex)
    end if
    if row <> invalid
        focusIndexToSet = currentItemIndex
        if currentItemIndex < 0 then currentItemIndex = 0
        if m.previousFocusedRow <> currentRowIndex
            StartContentLoading(true)
        end if
    end if
    m.previousFocusedRow = currentRowIndex
    m.previousFocusedItemIndex = currentItemIndex
end sub

Sub StartContentLoading(populateOnlyVisibleChannels = false as Boolean, leftEdgeTargetTimePriority = true as Boolean)
    channelIndex = m.view.channelFocused
    programIndex = m.view.programFocused
    content = m.view.content
    if m.topView.content <> invalid and content = invalid
        ' if content was set before view was shown
        OnContentChange()
        return
    end if

    if content = invalid then return
    channel = content.GetChild(channelIndex)
    if channel = invalid then return 'invalid focus event'
    program = channel.GetChild(programIndex)
    if program = invalid OR leftEdgeTargetTimePriority then
        startTime = m.view.leftEdgeTargetTime
    else
        startTime = program.playstart
    end if

    visibleChannelsToLoad = m.view.numRows - 1
    outOfScreenChannelsToLoad = m.view.numRows
    outOfScreenCacheTimeToLoad = 3600 * 3
    if populateOnlyVisibleChannels then outOfScreenChannelsToLoad = 0
    startChannelIndex = channelIndex - outOfScreenChannelsToLoad
    totalChannelsToLoad = visibleChannelsToLoad + outOfScreenChannelsToLoad*2
    channelIndexIterator = NewCycleNodeChildrenIterator(content, startChannelIndex, totalChannelsToLoad)

    if IsInsertionMode(channel[m.Handler_ConfigField]) then
        CACHE_TIME = channel[m.Handler_ConfigField].pageSize * 3600
        if not populateOnlyVisibleChannels then
            startTime -= outOfScreenCacheTimeToLoad
            if startTime < m.view.contentStartTime then
                startTime = m.view.contentStartTime
            end if
            CACHE_TIME += outOfScreenCacheTimeToLoad * 2
        else
            startTime -= 3600
        end if
    else
        CACHE_TIME = 0
        startTime = m.view.contentStartTime
    end if

    channelsProcessed = 0

    while true
        i = channelIndexIterator.GetIndex()
        if not isPageAlreadyInQueue(i, 0) then
            channelNode = content.GetChild(i)
            pageToLoad = getPageToLoadInRange(channelNode, startTime, startTime + CACHE_TIME)
            if pageToLoad <> invalid then
                LoadInsertionContent(pageToLoad, channelNode)
            end if
        end if
        channelsProcessed++
        if not channelIndexIterator.IsNextAvailable() then exit while
        channelIndexIterator.Next()
    end while

    RestartLazyLoadingTimer()
End Sub

Function NewCycleNodeChildrenIterator(node, startIndex, count) as Object
    maxIndex = node.GetChildCount() - 1

    while startIndex < 0
        startIndex = maxIndex + startIndex
    end while

    if startIndex > maxIndex then
        startIndex = maxIndex
    end if

    return {
        _node: node

        _max_index: maxIndex
        _index: startIndex

        _max_count: count
        _current_count: 0

        IsNextAvailable: function() as Boolean
            return m._current_count < m._max_count
        end function

        Next : function() as Integer
            if m.IsNextAvailable() then
                if m._index >= m._max_index then
                    m._index = 0
                else if m._index < m._max_index then
                    m._index++
                end if
                m._current_count++
            end if
            return m._index
        end function

        GetIndex: function() as integer
            return m._index
        end function
    }
End Function

Function getPageToLoadInRange(channelNode, startTime, endTime)
    if not IsInsertionMode(channelNode[m.Handler_ConfigField]) then
        ' will be executed only once
        if channelNode.getChildCount() > 0 then return invalid

        ' request only start without limitation of end
        return {
            pageNum: startTime
            index: 0
            endTime: 0
        }
    end if

    insertPosition = 0

    for i = 0 to channelNode.GetChildCount() - 1
        insertPosition = i
        programNode = channelNode.GetChild(i)

        if programNode.PlayStart >= endTime then
            ' we should insert content before this item
            ' fixes issue with inserting content when scrolling backward
            ' and there is no content on very beginning of the row
            insertPosition -= 1
            exit for
        end if

        if programNode.PlayStart <= startTime AND (programNode.PlayStart + programNode.PlayDuration) > startTime then
            startTime = programNode.PlayStart + programNode.playduration
        end if

        if programNode.PlayStart > startTime then
            ' Limit end time by next program start time - 1 seconds in order to avoid duplicates'
            endTime = programNode.PlayStart - 1
            insertPosition -= 1
            exit for
        end if
    end for

    if startTime >= endTime then return invalid

    return {
        pageNum: startTime
        index: insertPosition
        endTime: endTime
    }
End Function

Sub onLeftEdgeTimeChanged()
    RestartLazyLoadingTimer()
    
    ' for backward compatibility with native TimeGridView that has
    ' extended TimeGrid with "isScrolling" field available
    if m.view.isScrolling <> true
        ' custom views based on standard RSG TimeGrid will always
        ' initiate content loading as isScrolling will be invalid
        StartContentLoading(true)
    end if
End Sub

function OnPosterShapeChange() as Object
    if m.topView.content <> invalid then
        ChannelProgramFocused(m.view.channelFocused, m.view.programFocused)
    end if
end function
