' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' To populate ButtonBar buttons we need to set content as its children
sub GetContent()
    m.top.content.Update({
        children: [{
            title: "Movies"
            id: "movies"
        }, {
            title: "Series"
            id: "series"
        }, {
            title: "Search"
            id: "search"
        }]
    })
end sub
