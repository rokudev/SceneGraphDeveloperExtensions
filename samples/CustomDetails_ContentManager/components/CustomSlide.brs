sub Init()
    ' Cache custom UI bits to m for convenience
    m.mainImagePosition = m.top.findNode("mainImagePosition")
    m.controlLabel = m.top.findNode("controlLabel")
    m.slideTimer = m.top.findNode("slideTimer")
    m.spinner = m.top.findNode("customSpinner")
    m.mainImage = m.top.findNode("mainImage")
    m.title = m.top.findNode("title")
    m.description = m.top.findNode("description")

    m.mainImage.ObserveFieldScoped("loadStatus", "OnImageLoadStatusChanged")

    m.controlLabel.visible = false

    ' Configure slideshow timer for playback mode(default duration is 1s)
    m.slideTimerSecondsPassed = 0
    m.slideTimer.ObserveFieldScoped("fire", "OnSlideTimerFireChanged")

    ' Set callback for m.top fields
    m.top.ObserveField("currentItem", "OnCurrentItemChanged")
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")
end sub

 ' Callback function for handling item focused change to update a displayed content
sub OnItemFocusedChanged()
    ShowBusySpinner(true)
    currentItem = m.top.content.GetChild(m.top.itemFocused)
    if currentItem <> invalid
        SetContent(currentItem)
    end if
end sub

 ' Callback function for handling current item change to update a displayed content
sub OnCurrentItemChanged(event as Object)
    currentItem = event.getData()
    SetContent(currentItem)
end sub

' Helper function to set up content to display
sub SetContent(content as Object)
    if content <> invalid
        m.title.text = content.title
        m.description.text = content.description
        m.mainImage.uri = content.hdPosterUrl
    end if
end sub

' Callback function to handle a load status of poster to run a timer if needed or go to the next item
sub OnImageLoadStatusChanged(event as Object)
    status = event.GetData()
    poster = event.GetRoSGNode()
    if status = "ready"
        ShowBusySpinner(false)
        ' Start timer if the image load successful
        m.slideTimerSecondsPassed = 0
        if m.top.control = "play"
            m.slideTimer.control = "start"
        end if
    else if status = "failed" and poster.uri <> ""
        ' Go to next item in case if the image load failed
        SetNewIndex()
    end if
end sub

' Callback function to handle a timer change to start next item if needed
sub OnSlideTimerFireChanged(event as Object)
    m.slideTimerSecondsPassed++
    m.controlLabel.visible = false
    if m.slideTimerSecondsPassed >= m.top.slideDuration
        SetNewIndex()
    end if
end sub

' Overridden OnKeyEvent() function to handle a key pressing
function OnKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    steps = {
        "right": + 1
        "left": - 1
    }

    if press
        if steps[key] <> invalid
            ' Go to next or previous item
            SetNewIndex(steps[key])
            handled = true
        else if key = "play"
            ' Start or stop the timer
            if m.top.control = "pause"
                m.slideTimer.control = "start"
                m.top.control = "play"
            else if m.top.control = "play"
                m.slideTimer.control = "stop"
                m.top.control = "pause"
            end if
            
            ' Update a label on the screen to display a control status
            m.controlLabel.text = m.top.control
            m.controlLabel.visible = true
            handled = true
        end if
    end if

    return handled
end function

' Helper function to set up next item and update a timer
sub SetNewIndex(steps = +1 as Integer)
    newIndex = GetNextItemIndex(m.top.itemFocused, m.top.content.GetChildcount() - 1, steps)
    if m.top.itemFocused <> newIndex then
        m.slideTimerSecondsPassed = 0
        m.slideTimer.control = "stop"
        m.top.itemFocused = newIndex
    end if
end sub

' Helper function to process the next item to display
function GetNextItemIndex(currentIndex as Integer, maxIndex as Integer, _step as Integer, allowCarousel = true as Boolean, minIndex = 0 as Integer) as Integer
    result = currentIndex + _step

    if result > maxIndex then
        if allowCarousel then
            result = minIndex
        else
            result = maxIndex
        end if
    else if result < minIndex then
        if allowCarousel then
            result = maxIndex
        else
            result = minIndex
        end if
    end if

    return result
end function

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


