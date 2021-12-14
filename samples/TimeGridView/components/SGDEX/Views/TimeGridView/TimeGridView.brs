' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

function Init()
    InitTimeGridViewNodes()
    m.spinner = m.top.FindNode("spinner")
    m.spinner.uri = "pkg:/components/SGDEX/Images/loader.png"
    ShowSpinner(true)

    m.debug = false

    m.top.ObserveField("focusedChild", "OnFocusedChild")
    m.top.ObserveField("wasShown", "OnWasShown")
    m.top.ObserveField("content", "OnContentChange")

    m.view.observeField("content", "onTimeGridViewContentChange")

    m.top.ObserveField("jumpToRow", "OnJumpToRowChanged")
    m.top.ObserveField("jumpToRowItem", "OnJumpToRowItemChanged")

    m.top.ObserveField("posterShape", "OnPosterShapeChange")
    m.top.posterShape = "4x3"

    m.view.setFields({
        showPastTimeScreen: true
        channelInfoComponentName: "TimeGridChannelItemComponent"
    })

    m.view.observeField("channelFocused", "channelFocused")
    m.view.observeField("programFocused", "programFocused")
    m.view.observeField("programSelected", "OnProgramSelected")

    currentTime =  CreateObject("roDateTime") ' roDateTime is initialized
    ' to the current time
    t = currentTime.AsSeconds()
    t = t - (t mod 1800) ' RDE-2665 - TimeGrid works best when contentStartTime is set to a 30m mark
    m.view.contentStartTime = t
    m.view.leftEdgeTargetTime = currentTime.AsSeconds()

    m.view.channelNoDataText = "Loading..."
    m.view.loadingDataText = "Loading..."
    m.view.automaticLoadingDataFeedback = false

    m.view.numRows = 7
    m.view.fillProgramGaps = true

    ' View constants
    m.detailsTimeGridSpacing = 25
    m.timeGridWasMoved = false
end function

sub InitTimeGridViewNodes()
    m.details = m.top.viewContentGroup.CreateChild("ItemDetailsView")
    m.details.Update({
        id: "details"
        translation: [105,0]
        maxWidth: 666
    })

    m.poster = m.top.viewContentGroup.CreateChild("StyledPoster")
    m.poster.Update({
        id: "poster"
        translation: [125, 0]
        maxWidth: 357
        maxHeight: 201
    })

    m.view = m.top.findNode("contentTimeGrid")
    m.view.Reparent(m.top.viewContentGroup, false)
end sub

sub ShowSpinner(show)
    m.spinner.visible = show
    if show
        m.spinner.control = "start"
    else
        m.spinner.control = "stop"
    end if
end sub

' OnProgramSelected triggered when timeGrid.programSelected updated on user
' selection. Updating rowItemSelected interface to have similar behavior
' with GridView
sub OnProgramSelected(event as Object)
    timeGrid = event.GetRoSGNode()
    m.top.rowItemSelected = [timeGrid.channelSelected, timeGrid.programSelected]
end sub

function channelFocused(event as Object)
    if m.view <> invalid
        ChannelProgramFocused(m.view.channelFocused, m.view.programFocused)
    end if
end function

function programFocused(event as Object)
    if m.view <> invalid
        ChannelProgramFocused(m.view.channelFocused, m.view.programFocused)
    end if
end function

sub OnJumpToRowChanged(event as Object)
    row = event.getData()
    if m.view <> invalid
        m.view.jumpToChannel = row
    end if
end sub

sub OnJumpToRowItemChanged(event as Object)
    jumpToRowItem = event.getData()
    if m.view <> invalid
        m.view.jumpToChannel = jumpToRowItem[0]
        m.view.jumpToProgram = jumpToRowItem[1]
    end if
end sub

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
        UpdateItemDetails(currentRowIndex, currentItemIndex)

    end if
    m.previousFocusedRow = currentRowIndex
    m.previousFocusedItemIndex = currentItemIndex
end sub

