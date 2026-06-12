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
		defaults = {
			path_display = { "smart" },
			layout_config = {
				horizontal = { preview_width = 0.55 },
			},
		},
		extensions = {
			['ui-select'] = { require('telescope.themes').get_dropdown() },
		},
	}

	pcall(require('telescope').load_extension, 'fzf')
	pcall(require('telescope').load_extension, 'ui-select')
end
