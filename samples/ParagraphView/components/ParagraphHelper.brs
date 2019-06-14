' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

' function: CreateHeader()
' @Description: create header and append it to content node as child
' @Return as Object: header node
function CreateHeader(content as Object, text as String) as Object
    header = content.CreateChild("ContentNode")
    header.text = text
    header.AddField("paragraphType", "string", true)
    header.paragraphType = "header"

    return header
end function

' function: CreateParagraph()
' @Description: create paragraph and append it to content node as child
' @Return as Object: paragraph node
function CreateParagraph(content as Object, text as String) as Object
    paragraph = content.CreateChild("ContentNode")
    paragraph.text = text
    paragraph.AddField("paragraphType", "string", true)
    paragraph.paragraphType = "paragraph"
    
    return paragraph
end function

' function: CreateLinkingCode()
' @Description: create linking code and append it to content node as child
' @Return as Object: linking code node
function CreateLinkingCode(content as Object, text as String) as Object
    code = content.CreateChild("ContentNode")
    code.text = text
    code.AddField("paragraphType", "string", true)
    code.paragraphType = "linkingCode"

    return code
end function
