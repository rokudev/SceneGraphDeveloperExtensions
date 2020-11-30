sub init()
    m.progressWell = m.top.FindNode("progressWell")
    m.progress = m.top.FindNode("progress")
    m.top.ObserveFieldScoped("position", "OnPlayerPositionChanged")
end sub

sub OnPlayerPositionChanged()
    d = m.top.duration
    if d > 0
        p = m.top.position
        progress = p / d
        if progress >= 1 then progress = 1
        w = m.progressWell.width * progress
        if w < 2 then w = 2 'make sure width is at least couple pixels so 9patch image is rendered properly
        m.progress.width = w
    end if
end sub