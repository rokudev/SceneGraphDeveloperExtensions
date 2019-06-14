' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

sub GetContent()
    seasons = m.top.HandlerConfig.Lookup("seasons")
    rootChildren = {
       children: []
    }
    seasonNumber = 1
    for each season in seasons
        seasonAA = {
           children: []
        }
        for each episode in season
            seasonAA.children.Push(episode)
        end for
        strSeasonNumber = StrI(seasonNumber)
        seasonAA.Append({
            title: "Season " + strSeasonNumber
            contentType: "section"
        })
        seasonNumber++
        rootChildren.children.Push(seasonAA)
    end for
    
    m.top.content.Update(rootChildren)
end sub
