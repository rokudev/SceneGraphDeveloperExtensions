sub GetContent()
    childrenArray = []
    for index = 1 to 4
        SlideItem = CreateObject("roSGNode", "ContentNode")
        SlideItem.Update({
            title: "Item " + index.toStr()
            description: "This is description for Item " + index.toStr()
            HandlerConfigDetails: {
                name: "CHSlideItem"
                fields:{
                    slideIndex: index
                }
            }
        },true)
        childrenArray.Push(SlideItem)
    end for
    m.top.content.AppendChildren(childrenArray)
end sub
