sub GetContent()
    rowItems = CreateObject("roSGNode", "ContentNode")
    rowItems.Update({children:[{
        title: "Item 1.1"
        hdPosterUrl: "http://devtools.web.roku.com/samples/audio/nps_poster.jpg"
        description: "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum"" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, ""Lorem ipsum dolor sit amet.."", comes from a line in section 1.10.32."
        releaseDate: "25.12.2018"
        rating: "7.5"
        artists: "Barack Gates, Bill Obama" ' artist metadata will be displayed on MediaView
        album: "Achtung"
        StationTitle: "Station Title" ' this field can be used to display an album title on MediaView
        url: "http://www.sdktestinglab.com/Tutorial/sounds/audionode.mp3"
        streamFormat : "mp3" ' if the mode field  is not set on MediaView, streamFormat will be used to choose the mode
        length: 3 ' this field should be set to see progress bar on MediaView
    },{
        title: "Item 1.2"
        hdPosterUrl: "http://devtools.web.roku.com/samples/audio/nps_poster.jpg"
        description: "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum"" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, ""Lorem ipsum dolor sit amet.."", comes from a line in section 1.10.32."
        releaseDate: "25.12.2018"
        rating: "7.5"
        artists: "Barack Gates, Bill Obama" ' artist metadata will be displayed on MediaView
        album: "Achtung"
        StationTitle: "Station Title" ' this field can be used to display an album title on MediaView
        url: "http://devtools.web.roku.com/samples/audio/John_Bartmann_-_05_-_Home_At_Last.mp3"
        streamFormat : "mp3" ' if the mode field  is not set on MediaView, streamFormat will be used to choose the mode
        length: 130 ' this field should be set to see progress bar on MediaView
    }]}, true)
    m.top.content.AppendChild(rowItems)
end sub
