function IsDeepLinking(args as Object)
    ' check if deep linking args is valid
    return args.mediaType <> invalid and args.mediaType <> "" and args.contentId <> invalid and args.contentId <> "" 
end function

sub PerformDeeplinking(args as Object)
    mediaType = args.mediaType
    contentId = args.contentId
    ' check if mediaType is right
    if mediaType = "episode"
        currentView = m.top.ComponentController.currentView
        if currentView.Subtype() = "MediaView" and currentView.currentItem.id = contentId
            ' if currentView is MediaView and current playing item id equal to contentId, then do nothing
            print "Content is already playing"
        else if currentView.Subtype() = "DetailsView" and currentView.currentItem.id = contentId
            ' if if currentView is DetailsView and current playing item id equal to contentId, then play it
            OpenVideoView(currentView.content, currentView.itemFocused)
        else
            ' show media view with item id equal to contentId
            CloseAllAppViewsButHome()
            ImitateMediaViewOpening(contentId)
        end if
    else
        ShowContentNotFoundDialog()
    end if
end sub

sub CloseAllAppViewsButHome()
    ' close all views except home view
    while m.top.ComponentController.ViewManager.ViewCount > 1
        currentView = m.top.ComponentController.currentView
        currentView.close = true
    end while
end sub

sub ImitateMediaViewOpening(contentId as String)
    homeGrid = m.grid
    if homeGrid <> invalid and homeGrid.content <> invalid
        gridContent = homeGrid.content
        gridContentLen = gridContent.GetChildCount()
        
        ' search row and column index of the element with item id equal to contentId
        for gridIndex = 0 To gridContentLen - 1:
            rowContent = gridContent.GetChild(gridIndex)
            rowContentLen = rowContent.GetChildCount()

            for rowIndex = 0 To rowContentLen - 1:
                itemContent = rowContent.GetChild(rowIndex)
                if itemContent.id = contentId
                    ' if item id equal to contentId, then imitate opening of the video view
                    CloseContentNotFoundDialog()
                    homeGrid.jumpToRowItem = [gridIndex, rowIndex]
                    row = homeGrid.content.GetChild(gridIndex)
                    ShowDetailsView(row, rowIndex)
                    OpenVideoView(row, rowIndex)
                    return
                end if
            end for
        end for
    end if

    ShowContentNotFoundDialog()
end sub

sub ShowContentNotFoundDialog()
    ' check if dialog exists. If no then create a new one
    if m.top.GetScene().dialog = invalid
        dialog = CreateObject("roSGNode", "Dialog")
        m.top.GetScene().dialog = dialog
    else
        dialog = m.top.GetScene().dialog
    end if
    ' set dialog fields to needed
    dialog.title = tr("Error")
    dialog.message = tr("Content not found")
    dialog.buttons = [tr("Ok")]
    dialog.optionsDialog = true
    dialog.ObserveField("buttonSelected", "CloseContentNotFoundDialog")
end sub

sub CloseContentNotFoundDialog()
    if m.top.GetScene().dialog <> invalid
        ' if dialog exists, then close it
        m.top.GetScene().dialog.close = true
    end if
end sub
