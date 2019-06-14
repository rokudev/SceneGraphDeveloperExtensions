' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub OnRootContentLoaded()
    ' remove root config
    m.top.content[m.Handler_ConfigField] = invalid
    m.top.content.isLoaded = true

    requiredRowsCount = 3
    numrowsToLoad = GetNumRowsToLoad()

    nonEmptyRows = 0

    if requiredRowsCount > m.top.content.getChildCount() then
        requiredRowsCount = m.top.content.getChildCount()
    end if

    MarkRows()
    for each row in m.top.content.GetChildren(-1, 0)
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
        m.view.content = m.top.content
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
    if m.view.content <> invalid then
        focusedChannel = m.view.channelFocused
        focusedItem = m.view.programFocused
        if focusedItem = invalid or focusedItem < 0 then focusedItem = 0
        if focusedChannel = invalid or focusedChannel < 0 then focusedChannel = 0
        if m.debug then ? "new priority for rows near "focusedChannel
        rowPriority = 10
        itemPriority = 10
        rows = m.view.content.GetChildren( - 1, 0)
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
            ? "adding page to queue"

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
        content = m.top.content
        rowCount = content.getChildCount()

        for each row in content.GetChildren(-1, 0)
            if row.getChildCount() > 0 OR row.isFailed = true then nonEmptyRows++
        end for

        if nonEmptyRows >= requiredRowsCount OR nonEmptyRows = rowCount then
            m.view.content = content
        end if
    end if
End Sub

Function IsContentSet() as Boolean
    return m.view.content <> invalid
End Function
