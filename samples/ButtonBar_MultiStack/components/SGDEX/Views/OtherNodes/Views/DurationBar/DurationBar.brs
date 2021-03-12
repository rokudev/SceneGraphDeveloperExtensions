' Copyright (c) 2018 Roku, Inc. All rights reserved.
sub OnHeightChanged()
    m.top.FindNode("progress").height = m.top.height
    m.top.FindNode("background").height = m.top.height
end sub

'update progress on duration bar
Sub UpdateBookmark()
    progressRec = m.top.FindNode("progress")
    background = m.top.FindNode("background")
    if m.top.length > 0 AND m.top.length > m.top.BookmarkPosition
        progress = Int(m.top.BookmarkPosition / m.top.length * 100)
        if progress > 100
            progress = 100
        else if progress < 0
            progress = 0
        end if           
        progressRec.width = Int(progress * background.width / 100)
    else
        progressRec.width = 0
    end if
end Sub
