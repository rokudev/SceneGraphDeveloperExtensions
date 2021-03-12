' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

sub GetContent()
    rootChildren = []

    rowTitles = [
        {
            "title": "Video"
        },
        {
            "title": "Audio"
        },
        {
            "title": "Thumbnails"
        },
        {
            "title": "Health"
        },
        {
            "title": "Picture"
        },
        {
            "title": "Background"
        },
        {
            "title": "Screen"
        },
        {
            "title": "Games"
        },
        {
            "title": "Sea"
        },
        {
            "title": "Food"
        }
    ]

    for rowIndex = 0 to 7
        ' creating placeholders for row items that will be replaced with
        ' actual content items within paginated content handler(CHPaginatedRow)
        placeholders = []
        for i = 1 to 20 ' replace with update/ AppendChildren
            placeholderItem = CreateObject("roSGNode", "ContentNode")
            placeholderItem.hdPosterUrl = "pkg:/images/placeholder.png"

            placeholders.Push(placeholderItem)
        end for

        row = CreateObject("roSGNode", "ContentNode")
        row.title = rowTitles[rowIndex].title
        ' use update for more efficient populating row content node with
        ' placeholder items
        row.Update({
            children: placeholders ' Appending placeholders to row as a children
            HandlerConfigGrid: {
                name: "CHPaginatedRow"
                pageSize: 5 ' size of page that will be requested from API
                ' Passing additional custom params to ContentHandler (should be
                ' declared in Handler's xml)
                query: row.title ' passing title of row to use it as search query for API
            }
        }, true)

        rootChildren.Push(row) ' pushing row's to root content node
    end for

    ' populate root content node
    m.top.content.AppendChildren(rootChildren)
end sub
