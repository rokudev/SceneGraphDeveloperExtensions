' ********** Copyright 2019 Roku Corp.  All Rights Reserved. **********

'BookmarksHandler interface functions'
sub SaveBookmark()
    content = m.top.content
    position = m.top.position
    BookmarksHelper_SetBookmarkData(content.id, position)
end sub

function GetBookmark() as Integer
    content = m.top.content
    return BookmarksHelper_GetBookmarkData(content.id)
end function

sub RemoveBookmark()
    content = m.top.content
    BookmarksHelper_DeleteBookmark(content.id)
end sub
