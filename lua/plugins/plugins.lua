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
		on_attach = function(bufnr)
			local gs = require('gitsigns')
			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
			end

			map('n', ']c', gs.next_hunk, 'Next hunk')
			map('n', '[c', gs.prev_hunk, 'Previous hunk')
			map({ 'n', 'v' }, '<leader>hs', gs.stage_hunk, '[H]unk [S]tage')
			map({ 'n', 'v' }, '<leader>hr', gs.reset_hunk, '[H]unk [R]eset')
			map('n', '<leader>hp', gs.preview_hunk, '[H]unk [P]review')
			map('n', '<leader>hb', gs.blame_line, '[H]unk [B]lame')
		end,
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
			{ '<leader>a', group = '[A]I' },
			{ '<leader>g', group = '[G]it' },
			{ '<leader>h', group = 'Git [H]unk',  mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
			{ 'gr',        group = 'LSP Actions', mode = { 'n' } },
		},
	}

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

	require('mini.pairs').setup()

	require('mini.surround').setup()
	require('mini.icons').setup()
	require('mini.snippets').setup()


	local statusline = require 'mini.statusline'
	statusline.setup { use_icons = vim.g.have_nerd_font }

	statusline.section_location = function() return '%21:%-2v' end
	vim.pack.add { gh 'mason-org/mason.nvim' }
	require('config.mason').setup()

	vim.pack.add { gh 'nvim-treesitter/nvim-treesitter' }

	-- Visual
	vim.pack.add { gh 'folke/tokyonight.nvim' }
	---@diagnostic disable-next-line: missing-fields
	require('tokyonight').setup {}

	--- Git
	---
	vim.pack.add { gh 'tpope/vim-fugitive' }
end

require('plugins.telescope')
