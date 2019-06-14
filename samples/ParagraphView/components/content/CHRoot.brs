' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

' function: GetContent()
' @Description: create and append paragraphs to paragraphView
sub GetContent()
    Sleep(2000) ' to emulate API call
    CreateHeader(m.top.content, "Header Text")
    CreateParagraph(m.top.content, "Paragraph text 1 - Text in the paragraph screen is justified to the left edge")
    CreateParagraph(m.top.content, "Paragraph text 2 - Multiple paragraphs may be added to the screen by simply adding new child to the content node")
    CreateParagraph(m.top.content, "Paragraph text 3 - Linking code is aligned to center horizontally")
    
    code = (1000 + Rnd(8999)).ToStr() ' create random 4-digit number for linking code
    CreateLinkingCode(m.top.content, code)
end sub
