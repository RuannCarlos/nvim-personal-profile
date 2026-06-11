---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
function gh(repo) return 'https://github.com/' .. repo end

do
	-- Utilities
	vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
	require('guess-indent').setup {}

	if vim.g.have_nerd_font then vim.pack.add { gh 'nvim-tree/nvim-web-devicons' } end


	vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
	require('gitsigns').setup {
		signs = {
			add = { text = "+" }, --@diagnostic disable-line: missing-fields
			change = { text = "~" }, --@diagnostic disable-line: missing-fields
			delete = { text = "_" }, --@diagnostic disable-line: missing-fields
			topdelete = { text = "‾" }, --@diagnostic disable-line: missing-fields
			changedelete = { text = "~" }, --@diagnostic disable-line: missing-fields
		},
	}
	vim.pack.add { gh 'folke/which-key.nvim' }
	require('which-key').setup {
		-- Delay between pressing a key and opening which-key (milliseconds)
		delay = 0,
		icons = { mappings = vim.g.have_nerd_font },
		-- Document existing key chains
		spec = {
			{ '<leader>s', group = '[S]earch',    mode = { 'n', 'v' } },
			{ '<leader>f', group = '[F]ormat',    mode = { 'n' } },
			{ '<leader>p', group = '[P]roject',   mode = { 'n' } },
			{ '<leader>t', group = '[T]oggle' },
			{ '<leader>h', group = 'Git [H]unk',  mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
			{ 'gr',        group = 'LSP Actions', mode = { 'n' } },
		},
	}
	require("which-key").add({
		{ "<leader>s", group = "[S]earch" },
		{ "<leader>f", group = "[F]ormat" },
		{ "<leader>p", group = "[P]roject" },
		{ "<leader>t", group = "[T]oggle" },
		{ "<leader>h", group = "Git [H]unk" },
		{ "gr",        group = "LSP Actions" },
	})

	vim.pack.add { gh 'folke/todo-comments.nvim' }
	require('todo-comments').setup { signs = false }

	vim.pack.add { gh 'nvim-mini/mini.nvim' }

	require('mini.ai').setup {
		mappings = {
			around_next = 'aa',
			inside_next = 'ii',
		},
		n_lines = 500,
	}

	require('mini.surround').setup()

	local statusline = require 'mini.statusline'
	statusline.setup { use_icons = vim.g.have_nerd_font }

	statusline.section_location = function() return '%21:%-2v' end
	vim.pack.add { gh 'mason-org/mason.nvim' }

	require "mason".setup({
		ui = {
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗"
			}
		}
	})

	-- Visual
	vim.pack.add { gh 'folke/tokyonight.nvim' }
	---@diagnostic disable-next-line: missing-fields
	require('tokyonight').setup {}

	vim.pack.add { gh 'folke/todo-comments.nvim' }
	require('todo-comments').setup {}

	vim.pack.add {
		{ src = 'https://github.com/neovim/nvim-lspconfig' },
	}

	--- Git
	---
	vim.pack.add { gh 'tpope/vim-fugitive' }
end

require('plugins.telescope')
