' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

sub init()
    contentGrid = m.top.FindNode("contentGrid")
    contentGrid.Update({
        translation: [130, 100]
        itemComponentName: "SimpleGridItem"
    })
end sub
