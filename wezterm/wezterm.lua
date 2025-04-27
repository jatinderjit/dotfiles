-- Ref: https://alexplescan.com/posts/2024/08/10/wezterm/
--
-- `Ctrl-Shift-l`: Lua shell with debug logs
-- `Ctrl-Shift-p`: Show actions

-- Start: Boilerplate (imports, etc.) -----------------------------------------
local wezterm = require("wezterm")
local act = wezterm.action
local platform = require("utils.platform")

local appearance = require("appearance")
local launch = require("launch")

local config = wezterm.config_builder()
-- End: Boilerplate -----------------------------------------------------------

config.default_prog = launch.default_prog
config.launch_menu = launch.launch_menu

local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

-- config.debug_key_events = true
config.audible_bell = "Disabled"

local ENV_OVERRIDES = {}
local PATH = os.getenv("PATH")

if platform.is_mac then
   PATH = "/opt/homebrew/bin:" .. PATH
end

-- If you're using emacs you probably wanna choose a different leader here,
-- since we're gonna be making it a bit harder to CTRL + A for jumping to
-- the start of a line
config.leader = { key = "a", mods = "SUPER", timeout_milliseconds = 1000 }

local color_scheme_light = "Tokyo Night Day"
local color_scheme_dark = "Tokyo Night"

-- https://wezfurlong.org/wezterm/colorschemes/index.html
if appearance.is_dark() then
   config.color_scheme = color_scheme_dark
else
   config.color_scheme = color_scheme_light
end

wezterm.on("window-config-reloaded", function(window, pane)
   local overrides = window:get_config_overrides() or {}
   local scheme = window:get_appearance():find("Dark") and color_scheme_dark or color_scheme_light
   if overrides.color_scheme ~= scheme then
      overrides.color_scheme = scheme
      window:set_config_overrides(overrides)
   end
end)

config.font = wezterm.font({ family = "FiraCode Nerd Font" })
config.font_size = 12.0

-- Slightly transparent and blurred background
-- config.window_background_opacity = 0.8
config.window_background_opacity = 1.0
-- config.macos_window_background_blur = 10

-- Removes the title bar, leaving only the tab bar. Keeps
-- the ability to resize by dragging the window's edges.
-- On macOS, 'RESIZE|INTEGRATED_BUTTONS' also looks nice if
-- you want to keep the window controls visible and integrate
-- them into the tab bar.
config.window_decorations = "RESIZE|INTEGRATED_BUTTONS"
-- Sets the font for the window frame (tab bar)
config.window_frame = {
   -- Berkeley Mono for me again, though an idea could be to try a
   -- serif font here instead of monospace for a nicer look?
   font = wezterm.font({ family = "FiraCode Nerd Font", weight = "Bold" }),
   font_size = 12,
}

local function segments_for_right_status(window)
   return {
      -- window:active_workspace(),
      wezterm.strftime("%a %b %-d %H:%M"),
      -- wezterm.hostname(),
   }
end

wezterm.on("update-status", function(window, _)
   local segments = segments_for_right_status(window)

   local color_scheme = window:effective_config().resolved_palette
   -- Note the use of wezterm.color.parse here, this returns
   -- a Color object, which comes with functionality for lightening
   -- or darkening the colour (amongst other things).
   local bg = wezterm.color.parse(color_scheme.background)
   local fg = color_scheme.foreground

   -- Each powerline segment is going to be coloured progressively
   -- darker/lighter depending on whether we're on a dark/light colour
   -- scheme. Let's establish the "from" and "to" bounds of our gradient.
   local gradient_to, gradient_from = bg
   if appearance.is_dark() then
      gradient_from = gradient_to:lighten(0.2)
   else
      gradient_from = gradient_to:darken(0.2)
   end

   -- Yes, WezTerm supports creating gradients, because why not?! Although
   -- they'd usually be used for setting high fidelity gradients on your terminal's
   -- background, we'll use them here to give us a sample of the powerline segment
   -- colours we need.
   local gradient = wezterm.color.gradient(
      {
         orientation = "Horizontal",
         colors = { gradient_from, gradient_to },
      },
      #segments -- only gives us as many colours as we have segments.
   )

   -- We'll build up the elements to send to wezterm.format in this table.
   local elements = {}

   for i, seg in ipairs(segments) do
      local is_first = i == 1

      if is_first then
         table.insert(elements, { Background = { Color = "none" } })
      end
      table.insert(elements, { Foreground = { Color = gradient[i] } })
      table.insert(elements, { Text = SOLID_LEFT_ARROW })

      table.insert(elements, { Foreground = { Color = fg } })
      table.insert(elements, { Background = { Color = gradient[i] } })
      table.insert(elements, { Text = " " .. seg .. " " })
   end

   window:set_right_status(wezterm.format(elements))
end)

