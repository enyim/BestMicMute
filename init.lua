hs.loadSpoon("GlobalMute")

spoon.GlobalMute:bindHotkeys({
    toggle = {{"cmd", "shift"}, "m"}
})

-- spoon.GlobalMute.menubar_title_muted = "silent ⚪"
-- spoon.GlobalMute.menubar_title_live = "rec 🔴"
spoon.GlobalMute:start()
