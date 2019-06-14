' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.labelsLayout = m.top.findNode("labelsLayout")
    m.labelsBackground = m.top.findNode("labelsBackground")
    m.line1 = m.top.findNode("line1")
    m.line2 = m.top.findNode("line2")
    
    m.poster = m.top.findNode("poster")
    m.durationBar = m.top.findNode("durationBar")
    m.durationBar.height = 6
end sub 

sub onContentSet()
    content = m.top.itemContent
    if content <> invalid
        m.poster.uri = content.hdPosterUrl
        ' contentSetLine is field to check if text is set to label
        setLabelDataOrHide(m.line1, content.shortDescriptionLine1)
        setLabelDataOrHide(m.line2, content.shortDescriptionLine2)
        setDurationBarData(content.length, content.bookmarkposition, content.hideItemDurationBar <> true)
        updateLabelsLayout()
    end if
end sub

sub onWidthChange()
    m.durationBar.width = m.top.width
    m.poster.width      = m.top.width
    m.poster.loadWidth  = m.top.width
    updateLabelsLayout()
end sub

sub onHeightChange()
    m.poster.height = m.top.height
    m.poster.loadHeight  = m.top.height
    m.durationBar.translation = [0,m.top.height - m.durationBar.height]
    updateLabelsLayout()
end sub

sub updateLabelsLayout()
    width = m.top.width
    height = m.top.height
    if width > 0 and height > 0
        ' set theme parametres
        parent = Utils_getParentbyIndex(3, m.top)
        if parent <> invalid
            if parent.itemTextColorLine1 <> invalid
                m.line1.color = parent.itemTextColorLine1
            end if
            if parent.itemTextColorLine2 <> invalid
                m.line2.color = parent.itemTextColorLine2
            end if

            itemTextBgColor = parent.itemTextBackgroundColor
            if itemTextBgColor <> invalid and itemTextBgColor <> "" ' when itemTextBackgroundColor field is set
                if m.line1.visible Or m.line2.visible ' show background if there is text for atleast one label
                    m.labelsBackground.color = parent.itemTextBackgroundColor
                    m.labelsBackground.opacity = 1
                end if
            end if
        end if

        padding = 5
        if height > 200 then padding = 10   
        setLabelStyle(m.line1, width, height, padding)
        setLabelStyle(m.line2, width, height, padding)

        ' set rectangle background width and height
        heightLayout = m.labelsLayout.boundingRect().height
        m.labelsBackground.width = width + 1 ' background should fill whole item width
        m.labelsBackground.height = heightLayout + 2 * padding

        ' translate layouts to the bottom of item
        m.labelsBackground.translation = [0, height - m.labelsBackground.height]
        if m.line1.visible and not m.line2.visible ' to centralize text on labelsLayout
            m.labelsLayout.translation = [padding, height - padding + m.labelsLayout.itemSpacings[0]]
        else
            m.labelsLayout.translation = [padding, height - padding]
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

sub setDurationBarData(length as Integer,BookmarkPosition as Integer, showDurationBar as Boolean)
    if showDurationBar and length > 0 and BookmarkPosition > 0 and bookmarkPosition < length
        m.durationBar.length            = length
        m.durationBar.BookmarkPosition  = BookmarkPosition
        m.durationBar.visible           = true
        m.durationBar.scale             = [1,1]
    else
        m.durationBar.visible = false
        m.durationBar.scale = [0,0]
    end if
end sub
