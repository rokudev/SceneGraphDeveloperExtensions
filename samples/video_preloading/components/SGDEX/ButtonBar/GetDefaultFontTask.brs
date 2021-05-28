' Copyright (c) 2021 Roku, Inc. All rights reserved.

sub init()
    m.top.functionName = "getFont"
end sub

sub getFont()
    reg = CreateObject("roFontRegistry")
    if reg <> invalid
        font = reg.GetDefaultFont(31, false, false)
        if font <> invalid
            m.top.oneCharWidth = font.GetOneLineWidth("a", 300)
        else
            ' a workaround for the case when default font instance is invalid
            m.top.oneCharWidth = 18
        end if
    end if
end sub
