-- Turn bluetooth off during sleep.
-- Automatically turn it on after waking up, if it was turned off by this script.
local logger = hs.logger.new("bt-sleep", "debug")
local _obj = { prev_bluetooth_on = nil }

local function is_bluetooth_on()
	local resp = hs.execute("blueutil -p")
	logger.d(string.format("blueutil resp='%s'", resp))
	local state = resp == "1\n"
	logger.d(string.format("state=%s", state and "on" or "off"))
	return state
end

local function set_bluetooth_state(on)
	local state = on and "1" or "0"
	hs.execute(string.format("blueutil -p %s", state))
	logger.d(string.format("set_state=%s", on and "on" or "off"))
end

local function handler(event)
	if event == hs.caffeinate.watcher.systemWillSleep then
		logger.d("sleeping")
		_obj.prev_bluetooth_on = is_bluetooth_on()
		if _obj.prev_bluetooth_on then
			set_bluetooth_state(false)
		end
	else
		if event == hs.caffeinate.watcher.systemDidWake then
			logger.d("waking")
			if _obj.prev_bluetooth_on and not is_bluetooth_on() then
				set_bluetooth_state(true)
			end
		end
	end
end

function _obj:start()
	local watcher = hs.caffeinate.watcher.new(handler)
	_obj.prev_bluetooth_on = is_bluetooth_on()
	watcher:start()
end

return _obj
