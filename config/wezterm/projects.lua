local wezterm = require("wezterm")
local module = {}

local function project_dirs()
  return {
    "~/projects/gt/gt",
    "~/projects/gt/gt_app",
    "~/projects/oc-owens-corning/occonnect",
    "~/projects/oc-owens-corning/mdms",
    "~/projects/oc-owens-corning/ums",
  }
end

function module.choose_project()
  local choices = {}
  for _, value in ipairs(project_dirs()) do
    table.insert(choices, { label = value })
  end

  -- The InputSelector action presents a modal UI for choosing between a set of
  -- options within WezTerm.
  return wezterm.action.InputSelector({
    title = "Projects",
    choices = choices,
    fuzzy = true,
    action = wezterm.action_callback(function(child_window, child_pane, id, label)
      -- -- The user has selected a project; spawn a new tab with the selected
      -- -- project as the working directory.
      -- wezterm.spawn({
      --   args = { "wezterm", "--new-tab", "--working-directory", label },
      -- })
      wezterm.log_info("Selected project: " .. label)
    end),
  })
end

return module