local function activate_pane(key, direction)
   return {
      key = key,
      mods = "SUPER|SHIFT",
      action = act.ActivatePaneDirection(direction),
   }
end

local function resize_pane(key, direction)
   return {
      key = key,
      action = act.AdjustPaneSize({ direction, 3 }),
   }
end

local platform_mod = platform.is_win and "CTRL" or "SUPER"

-- Table mapping keypresses to actions
-- To view all the key mappings: `wezterm show-keys --lua`
config.keys = {
   -- Sends ESC + b and ESC + f sequence, which is used
   -- for telling your shell to jump back/forward.
   { key = "LeftArrow", mods = "OPT", action = act.SendString("\x1bb") },
   { key = "RightArrow", mods = "OPT", action = act.SendString("\x1bf") },
   {
      -- Open the config file in a new tab with `SUPER + ,`
      key = ",",
      mods = platform_mod,
      action = act.SpawnCommandInNewTab({
         cwd = wezterm.home_dir,
         args = { "nvim", wezterm.config_file },
      }),
   },
   {
      key = "k",
      mods = "SUPER",
      action = act.Multiple({
         -- clear scrollback and viewport
         act.ClearScrollback("ScrollbackAndViewport"),
         -- Ask the shell to redraw the prompt
         act.SendKey({ key = "L", mods = "CTRL" }),
      }),
   },
   {
      -- Split the current pane vertically with `SUPER + d`
      key = "d",
      mods = "SUPER",
      action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
   },
   {
      -- Split the current pane horizontally with `SUPER + D`
      key = "D",
      mods = "SUPER",
      action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
   },
   activate_pane("j", "Down"),
   activate_pane("k", "Up"),
   activate_pane("h", "Left"),
   activate_pane("l", "Right"),
   {
      key = "r",
      mods = "LEADER",
      action = wezterm.action.ActivateKeyTable({
         name = "resize_panes",
         -- Ensures the keytable stays active after it handles its first keypress.
         one_shot = false,
         timeout_milliseconds = 1000,
      }),
   },
   {
      key = "f",
      mods = "LEADER",
      action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
   },
   {
      key = "f",
      mods = "SUPER",
      action = act.Search({ CaseInSensitiveString = "" }),
   },
   {
      key = "f",
      mods = "SUPER|SHIFT",
      action = act.Search({ CaseSensitiveString = "" }),
   },
}

config.mouse_bindings = {
   -- CMD-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "SUPER",
      action = wezterm.action.OpenLinkAtMouseCursor,
   },
   -- Disable copy on selection
   {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "NONE",
      action = wezterm.action.Nop,
   },
}

config.key_tables = {
   -- Press `Leader + r` to activate the `resize_panes` keytable
   resize_panes = {
      resize_pane("j", "Down"),
      resize_pane("k", "Up"),
      resize_pane("h", "Left"),
      resize_pane("l", "Right"),
   },
}

ENV_OVERRIDES["PATH"] = PATH
config.set_environment_variables = ENV_OVERRIDES

-- Returns our config to be evaluated. We must always do this at the bottom of this file
return config
