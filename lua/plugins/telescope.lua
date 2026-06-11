do
	---@type (string|vim.pack.Spec)[]
	local telescope_plugins = {
		gh 'nvim-lua/plenary.nvim',
		gh 'nvim-telescope/telescope.nvim',
		gh 'nvim-telescope/telescope-ui-select.nvim',
	}
	if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins,
			gh 'nvim-telescope/telescope-fzf-native.nvim') end

	vim.pack.add(telescope_plugins)

	require('telescope').setup {
		extensions = {
			['ui-select'] = { require('telescope.themes').get_dropdown() },
		},
	}

	pcall(require('telescope').load_extension, 'fzf')
	pcall(require('telescope').load_extension, 'ui-select')

	local builtin = require 'telescope.builtin'

	vim.api.nvim_create_autocmd('LspAttach', {
		group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
		callback = function(event)
			local buf = event.buf

			-- Find references for the word under your cursor.
			vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

			-- Jump to the implementation of the word under your cursor.
			-- Useful when your language has ways of declaring types without an actual implementation.
			vim.keymap.set('n', 'gri', builtin.lsp_implementations,
				{ buffer = buf, desc = '[G]oto [I]mplementation' })

			-- Jump to the definition of the word under your cursor.
			-- This is where a variable was first declared, or where a function is defined, etc.
			-- To jump back, press <C-t>.
			vim.keymap.set('n', 'grd', builtin.lsp_definitions,
				{ buffer = buf, desc = '[G]oto [D]efinition' })

			-- Fuzzy find all the symbols in your current document.
			-- Symbols are things like variables, functions, types, etc.
			vim.keymap.set('n', 'gO', builtin.lsp_document_symbols,
				{ buffer = buf, desc = 'Open Document Symbols' })

			-- Fuzzy find all the symbols in your current workspace.
			-- Similar to document symbols, except searches over your entire project.
			vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols,
				{ buffer = buf, desc = 'Open Workspace Symbols' })

			-- Jump to the type of the word under your cursor.
			-- Useful when you're not sure what type a variable is and you want to see
			-- the definition of its *type*, not where it was *defined*.
			vim.keymap.set('n', 'grt', builtin.lsp_type_definitions,
				{ buffer = buf, desc = '[G]oto [T]ype Definition' })
		end,
	})
end
