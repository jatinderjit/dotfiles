local utils = {}

---Returns i-th character of the string s
---@param s string
---@param i integer
---@return string
function utils:at(s, i)
    return string.sub(s, i, i)
end

---Replace `~` at the beginning of the path with the path to user's home directory.
---@param path string
---@return string
function utils:expand_user(path)
    if utils:at(path, 1) == '~' then
        -- This might not work on Windows
        local home = os.getenv("HOME")
        return home .. path:sub(2)
    else
        return path
    end
end

local logPath = utils:expand_user("~/logs/hammerspoon.log")
local logger = hs.logger.new('hs', 'debug')
function utils:log(msg)
    local file = io.open(logPath, "a")
    if file ~= nil then
        file:write(string.format("%s: %s\n", os.date(), msg))
        file:close()
    end
    logger.d(msg)
    hs.notify.new({ title = "Hammerspoon", informativeText = msg }):send()
end

return utils
