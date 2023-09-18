-- Turn bluetooth off during sleep.
-- Automatically turn it on after waking up, if it was turned off by this
-- script.
local _obj = { prev_bluetooth_on = nil }

local function is_bluetooth_on()
	return hs.execute("blueutil -p") == "1\n"
end

local function set_bluetooth_state(on)
	local state = on and "1" or "0"
	hs.execute(string.format("blueutil -p %s", state))
end

local function handler(event)
	if event == hs.caffeinate.watcher.systemWillSleep then
		_obj.prev_bt_on = is_bluetooth_on()
		if _obj.prev_bt_on then
			set_bluetooth_state(false)
		end
	else
		if event == hs.caffeinate.watcher.systemDidWake then
			if _obj.prev_bt_on and not is_bluetooth_on() then
				set_bluetooth_state(true)
			end
		end
	end
end

function _obj:start()
	local watcher = hs.caffeinate.watcher.new(handler)
	watcher:start()
end

return _obj
