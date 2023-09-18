-- local md_clipboard = require("md_clipboard")
-- -- local messagesWindowFilter = hs.window.filter.new(false):setAppFilter("iTerm")
-- -- messagesWindowFilter:subscribe(hs.window.filter.windowFocused, cleanPasteboard)
-- hs.pasteboard.watcher.interval(1)
-- hs.pasteboard.watcher.new(md_clipboard.cleanPasteboard)

-- Turn off bluetooth on system sleep, so that it doesn't automatically connect
-- my earphones while laying in the bag.
local bt_sleep = require("bluetooth_sleep")
bt_sleep:start()
