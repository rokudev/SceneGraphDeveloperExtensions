' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

sub GetContent()
    'this is for a sample, usually feed is retrieved from url using roUrlTransfer
    buttons = [
        {
            id: "search_id",
            iconUri: "pkg:/images/search.png"
            title: "Search"
        },
        {
            id: "home_id",
            iconUri: "pkg:/images/home.png"
            title: "Home"
        },
        {
            id: "series_id",
            iconUri: "pkg:/images/series.png",
            title: "Series"
        },
        {
            id: "browse_id",
            iconUri: "pkg:/images/browse.png",
            title: "Browse"
        },
        {
            id: "movie_id",
            iconUri: "pkg:/images/movies-folder.png"
            title: "Movies"
        },
        {
            id: "settings_id",
            iconUri: "pkg:/images/options.png",
            title: "Settings"
        }
    ]
    m.top.content.Update({
        children: buttons
    }, true)
end sub

