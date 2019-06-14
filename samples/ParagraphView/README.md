# ParagraphView

This sample demonstrates using the SGDEX ParagraphView.

## Initializing the ParagraphView

To create and set up the ParagraphView we should do the following steps:

* Create the ParagraphView object and set some of its fields. We save the reference to the view in m.paragraphView so we can access it in the scene scope.

```
m.paragraphView = CreateObject("roSGNode", "ParagraphView")
```

* There are two ways to set content to the screen. 
The first way is to create a content node for our view and then we can simply set content with appropriate children like in the example below. To set the text to display we should define text field of created node. The default type of created node is "paragraph", but we can define which type of paragraph we want to create by adding and setting the paragraphType field to our node. There are four possible types: 
    - paragraph
    - header
    - linkingCode
    - image

```
content = CreateObject("roSGNode", "ContentNode")

header = content.CreateChild("ContentNode")
header.paragraph = "Paragraph Text"
header.AddField("paragraphType", "string", true)
header.paragraphType = "paragraph"

m.paragraphView.content = content
```

* In a second way we also have to create a content node for our view, but then we add to our node HandlerConfigParagraph, which specifies the content handler for this view. it is explained how to properly load content in ContentHandler in the chapter "Organizing content in ContentHandler". 

```
content = CreateObject("roSGNode", "ContentNode")

content.AddFields({
    HandlerConfigParagraph: {
        name: "CHRoot"
    }
})

m.paragraphView.content = content
```

* Set theme attributes to adjust ParagraphView appearance.

```
m.paragraphView.theme = {
    textColor: "0x22FF22" ' sets text color to all labels
    paragraphColor: "0xFF22FF" ' specifies the color of text with type paragraph
    headerColor: "0x22FFFF" ' specifies the color of text with type header
    linkingCodeColor: "0xFFFF22" ' specifies the color of text with type linkingCode
    buttonsFocusedColor: "0x000000" ' sets the color of focused buttons
}
```

Except theme attribute listed above, ParagraphView also supports a few other attributes such as: 
    buttonsUnFocusedColor - set the color of unfocused buttons
    buttonsFocusRingColor - set the color of button focused ring
    

* Add buttons to the view and observe buttonSelected interface. Buttons interface is the content node, which should contain children with id and title that will be shown on view. Example of creating a button on ParagraphView:

```
m.paragraphView.buttons = GetButtons() ' in function, which set up our ParagraphView

function GetButtons() as Object
    buttons = CreateObject("roSGNode", "ContentNode")
    btn1 = buttons.CreateChild("ContentNode")
    btn1.title = "Reload linking code"
    btn1.id = "codeButton"
    return buttons
end function
```

* Finally, add view to screen stack by calling show function.

```
m.top.ComponentController.CallFunc("show", {
    view: paragraphView
})
```

## Organizing content in ContentHandler

* For convenience, we created a separate file with functions, which create paragraphs for view, called ParagraphHelper.brs. By the way, it's correct and possible to define these functions in our content handler.

* To add paragraphs to view, we should create a content node and append as a child to paragraphView content. As mentioned above, we can define which type of paragraph we want to create by adding and setting the paragraphType field to our node.

Example of creating a header in ParagraphHelper.brs, where m.paragraphView.content passed as a content parameter:

```
function CreateHeader(content as Object, text as String) as Object
    header = content.CreateChild("ContentNode")
    header.text = text
    header.AddField("paragraphType", "string", true)
    header.paragraphType = "header"

    return header
end function
```

## Reload linking code
* To perform reload linking code on screen by button press, firstly, we should observe buttonSelected field:

```
m.paragraphView.ObserveField("buttonSelected", "OnButtonSelected")
```

* After that, we implement callback function, which handles button press events. In this function, we implement the logic for updating linking code. It's possible to change the linking code by the two ways. First is to reload ContentHandler, which is responsible for updating linking code, and second is to change it directly. There are a few main steps to update linkingCode without ContentHandler:
    - Find linkingCode node among children of paragraphView content
    - Create a copy of paragraphView content and update linking code in it
    - Reset paragraphView content with updated node to change the code on the screen

```
sub OnButtonSelected(event as Object)
    ?"OnButtonSelected"
    buttonIndex = event.GetData()
    button = m.paragraphView.buttons.GetChild(buttonIndex)
    if button.id = "codeButton"
        ' You can reset content with config to trigger 
        ' content handler for fetching new linking code
        ' the entire screen will be reloaded in such case
        ' content = CreateObject("roSGNode", "ContentNode")
        ' content.AddFields({
        '     HandlerConfigParagraph: {
        '         name: "CHRoot"
        '     }
        ' })
        ' m.paragraphView.content = content
        ' Or you can fetch new linking code by your own 
        ' and just set it to the appropriate content node
        code = (1000 + Rnd(8999)).ToStr()
        content = m.paragraphView.content.Clone(true)
        linkingCodeIndex = content.GetChildCount() - 1 ' linking code is the last child in our sample
        content.GetChild(linkingCodeIndex).text = code
        m.paragraphView.content = content
    end if
end sub
```

###### Copyright (c) 2019 Roku, Inc. All rights reserved.
