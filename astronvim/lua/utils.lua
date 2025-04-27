-- Ref: https://www.reddit.com/r/neovim/comments/tci7qf/comment/i0gru59/
local uname = vim.loop.os_uname()
local os = uname.sysname

local platform = {
  is_mac = os == "Darwin",
  is_linux = os == "Linux",
  is_windows = os:find "Windows" and true or false,
  is_wsl = os == "Linux" and uname.release:find "Microsoft" and true or false,
}

return {
  platform = platform,
}
