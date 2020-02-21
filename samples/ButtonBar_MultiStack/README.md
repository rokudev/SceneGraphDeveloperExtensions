# SGDEX ButtonBar and MultiStack

## Definition

This sample demonstrates using SGDEX features: ButtonBar and MultiStack.
ButtonBar is the global UI component, which allows easily represent a group of buttons. All buttons can be customized and actions can be added to them.
MultiStack is the name for the concept that provide multiple stack support. Combining the MultiStack with the ButtonBar give developers opportunity to easily manage switching stacks and views through the buttons.

### Initializing the ButtonBar

* To set up the Buttonbar we should do the following steps:

ButtonBar is created in the scene and we can reach it like this:
```
m.top.buttonBar ' where m.top is the MainScene
```

ButtonBar can also be reached from the retrieved scene:
```
m.top.GetScene().buttonBar
```

* There are two ways to set up content to the screen.
The first way is to create a content node and set it directly to the ButtonBar as a child like in the example below. To set the text to the button use the title field of a content node.

```
content = CreateObject("roSGNode", "ContentNode")
content.Update({
   children: [{
      title: "Movie"           
   }]
})
m.top.buttonBar.content = content
```

* In the second way we also have to create a content node, but then we add to our node HandlerConfigButtonBar, which specifies the content handler for the ButtonBar.

```
buttonsContent = CreateObject("roSGNode", "ContentNode")
buttonsContent.AddFields({
    HandlerConfigButtonBar: {
        name: "ButtonBarHandler"
    }
})
m.top.buttonBar.content = buttonsContent
```

* Set theme attributes to adjust ButtonBar appearance.
```
m.top.theme = {
    buttonBar: {
        backgroundColor: "0x000080" ' set the color of component background
        buttonColor: "0xff0000" ' controls the color of button backgrounds
        footprintButtonColor: "0xff000073" ' controls the color of the footprint button's background
    }
}
```

Also there is another way to set up theme to buttonBar:
```
m.top.buttonBar.theme = {
    backgroundColor: "0x000080"
    buttonColor: "0xff0000"
    footprintButtonColor: "0xff000073"
}
```

Except theme attributes listed above, ButtonBar also supports a few other attributes such as:
```
buttonTextColor - controls the color of button text
focusedButtonColor - controls the color of the focused button's background
focusedButtonTextColor - controls the color of the focused button's text
footprintButtonTextColor - controls the color of the footprint button's text
hintTextColor - controls the color of text shown on auto-hide mode
hintArrowColor - controls the color of arrow shown on auto-hide mode
```

### MultiStack usage

* Adding new stacks to the ComponentController.
There is one "default" stack and we can add a new one like this:
```
m.top.componentController.addStack = "stack_1"
}
```
Adding new stacks does not select them automatically.

* To select another stack use the name of existing one. Whenever we select stack, showing the new view will be applied just to the selected one.
```
m.top.componentController.selectStack = "default"
}
```

* We can also retrieve activeStack name by calling a ComponentController field with the same name (i.e. activeStack). And those are all actions we use to manipulate with MultiStack in our sample.

* It is also important to keep in mind that each new stack is completely new screen, therefore changes to ComponentController fields (such as allowCloseChannelOnLastView and allowCloseLastViewOnBack) are applied just to active stack.

* In addition, ComponentController provides the way to remove the stack using its name:
```
m.top.componentController.removeStack = "stack_1"
}
```

###### Copyright (c) 2020 Roku, Inc. All rights reserved.
