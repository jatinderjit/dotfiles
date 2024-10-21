local get_mappings = function()
  local maps = { n = {}, v = {} }

  if vim.fn.executable "lazygit" == 1 then
    maps.n["<leader>gg"] = {
      "<cmd>FloatermNew --height=0.8 --width=0.8 lazygit<CR>",
      -- function()
      --   local worktree = require("astronvim.utils.git").file_worktree()
      --   local flags = worktree and (" --work-tree=%s --git-dir=%s"):format(worktree.toplevel, worktree.gitdir) or ""
      --   utils.toggle_term_cmd("lazygit " .. flags)
      -- end,
      desc = "Lazygit",
    }
  end
  maps.n["<leader>tj"] = { ":FloatermNew --autoclose=0 just", desc = "Just" }
  maps.n["<leader>j"] = {
    "<cmd>FloatermNew --autoclose=0 --width=1.0 --height=0.4 --position=bottom just<cr>",
    desc = "Just (default)",
  }
  maps.v["<leader>ts"] = {
    "<cmd>'<,'>FloatermSend<CR><cmd>FloatermToggle<cr>",
    desc = "Send to Terminal",
  }
  maps.n["<leader>tp"] = { "<cmd>FloatermNew ipython<cr>", desc = "Open ipython" }
  return maps
end

---@type LazySpec
return {
  { "akinsho/toggleterm.nvim", enabled = false },
  {
    "voldikss/vim-floaterm",
    lazy = false,
    init = function()
      vim.g.floaterm_keymap_toggle = "<M-3>"
      vim.g.floaterm_keymap_new = "<M-t>"
      vim.g.floaterm_keymap_prev = "<C-j>"
      vim.g.floaterm_keymap_next = "<C-k>"
      vim.g.floaterm_keymap_toggle = "<M-3>"
      vim.g.floaterm_opener = "edit"
      vim.g.floaterm_width = 0.6
      vim.g.floaterm_height = 0.99
      vim.g.floaterm_shell = "/opt/homebrew/bin/zsh"
      vim.g.floaterm_position = "right"
    end,
    opts = { mappings = get_mappings() },
    config = function()
      -- vim.api.nvim_create_autocmd({ "BufEnter" }, {
      --   pattern = { "*.py" },
      --   callback = function(args)
      --     require("astronvim.utils").set_mappings {
      --       n = {
      --         ["<leader>te"] = {
      --           ":FloatermNew --width=0.8 --height=0.8 --autoclose=0 python3 '%'<CR>",
      --           desc = "Execute Current File",
      --           buffer = args.buf,
      --         },
      --       },
      --     }
      --   end,
      -- })
    end,
  },
}
