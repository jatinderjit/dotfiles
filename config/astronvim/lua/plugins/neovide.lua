if not vim.g.neovide then return {} end

vim.g.neovide_input_macos_option_key_is_meta = "only_left"
vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli')

-- return {
--   "AstroNvim/astrocore",
--   opts = {
--     opt = {
--       g = {
--         neovide_input_macos_option_key_is_meta = "only_left",
--       },
--     },
--   },
-- }
return {}