sub UpdateItemDetails(channelIndex, programIndex)
    content = m.view.content
    if content = invalid then return
    channel = content.GetChild(channelIndex)
    if channel = invalid then return
    program = channel.GetChild(programIndex)

    shouldClearMeta = false
    if program = invalid then
        shouldClearMeta = true
    else
        diff = m.view.leftEdgeTargetTime - program.PLAYSTART

        bIsInPast = diff > 0 and diff - program.playduration > 0
        bIsInFuture = diff + m.view.duration < 0

        if bIsInPast then ' need to account duration that item might be partly visible
            ' focused item is in past
            shouldClearMeta = true
        else if bIsInFuture then ' item might be partly visible in future
            ' focused item is in future
            shouldClearMeta = true
        end if

        if m.debug then
            ?"---------------"
            ? " diff "diff " duration "m.view.duration
            ? "diff is past "bIsInPast
            ?" diff is future "bIsInFuture
            ?"---------------"
        end if
    end if

    if shouldClearMeta
        program = CreateObject("roSGNode", "ContentNode")
        ' don't set any title here
        ' in some cases content wouldn't even be loaded in future,
        ' as there might be no config for channel
        program.title = ""
    end if

    m.details.content = program
    m.poster.uri = program.hdposterurl
    if m.poster.uri.Len() > 0 then
        m.details.translation = [m.poster.translation[0] + m.poster.width + 15, m.poster.translation[1]]
        AlignTimeGrid()
    else
        m.details.translation = m.poster.translation
    end if
end sub

sub AlignTimeGrid()
    if not m.timeGridWasMoved
        posterHeight = m.poster.maxHeight
        posterBottomY = m.poster.boundingRect().y + posterHeight

        ' calculate timeBarHeight because translation of TimeGrid component
        ' somehow is not calculated from the top of TimeBar
        timeBarHeight = m.view.timeBarHeight
        if timeBarHeight = 0 then timeBarHeight = 50

        timeGridY = posterBottomY + timeBarHeight + m.detailsTimeGridSpacing
        m.view.translation = [m.view.translation[0], timeGridY]

        m.timeGridWasMoved = true
    end if
end sub

function OnPosterShapeChange() as Object
    m.poster.shape = m.top.posterShape
    if m.top.content <> invalid then
        ChannelProgramFocused(m.view.channelFocused, m.view.programFocused)
    end if
end function

Sub onTimeGridViewContentChange()
    ShowSpinner(m.view.content = invalid OR m.view.content.GetChildCount() = 0)

    ' This logic will reset focus to current time or to
    ' first valid item if there are no content for current time
    if m._isContentFocusResetDone = true then return

    content = m.view.content
    if content = invalid then return

    channel = content.getChild(0)
    if channel = invalid OR channel.getChildCount() = 0 then return

    isNowProgramAvailable = false
    currentTime = m.view.leftEdgeTargetTime
    for each program in channel.GetChildren(-1, 0)
        if program.PlayStart <= currentTime AND program.PlayStart + program.PlayDuration >= currentTime then
            isNowProgramAvailable = true
            exit for
        end if
    end for

    if not isNowProgramAvailable then
        ' focus to begin on content
        m.view.jumpToProgram = 0
        m.view.leftEdgeTargetTime = channel.GetChild(0).PlayStart
    end if

    m._isContentFocusResetDone = true
End Sub

Function AlignTimeToHours(timestamp as Integer) as Integer
    return timestamp - timestamp MOD 3600
End Function
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

sub SGDEX_UpdateViewUI()
    buttonBar = m.top.getScene().buttonBar
    isButtonBarVisible = buttonBar.visible
    descriptionLabelWidth = 666

    if buttonBar <> invalid and m.details <> invalid
        if buttonBar.alignment = "left"
            offset = GetButtonBarWidth()
            if isButtonBarVisible
                ' Resize description if layout shifted
                if descriptionLabelWidth/2 >= offset - GetViewXPadding()
                    descriptionLabelWidth -= (offset - GetViewXPadding())
                else
                    descriptionLabelWidth = descriptionLabelWidth - m.details.boundingRect()["x"] - GetViewXPadding()
                end if
            end if
        end if
        m.details.maxWidth = descriptionLabelWidth
    end if
end sub