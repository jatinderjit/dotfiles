if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  config = function()
    require("nvim-treesitter.configs").setup {
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "css",
        "dart",
        "go",
        "html",
        "htmldjango",
        "lua",
        "nu",
        "python",
        "ruby",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "yaml",
        "vim",
      },
      highlight = {
        enable = true,
      },
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            -- Nushell only
            ["aP"] = "@pipeline.outer",
            ["iP"] = "@pipeline.inner",

            -- supported in other languages as well
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            ["aC"] = "@conditional.outer",
            ["iC"] = "@conditional.inner",
            ["iS"] = "@statement.inner",
            ["aS"] = "@statement.outer",
          }, -- keymaps
        },   -- select
      },     -- textobjects
    }
  end,
  dependencies = {
    { "nushell/tree-sitter-nu" },
  },
  build = ":TSUpdate",
}
