function ShowCustomView(hdPosterUrl)
    m.CustomScreen = CreateObject("roSGNode", "custom")
    m.CustomScreen.picPath = hdPosterUrl
    m.top.ComponentController.CallFunc("show", {
        screen: m.CustomScreen
    })
end function
