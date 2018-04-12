sub GetContent()
    ' url = CreateObject("roUrlTransfer")
    ' url.SetUrl("FEED_URL")
    ' url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    ' url.AddHeader("X-Roku-Reserved-Dev-Id", "")
    ' url.InitClientCertificates()
    ' feed = url.GetToString()
    'this is for a sample, usually feed is retrieved from url using roUrlTransfer
    feed = ReadAsciiFile("pkg:/feed/feed.json")
    sleep(2000)

    if feed.Len() > 0
        json = ParseJson(feed)
        if json <> invalid 'and json.rows <> invalid and json.rows.Count() > 0
            rootChildren = []
            for each item in json
                value = json.Lookup(item)
                if item = "movies" OR item = "series"
                    children = []
                    for i = 0 to value.count() - 1
                        itemNode = CreateObject("roSGNode", "ContentNode")
                        itemNode.AddFields(value.GetEntry(i))
                        hdPosterUrl = value.GetEntry(i).thumbnail
                        itemNode.AddField("hdPosterUrl", "Object", false)
                        itemNode.setField("hdPosterUrl", hdPosterUrl)
                        description = value.GetEntry(i).shortDescription
                        itemNode.AddField("Description", "Object", false)
                        itemNode.setField("Description", description)
                        id = value.GetEntry(i).id
                        itemNode.AddField("id", "Object", false)
                        itemNode.setField("id", id)
                        genre = value.GetEntry(i).Lookup("genres").GetEntry(0)
                        itemNode.Addfield("Categories", "Object", false)
                        itemNode.setField("Categories", genre)
                        if item = "movies"
                        ' Add 4k option
                        contentUrl = value.GetEntry(i).Lookup("content").Lookup("videos").GetEntry(0).Lookup("url")
                            itemNode.Addfield("Url", "Object", false)
                            itemNode.setField("Url", contentUrl)
                        end if
                        if item = "series"
                            seasons = value.GetEntry(i).lookup("seasons")
                            itemNode.AddField("seasons", "Object", false)
                            seasonArray = []
                            for each season in seasons
                                episodeArray = []
                                episodes = season.lookup("episodes")
                                for each episode in episodes
                                    ' This is just a workaround to avoid a type mismatch warning on the console
                                    ' The episodeNumber value isn't used anywhere in this sample, so it's safe to delete it
                                    episode.Delete("episodeNumber")

                                    episodeNode = CreateObject("roSGNode", "ContentNode")
                                    episodeNode.addFields(episode)
                                    episodeNode.setFields(episode)
                                    episodeNode.addField("url", "Object", false)
                                    url = episode.Lookup("content").Lookup("videos").GetEntry(0).url
                                    episodeNode.setField("url", url)
                                    episodeNode.addField("hdPosterUrl", "Object", false)
                                    episodeNode.setField("hdPosterUrl", episode.lookup("thumbnail"))
                                    episodeNode.addField("Description", "Object", false)
                                    episodeNode.setField("Description",episode.lookup("shortDescription"))
                                    episodeArray.Push(episodeNode)
                                end for
                                seasonArray.Push(episodeArray)
                            end for
                            itemNode.SetField("seasons", seasonArray)
                        end if
                        children.Push(itemNode)
                    end for
                    rowNode = CreateObject("roSGNode", "ContentNode")
                    rowNode.SetFields({
                        title: item
                    })
                    rowNode.AppendChildren(children)

                    rootChildren.Push(rowNode)
                    m.top.content.AppendChildren(rootChildren)
                end if
            end for
        end if
    end if
end sub
