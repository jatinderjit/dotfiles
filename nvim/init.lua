vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Source vimrc
local vimrc = vim.fn.stdpath("config") .. "/vimrc"
vim.cmd.source(vimrc)

local function is_git_repo()
	vim.fn.system("git rev-parse --is-inside-work-tree")
	return vim.v.shell_error == 0
end
local function get_git_root()
	local dot_git_path = vim.fn.finddir(".git", ".;")
	return vim.fn.fnamemodify(dot_git_path, ":h")
end

local function setup_telescope()
	require("telescope").setup({
		defaults = {
			layout_strategy = "vertical",
			layout_config = { height = 0.95 },
			prompt_prefix = "🔍 ",
			preview = {
				-- Preview images
				-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#use-terminal-image-viewer-to-preview-images
				mime_hook = function(filepath, bufnr, opts)
					local is_image = function()
						local image_extensions = { "png", "jpg", "gif", "ico" } -- Supported image formats
						local split_path = vim.split(filepath:lower(), ".", { plain = true })
						local extension = split_path[#split_path]
						return vim.tbl_contains(image_extensions, extension)
					end
					if is_image() then
						local term = vim.api.nvim_open_term(bufnr, {})
						local function send_output(_, data, _)
							for _, d in ipairs(data) do
								vim.api.nvim_chan_send(term, d .. "\r\n")
							end
						end
						vim.fn.jobstart(
							{ "catimg", filepath }, -- Terminal image viewer command
							{ on_stdout = send_output, stdout_buffered = true, pty = true }
						)
					else
						require("telescope.previewers.utils").set_preview_message(
							bufnr,
							opts.winid,
							"Binary cannot be previewed"
						)
					end
				end,
			},
		},
		pickers = {
			find_files = { theme = "ivy" },
		},
		extensions = {
			-- always use Telescope locations to preview definitions/declarations/implementations etc
			coc = { theme = "ivy", prefer_locations = true },
		},
	})

	require("telescope").load_extension("coc")

	require("telescope").load_extension("vim_bookmarks")
	local bookmark_actions = require("telescope").extensions.vim_bookmarks.actions
	require("telescope").extensions.vim_bookmarks.all({
		attach_mappings = function(_, map)
			-- FIXME: not working
			map("n", "dd", bookmark_actions.delete_selected_or_at_cursor)
			return true
		end,
	})

	-- Ref: https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#live-grep-from-project-git-root-with-fallback
	local function telescope_from_git_root(f)
		return function()
			local opts = {}
			if is_git_repo() then
				opts.cwd = get_git_root()
			end
			require("telescope.builtin")[f](opts)
		end
	end
	vim.keymap.set("n", "<M-o>", telescope_from_git_root("find_files"))
	vim.keymap.set("n", "<leader>fg", telescope_from_git_root("live_grep"))
end
setup_telescope()

require("auto-session").setup()
require("telescope").load_extension("session-lens")

require("indent_blankline").setup()
require("nvim-autopairs").setup() -- TODO: setup enter behaviour
-- https://github.com/windwp/nvim-autopairs/wiki/Completion-plugin
require("project_nvim").setup()
require("telescope").load_extension("projects")

local function setup_nvim_tree()
	require("nvim-tree").setup({
		update_focused_file = { enable = true },
	})
	local api = require("nvim-tree.api")
	local view = require("nvim-tree.view")

	-- Workaround when using rmagatti/auto-session
	-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Recipes#workaround-when-using-rmagattiauto-session
	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		pattern = "NvimTree*",
		callback = function()
			if not view.is_visible() then
				api.tree.open()
			end
		end,
	})

	-- When working on a project with files from multiple repos, change
	-- the root to the current files git root
	-- vim.api.nvim_create_autocmd({ 'BufEnter' }, {
	--     callback = function ()
	--         -- if view.is_visible() and vim.b.git_root ~= nil then
	--         --     local parent = require('plenary').path:new(vim.b.git_root):absolute()
	--         --     api.tree.change_root(parent)
	--         -- end
	--         if view.is_visible() and is_git_repo() then
	--             api.tree.change_root(get_git_root())
	--         end
	--     end
	-- })
end
setup_nvim_tree()

local function setup_ufo_folds()
	-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
	vim.keymap.set("n", "zR", require("ufo").openAllFolds)
	vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

	-- Option 1: coc.nvim as LSP client
	-- require('ufo').setup()

	-- Option 3: treesitter as a main provider instead
	-- Only depend on `nvim-treesitter/queries/filetype/folds.scm`,
	-- performance and stability are better than `foldmethod=nvim_treesitter#foldexpr()`
	require("ufo").setup({
		provider_selector = function(bufnr, filetype, buftype)
			return { "treesitter", "indent" }
		end,
	})
end
setup_ufo_folds()

if vim.g.neovide then
	vim.g.neovide_input_macos_alt_is_meta = true
end
