vim.lsp.config('lua_ls', {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	root_markers = { '.git' },
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file('', true),
				checkThirdParty = false,
			},
		},
	},
})

vim.lsp.config('terraform_ls', {
	cmd = { 'terraform-ls', 'serve' },
	filetypes = { 'terraform', 'terraform-vars', 'tf' },
	root_markers = {
		'.terraform',
		'.git',
	},
})

vim.lsp.config('tflint', {
	cmd = { 'tflint', '--langserver' },
	filetypes = { 'terraform', 'terraform-vars', 'tf' },
	root_markers = {
		'.tflint.hcl',
		'.git',
	},
})

vim.lsp.enable({ "lua_ls", "terraform_ls", "tflint" })
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('config-lsp-attach', { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local bufnr = ev.buf
		if not client then
			return
		end

		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
		end

		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
		end

		map('n', 'K', vim.lsp.buf.hover, 'LSP hover')
		map('n', 'grn', vim.lsp.buf.rename, 'LSP rename')
		map({ 'n', 'v' }, 'gra', vim.lsp.buf.code_action, 'LSP code action')
		map('n', 'gD', vim.lsp.buf.declaration, 'Goto declaration')
		map('n', ']d', vim.diagnostic.goto_next, 'Next diagnostic')
		map('n', '[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
		map('n', '<leader>e', vim.diagnostic.open_float, 'Show diagnostic float')

		local ok, builtin = pcall(require, 'telescope.builtin')
		if ok then
			map('n', 'grr', builtin.lsp_references, '[G]oto [R]eferences')
			map('n', 'gri', builtin.lsp_implementations, '[G]oto [I]mplementation')
			map('n', 'grd', builtin.lsp_definitions, '[G]oto [D]efinition')
			map('n', 'gO', builtin.lsp_document_symbols, 'Open document symbols')
			map('n', 'gW', builtin.lsp_dynamic_workspace_symbols, 'Open workspace symbols')
			map('n', 'grt', builtin.lsp_type_definitions, '[G]oto [T]ype Definition')
		else
			map('n', 'grr', vim.lsp.buf.references, '[G]oto [R]eferences')
			map('n', 'gri', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
			map('n', 'grd', vim.lsp.buf.definition, '[G]oto [D]efinition')
			map('n', 'grt', vim.lsp.buf.type_definition, '[G]oto [T]ype Definition')
		end
	end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
	group = vim.api.nvim_create_augroup('config-lsp-format-on-save', { clear = true }),
	pattern = { '*.lua', '*.tf', '*.tfvars' },
	callback = function(args)
		vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 1000 })
	end,
})

vim.opt.completeopt:append('noselect')
