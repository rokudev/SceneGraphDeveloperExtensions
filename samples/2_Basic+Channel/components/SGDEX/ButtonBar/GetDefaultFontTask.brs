' Copyright (c) 2019 Roku, Inc. All rights reserved.

sub init()
    m.top.functionName = "getFont"
end sub

sub getFont()
    reg = CreateObject("roFontRegistry")
    if reg <> invalid
        font = reg.GetDefaultFont(31, false, false)
        m.top.oneCharWidth = font.GetOneLineWidth("a", 300)
    end if
end sub