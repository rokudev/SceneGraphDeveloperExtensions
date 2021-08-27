' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub onContentSet()
    content = m.top.itemContent
    if content <> invalid
        m.top.findNode("poster").uri = content.hdPosterUrl
        line1 = m.top.findNode("line1")
        line2 = m.top.findNode("line2")
        ' contentSetLine is field to check if text is set to label
        setLabelDataOrHide(line1, content.shortDescriptionLine1)
        setLabelDataOrHide(line2, content.shortDescriptionLine2)
        setDurationBarData(content)
        updateLabelsLayout()
    end if
end sub

sub onWidthChange()
    m.top.FindNode("durationBar").width = m.top.width
    m.top.FindNode("poster").width      = m.top.width
    m.top.FindNode("poster").loadWidth  = m.top.width
    m.top.FindNode("posterRect").width = m.top.width
    updateLabelsLayout()
end sub

sub onHeightChange()
    m.top.FindNode("poster").height = m.top.height
    m.top.FindNode("poster").loadHeight  = m.top.height
    m.top.FindNode("posterRect").height = m.top.height
    durationBar = m.top.FindNode("durationBar")
    durationBar.translation = [0,m.top.height - durationBar.height]
    updateLabelsLayout()
end sub


sub updateLabelsLayout()
    width = m.top.width
    height = m.top.height
    if width > 0 and height > 0
        line1 = m.top.findNode("line1")
        line2 = m.top.findNode("line2")
        posterRect = m.top.FindNode("posterRect")
        labelsBackground = m.top.findNode("labelsBackground")
        labelsLayout = m.top.findNode("labelsLayout")

        ' set theme parametres
        parent = Utils_getParentbyIndex(3, m.top)
        if parent <> invalid
            if parent.itemTextColorLine1 <> invalid
                line1.color = parent.itemTextColorLine1
            end if
            if parent.itemTextColorLine2 <> invalid
                line2.color = parent.itemTextColorLine2
            end if
            if parent.itemBackgroundColor <> invalid and parent.itemBackgroundColor <> ""
                posterRect.color = parent.itemBackgroundColor
            end if
            if parent.shortDescriptionLine1Align <> invalid and parent.shortDescriptionLine1Align <> ""
                line1.horizAlign = parent.shortDescriptionLine1Align
            end if
            if parent.shortDescriptionLine2Align <> invalid and parent.shortDescriptionLine2Align <> ""
                line2.horizAlign = parent.shortDescriptionLine2Align
            end if

            itemTextBgColor = parent.itemTextBackgroundColor
            if itemTextBgColor <> invalid and itemTextBgColor <> "" ' when itemTextBackgroundColor field is set
                if line1.visible Or line2.visible ' show background if there is text for atleast one label
                    labelsBackground.color = parent.itemTextBackgroundColor
                    labelsBackground.opacity = 1
                end if
            end if
        end if

        padding = 5
        if height > 200 then padding = 10   
        setLabelStyle(line1, width, height, padding)
        setLabelStyle(line2, width, height, padding)

        ' set rectangle background width and height
        heightLayout = labelsLayout.boundingRect().height
        labelsBackground.width = width + 1 ' background should fill whole item width
        labelsBackground.height = heightLayout + 2 * padding

        ' translate layouts to the bottom of item
        labelsBackground.translation = [0, height - labelsBackground.height]
        if line1.visible and not line2.visible ' to centralize text on labelsLayout
            labelsLayout.translation = [padding, height - padding + labelsLayout.itemSpacings[0]]
        else
            labelsLayout.translation = [padding, height - padding]
        end if
    end if
end sub

sub setLabelStyle(label as Object, width as Integer, height as Integer, padding as Integer)
    if height > 0 and width > 0
        font = "font:MediumSystemFont"
        if height > 220 ' big size
            font = "font:LargeSystemFont"
        end if
        label.width = width - padding * 2
        label.font  = font
    end if
end sub

sub setLabelDataOrHide(label as Object, text as String)
    if text.trim().len() > 0
        label.text = text
        label.visible = true
        label.scale = [1,1]
    else
        label.text = ""
        label.visible = false
        label.scale = [0,0]
    end if
end sub

sub setDurationBarData(content as Object)
    length = content.length
    
    ' Try to get bookmark from playStart first, then fallback to bookmarkPosition
    ' and use shallow copy of the content node fields to avoid either of values
    ' to be auto-filled by RSG
    cf = content.GetFields()
    bookmarkPosition = cf.playStart
    if bookmarkPosition = invalid or bookmarkPosition = 0
        bookmarkPosition = cf.bookmarkPosition
        if bookmarkPosition = invalid
            bookmarkPosition = 0
        end if
    end if
    
    showDurationBar = content.hideItemDurationBar <> true
    durationBar = m.top.FindNode("durationBar")
    if showDurationBar and length > 0 and BookmarkPosition > 0 and bookmarkPosition < length
        durationBar.length            = length
        durationBar.BookmarkPosition  = BookmarkPosition
        durationBar.visible           = true
        durationBar.scale             = [1,1]
    else
        durationBar.visible = false
        durationBar.scale = [0,0]
    end if
end sub
