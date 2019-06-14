' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

function ShowEpisodePickerView(seasonContent as Object) as Object
    episodePicker = CreateObject("roSGNode", "CategoryListView")
    episodePicker.posterShape = "16x9"
    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
        HandlerConfigCategoryList: {
            name: "SeasonsHandler"
            seasons: seasonContent
        }
    })
    episodePicker.content = content
    episodePicker.ObserveField("selectedItem", "OnEpisodeSelected")
    'this will trigger job to show this View
    m.top.ComponentController.CallFunc("show", {
        view: episodePicker
    })
    return episodePicker
end function

sub OnEpisodeSelected(event as Object)
    'show details view with selected episode content
    categoryList = event.GetRoSGNode()
    itemSelected = event.GetData()
    category = categoryList.content.GetChild(itemSelected[0])
    ShowDetailsView(category.GetChild(itemSelected[1]), 0, false)
end sub
