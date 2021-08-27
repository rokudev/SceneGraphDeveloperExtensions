
sub GetContent()
    sleep(700)
    m.top.content.Update({
        hdPosterUrl : "https://dummyimage.com/600x400/ffffff/ff0000.png&text=item+" + m.top.slideIndex.toStr()
    },true)
end sub
