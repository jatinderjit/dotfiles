if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
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
      "python",
      "ruby",
      "rust",
      "toml",
      "tsx",
      "typescript",
      "yaml",
      "vim",
    },
  },
}
