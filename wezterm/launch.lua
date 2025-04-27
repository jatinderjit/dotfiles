-- Copied from https://github.com/KevinSilvester/wezterm-config/blob/master/config/launch.lua
local platform = require("utils.platform")

local options = {
   default_prog = {},
   launch_menu = {},
}

if platform.is_win then
   options.default_prog = { "nu" }
   options.launch_menu = {
      { label = "Nushell", args = { "nu" } },
      { label = "WSL (Ubuntu)", domain = { DomainName = "WSL:Ubuntu" } },
      { label = "PowerShell Core", args = { "pwsh", "-NoLogo" } },
      { label = "PowerShell Desktop", args = { "powershell" } },
      { label = "Command Prompt", args = { "cmd" } },
      { label = "Msys2", args = { "ucrt64.cmd" } },
      {
         label = "Git Bash",
         args = { "C:\\Program Files\\Git\\bin\\bash.exe" },
      },
   }
elseif platform.is_mac then
   options.default_prog = { "/opt/homebrew/bin/zsh", "-l" }
   options.launch_menu = {
      { label = "Zsh", args = { "zsh", "-l" } },
      { label = "Bash", args = { "bash", "-l" } },
      { label = "Fish", args = { "/opt/homebrew/bin/fish", "-l" } },
      { label = "Nushell", args = { "/opt/homebrew/bin/nu", "-l" } },
   }
elseif platform.is_linux then
   options.default_prog = { "zsh", "-l" }
   options.launch_menu = {
      { label = "Zsh", args = { "zsh", "-l" } },
      { label = "Bash", args = { "bash", "-l" } },
      { label = "Fish", args = { "fish", "-l" } },
   }
end

return options
