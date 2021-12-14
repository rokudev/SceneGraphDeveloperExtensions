' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub Show(args as Object)
    CreateButtonBar()
    m.grid = CreateObject("roSGNode", "GridView")

    ' setup UI of view
    m.grid.SetFields({
        style: "zoom"
        posterShape: "16x9"
    })
    ' This is root content that describes how to populate rest of rows
    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
        HandlerConfigGrid: {
            name: "CHRoot"
        },
        isContentLoaded: false
    })
    m.grid.ObserveField("rowItemSelected", "OnGridItemSelected")
    m.grid.content = content

    if IsDeepLinking(args)
        ' observe content change to be able to handle launch time deep linking, if any
        m.grid.content.ObserveFieldScoped("isContentLoaded", "OnContentLoaded")
        m.args = args
    end if

    m.top.ComponentController.CallFunc("show", {
        view: m.grid
    })

    m.top.signalBeacon("AppLaunchComplete")
end sub

sub Input(args as object)
    ' handle roInput event deep linking
    if IsDeepLinking(args)
        PerformDeeplinking(args)
    end if
end sub

sub OnGridItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.GetData()
    row = grid.content.GetChild(selectedIndex[0])
    detailsView = ShowDetailsView(row, selectedIndex[1])
end sub

sub OnContentLoaded(event as object)
    if event.GetData() = True
        ' content has been loaded, process launch time deep linking
        if IsDeepLinking(m.args) ' if there are non-empty contentId and mediaType
            PerformDeeplinking(m.args)
        end if
        ' clear previously cached arguments
        m.args = invalid

        m.grid.content.UnobserveFieldScoped("isContentLoaded")
    end if
end sub

sub CreateButtonBar()
    buttonBarContent = CreateObject("roSGNode", "ContentNode")
    buttonBarContent.Update({
        HandlerConfigButtonBar: {
            name: "CHButtonBar"
        }
    }, true)

    ' Set CustomButtonBar object to the m.top.buttonBar interface
    m.top.buttonBar = CreateObject("roSGNode", "CustomButtonBar")
    m.top.buttonBar.content = buttonBarContent
    m.top.buttonBar.visible = true
    m.top.buttonBar.overlay = true
    m.top.buttonBar.alignment = "left"

    m.top.buttonBar.ObserveFieldScoped("itemSelected", "OnButtonBarItemSelected")
end sub

sub OnButtonBarItemSelected(event as Object)
    buttonBar = event.GetRoSGNode()
    content = buttonBar.content
    itemNodeSelected = content.GetChild(event.GetData())

    ' Create and setup a dialog
    dialog = CreateObject("roSGNode", "Dialog")
    m.top.GetScene().dialog = dialog
    dialog.title = tr(itemNodeSelected.title)
    dialog.message = tr("Lorem Ipsum is simply dummy text of the printing and typesetting industry.")
    dialog.buttons = [tr("Ok")]
    dialog.optionsDialog = true
    dialog.ObserveField("buttonSelected", "CloseContentNotFoundDialog")
end sub