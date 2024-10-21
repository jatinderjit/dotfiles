-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---Return functions that creates a scratchpad
---@param filetype string?
---@return function
local scratchpad = function(filetype)
  local fn = "scratch" .. (filetype and ("-" .. filetype) or "")
  return function()
    local bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(bufnr, fn)
    if filetype then vim.api.nvim_buf_set_option(bufnr, "filetype", filetype) end
    vim.api.nvim_win_set_buf(0, bufnr)
  end
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 500, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        -- relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        -- spell = false, -- sets vim.opt.spell
        signcolumn = "auto", -- sets vim.opt.signcolumn to auto
        -- wrap = false, -- sets vim.opt.wrap

        -- Custom
        spell = true,
        spelllang = { "en_us" },
        clipboard = "",
        relativenumber = false,
        wrap = true,
        list = true, -- show whitespace characters
        listchars = { tab = "│→", extends = "⟩", precedes = "⟨", trail = "·", nbsp = "␣" },
        showbreak = "↪ ",
        swapfile = false,
        scrolloff = 6,
        colorcolumn = "80",
        textwidth = 80,
        title = true,
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapLeader` and `mapLocalLeader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        ["<M-k>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["<M-j>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bD"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Pick to close",
        },
        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        ["<Leader>b"] = { desc = "Buffers" },
        -- quick save
        -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
        --

        ["<tab>"] = { function() require("astrocore.buffer").prev() end },

        -- System clipboard
        ["<Leader>y"] = { '"+y' },
        ["<Leader>Y"] = { '"+Y' },
        ["<Leader>d"] = { '"+d' },
        ["<Leader>D"] = { '"+D' },
        ["<Leader>p"] = { '"+p' },
        ["<Leader>P"] = { '"+P' },

        ["<Leader>e"] = { ':e <C-R>=expand("%:p:h") . "/"<CR>' },

        ["<M-E>"] = { "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
        ["<M-e>"] = {
          function()
            if vim.bo.filetype == "neo-tree" then
              vim.cmd.wincmd "p"
            else
              vim.cmd.Neotree "focus"
            end
          end,
          desc = "Toggle Explorer Focus",
        },

        ["<M-f>"] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find in current file" },

        ["<Leader>at"] = { "<cmd>AerialToggle<cr>", desc = "AerialToggle" },
        ["<Leader>an"] = { "<cmd>AerialNavToggle<cr>", desc = "AerialNavToggle" },

        -- Scratchpad
        ["<LocalLeader>sp"] = { name = "Scratchpad" },
        ["<LocalLeader>sp<space>"] = { scratchpad(nil), desc = "Scratchpad" },
        ["<LocalLeader>spp"] = { scratchpad "python", desc = "Python Scratchpad" },
        ["<LocalLeader>spm"] = { scratchpad "markdown", desc = "Markdown Scratchpad" },

        ["<c-s-p>"] = { "<cmd>Telescope commands<cr>", desc = "Telescope commands" },
        ["<M-p>"] = { "<cmd>Telescope buffers<cr>", desc = "Search buffer files" },
        ["<M-o>"] = { "<cmd>Telescope git_files<cr>", desc = "Search git files" },
        ["<M-s>"] = { "<cmd>Telescope spell_suggest<cr>" },
        ["<Leader>fr"] = { "<cmd>Telescope resume<cr>", desc = "Telescope Resume" },
        ["<Leader>o"] = { "<cmd>Telescope buffers<cr>" },
        ["<Leader>fg"] = { "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },

        -- Github links
        ["<Leader>gw"] = { "<cmd>GetCommitLink<cr>", desc = "Copy github link" },
        ["<Leader>gW"] = { "<cmd>GetCommitLink<cr>", desc = "Copy github (current) link" },

        -- Terminal
        ["<Leader>t"] = { name = "Terminal" },
      },
      i = {
        ["jk"] = { "<esc>" },
        ["<M-o>"] = { "<C-o>o" },
        ["<M-O>"] = { "<C-o>O" },
        ["<M-l>"] = { "<cmd>><cr>", desc = "indent" },
        ["<M-h>"] = { "<cmd><<cr>", desc = "dedent" },
      },
      v = {
        ["<Leader>y"] = { '"+y' },
        ["<Leader>Y"] = { '"+Y' },
        ["<Leader>d"] = { '"+d' },
        ["<Leader>D"] = { '"+D' },

        -- Github links
        ["<Leader>gw"] = { "<cmd>GetCommitLink<cr>", desc = "Copy github link" },
        ["<Leader>gW"] = { "<cmd>GetCommitLink<cr>", desc = "Copy github (current) link" },
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
        ["<esc><esc>"] = { "<C-\\><c-n>" },
        ["<C-k>"] = { "<C-c> clear<CR>", desc = "Clear screen" },
      },
    },
    autocmds = {},
  },
}
