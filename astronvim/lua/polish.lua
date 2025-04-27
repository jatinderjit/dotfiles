-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
vim.filetype.add {
  extension = {
    foo = "fooscript",
    slint = "slint",
  },
  filename = {
    ["Foofile"] = "fooscript",
  },
  pattern = {
    ["~/%.config/foo/.*"] = "fooscript",
    [".*/.ssh/config.d/.*"] = "sshconfig",
  },
}

-- Markdown
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*.md" },
  callback = function(args)
    -- require("astronvim.utils").set_mappings {
    --   n = {
    --     ["<leader>mp"] = {
    --       "<cmd>MarkdownPreview<CR>",
    --       desc = "Markdown Preview",
    --       buffer = args.buf,
    --     },
    --   },
    -- }

    vim.opt_local.conceallevel = 1
    vim.opt_local.textwidth = 80
    -- Macro to convert bare URLs
    vim.fn.setreg("l", "ysaWbi[]jki")
  end,
})

-- Python
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*.py" },
  callback = function(args) vim.cmd 'abbreviate ipdb __import__("ipdb").set_trace()' end,
})

-- JavaScript / TypeScript
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
  callback = function(args)
    vim.cmd "abbreviate fn function"
    vim.cmd "abbreviate tt type"
    vim.cmd "abbreviate ii interface"
    vim.cmd "abbreviate efn export function"
    vim.cmd "abbreviate et export type"
    vim.cmd "abbreviate ei export interface"
  end,
})
