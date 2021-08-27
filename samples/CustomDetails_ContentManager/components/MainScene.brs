
sub Show(args as Object)
    ShowSlideView()
end sub

function ShowSlideView()
    ' Create a CustomSlide object
    slide = CreateObject("roSGNode", "CustomSlide")
    slideContent = CreateObject("roSGNode", "ContentNode")
    slideContent.Update({
        HandlerConfigDetails: {
            name: "CHSlide"
        }
    }, true)

    ' Setup content and index to play
    slide.content = slideContent
    slide.control = "play"

    ' Push the CustomSlide object to the stack to show it on the screen
    m.top.ComponentController.CallFunc("show", {
        view: slide
    })
    return slide
end function