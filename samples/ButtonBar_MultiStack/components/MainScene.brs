' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub Show(args as Object)
    ' despite this sample use content handler to populate ButtonBar
    ' it also possible to populate it directly
    buttonsContent = CreateObject("roSGNode", "ContentNode")
    buttonsContent.AddFields({
        HandlerConfigButtonBar: {
            name: "ButtonBarHandler"
        }
    })
    m.top.buttonBar.content = buttonsContent

    m.top.buttonBar.visible = true
    ' as long as this sample use selection UX it is better to set a
    ' selection style for footprint representation
    m.top.buttonBar.footprintStyle = "selection"
    m.top.buttonBar.ObserveField("itemSelected", "OnButtonBarItemSelected")

    m.top.theme = {
        global: {
            backgroundColor: "0x202020ff"
            overhangBackgroundColor: "0x000000ff"
        }
        buttonBar: {
            backgroundColor: "0x8806ceff"
            buttonColor: "0x202020ff"
            focusedButtonTextColor: "0x000000ff"
            footprintButtonColor: "0x000000ff"
            footprintButtonTextColor: "0xffffffff"
            textColor: "0x8806ceff"
        }
    }

    ' Add more stacks for each button
    m.top.componentController.addStack = "stack_1"
    m.top.componentController.addStack = "stack_2"
    m.top.componentController.selectStack = "default"   ' default stack is created automatically

    ' Show first screen
    gridConfig = GetButtonBarScreensConfig()["movies"]
    ShowNewScreenFromConfig(gridConfig)

    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if

    m.top.signalBeacon("AppLaunchComplete")
end sub

sub Input(args as object)
    ' handle roInput event deep linking
    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if
end sub

sub OnButtonBarItemSelected(event as Object)
    itemSelected = event.GetData()
    RetrieveScreenFromItem(itemSelected)
end sub

sub RetrieveScreenFromItem(item as Object)
    button = m.top.buttonBar.content.GetChild(item)
    screenConfig = GetButtonBarScreensConfig()[button.id]
    activeStack = m.top.componentController.activeStack
    activeView = m.top.componentController.currentView

    if screenConfig.stackName = activeStack
        ' user selected the active stack, thus move focus back on view
        ' to prevent view reloading
        if activeView <> invalid then activeView.SetFocus(true)
    else
        ' Select certain stack
        m.top.componentController.selectStack = screenConfig.stackName

        if m.top.ComponentController.currentView = invalid ' this stack hasn't been used yet
            ShowNewScreenFromConfig(screenConfig)
        else
            ' view has been already shown, therefore just move focus on it
            currentView = m.top.componentController.currentView
            if currentView <> invalid then currentView.SetFocus(true)
        end if
    end if
end sub

' Set up and show a new view
sub ShowNewScreenFromConfig(config as Object)
    newScreen = CreateObject("roSGNode", config.screenName)
    content = CreateObject("roSGNode", "ContentNode")

    content.AddFields(config.handlerConfig)
    if config.fieldsToSet <> invalid
        newScreen.SetFields(config.fieldsToSet)
    end if
    newScreen.content = content

    if config.screenName = "SearchView"
        ShowSearchView(newScreen)
    else if config.screenName = "GridView"
        ShowGridView(newScreen)
    end if
end sub

' Retrieve config for corresponding stack and view using button ID
function GetButtonBarScreensConfig() as Object
    config = {
        movies: {
            stackName: "default"
            screenName: "GridView"
            handlerConfig: {
                HandlerConfigGrid: {
                    name: "GridHandler"
                    fields: {
                        contentType: "movies"
                    }
                }
            }
        }
        series: {
            stackName: "stack_1"
            screenName: "GridView"
            handlerConfig: {
                HandlerConfigGrid: {
                    name: "GridHandler"
                    fields: {
                        contentType: "series"
                    }
                }
            }
        }
        search: {
            stackName: "stack_2"
            screenName: "SearchView"
        }
    }
    return config
end function
