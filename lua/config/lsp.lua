--- Native Neovim LSP setup for DevOps-oriented languages.
local mason_bin = vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'bin')

local function mason_bin_on_path()
	local path = vim.env.PATH or ''
	if vim.uv.fs_stat(mason_bin) and not path:find(vim.pesc(mason_bin), 1, true) then
		vim.env.PATH = mason_bin .. ':' .. path
	end
end

mason_bin_on_path()

---@type string[]
local terraform_filetypes = { 'terraform', 'terraform-vars', 'tf' }

---@type string[]
local terraform_root_markers = {
	'.git',
	'.terraform',
	'.terraform-version',
	'versions.tf',
	'main.tf',
	'account.tfvars',
}

---@type string[]
local mason_packages = {
	'yaml-language-server',
	'rust-analyzer',
	'json-lsp',
	'bash-language-server',
	'docker-language-server',
	'pyright',
	'taplo',
	'typescript-language-server',
	'tflint',
	'tree-sitter-cli',
}

local function ensure_mason_packages()
	local ok, registry = pcall(require, 'mason-registry')
	if not ok then
		return
	end

	vim.schedule(function()
		for _, name in ipairs(mason_packages) do
			local pkg_ok, pkg = pcall(registry.get_package, name)
			if pkg_ok and not pkg:is_installed() then
				vim.notify(('Installing Mason package: %s'):format(name), vim.log.levels.INFO)
				pcall(pkg.install, pkg)
			end
		end
	end)
end

ensure_mason_packages()

---@type table<string, vim.lsp.Config>
local servers = {
	lua_ls = {
		cmd = { 'lua-language-server' },
		filetypes = { 'lua' },
		root_markers = { '.git' },
		settings = {
			Lua = {
				runtime = { version = 'LuaJIT' },
				workspace = {
					library = vim.api.nvim_get_runtime_file('', true),
					checkThirdParty = false,
				},
			},
		},
	},

	gopls = {
		cmd = { 'gopls' },
		filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
		root_markers = { 'go.mod', 'go.work', '.git' },
		settings = {
			gopls = {
				analyses = { unusedparams = true },
				staticcheck = true,
				gofumpt = true,
				usePlaceholders = true,
			},
		},
	},

	yamlls = {
		cmd = { 'yaml-language-server', '--stdio' },
		filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
		root_markers = { '.git' },
		settings = {
			yaml = {
				schemaStore = {
					enable = true,
					url = 'https://www.schemastore.org/api/json/catalog.json',
				},
				format = { enable = true, printWidth = 120 },
				validate = true,
				completion = true,
				hover = true,
			},
		},
	},

	rust_analyzer = {
		cmd = { 'rust-analyzer' },
		filetypes = { 'rust' },
		root_markers = { 'Cargo.toml', 'Cargo.lock', '.git' },
	},

	jsonls = {
		cmd = { 'vscode-json-language-server', '--stdio' },
		filetypes = { 'json', 'jsonc' },
		root_markers = { '.git' },
		settings = {
			json = {
				validate = { enable = true },
				format = { enable = true },
			},
		},
	},

	bashls = {
		cmd = { 'bash-language-server', 'start' },
		filetypes = { 'sh', 'bash' },
		root_markers = { '.git' },
	},

	dockerls = {
		cmd = { 'docker-language-server', 'start', '--stdio' },
		filetypes = { 'dockerfile' },
		root_markers = { 'Dockerfile', '.git' },
	},

	pyright = {
		cmd = { 'pyright-langserver', '--stdio' },
		filetypes = { 'python' },
		root_markers = { 'pyproject.toml', 'setup.py', 'requirements.txt', '.git' },
	},

	taplo = {
		cmd = { 'taplo', 'lsp', 'stdio' },
		filetypes = { 'toml' },
		root_markers = { '.git' },
	},

	ts_ls = {
		cmd = { 'typescript-language-server', '--stdio' },
		filetypes = {
			'javascript',
			'javascriptreact',
			'typescript',
			'typescriptreact',
		},
		root_markers = { 'package.json', 'tsconfig.json', '.git' },
	},

	terraform_ls = {
		cmd = { 'terraform-ls', 'serve' },
		filetypes = terraform_filetypes,
		root_markers = terraform_root_markers,
	},

	tflint = {
		cmd = { 'tflint', '--langserver' },
		filetypes = terraform_filetypes,
		root_markers = vim.list_extend({ '.tflint.hcl' }, terraform_root_markers),
	},
}

for name, config in pairs(servers) do
	vim.lsp.config(name, config)
end

vim.lsp.enable(vim.tbl_keys(servers))

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('config-lsp-attach', { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local bufnr = ev.buf
		if not client then
			return
		end

		if client:supports_method('textDocument/completion') then
			-- Built-in completion expands LSP snippets (e.g. func() with cursor inside).
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

local format_filetypes = vim.list_extend({
	'lua',
	'go',
	'gomod',
	'gowork',
	'gotmpl',
	'yaml',
	'yaml.docker-compose',
	'yaml.gitlab',
	'rust',
	'json',
	'jsonc',
	'sh',
	'bash',
	'dockerfile',
	'python',
	'toml',
	'javascript',
	'javascriptreact',
	'typescript',
	'typescriptreact',
}, terraform_filetypes)

vim.api.nvim_create_autocmd('BufWritePre', {
	group = vim.api.nvim_create_augroup('config-lsp-format-on-save', { clear = true }),
	callback = function(args)
		if not vim.tbl_contains(format_filetypes, vim.bo[args.buf].filetype) then
			return
		end
		vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 1000 })
	end,
})

vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'preview' }
