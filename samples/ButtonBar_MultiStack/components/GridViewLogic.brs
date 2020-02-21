' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

function ShowGridView(view as Object)
    view.ObserveField("rowItemSelected", "OnRowItemSelected")

    m.top.componentController.CallFunc("show", { view: view })
end function

sub OnRowItemSelected(event as Object)
    ' retrieve content for a video from a grid item
    grid = event.GetRoSGNode()
    itemSelected = event.GetData()
    rowContent = grid.content.GetChild(itemSelected[0])
    itemContent = rowContent.GetChild(itemSelected[1])

    OpenVideoPlayerItem(itemContent)
end sub