--- Native Neovim LSP setup for DevOps-oriented languages.
local mason_bin = vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'bin')

local function go_bin_dir()
	if vim.fn.executable('go') == 1 then
		local out = vim.trim(vim.fn.system({ 'go', 'env', 'GOBIN' }) or '')
		if vim.v.shell_error == 0 and out ~= '' then
			return out
		end
	end
	local gopath = vim.env.GOPATH or vim.fs.joinpath(vim.fn.expand('~'), 'go')
	return vim.fs.joinpath(gopath, 'bin')
end

local function go_toolchain_bin()
	if vim.fn.executable('go') == 1 then
		local goroot = vim.trim(vim.fn.system({ 'go', 'env', 'GOROOT' }) or '')
		if vim.v.shell_error == 0 and goroot ~= '' then
			return vim.fs.joinpath(goroot, 'bin')
		end
	end
	if vim.env.GOROOT and vim.env.GOROOT ~= '' then
		local dir = vim.fs.joinpath(vim.env.GOROOT, 'bin')
		if vim.uv.fs_stat(vim.fs.joinpath(dir, 'go')) then
			return dir
		end
	end
	local fallback = '/usr/local/go/bin'
	if vim.uv.fs_stat(vim.fs.joinpath(fallback, 'go')) then
		return fallback
	end
end

local function prepend_path(dir)
	if not dir or dir == '' or not vim.uv.fs_stat(dir) then
		return
	end
	local path = vim.env.PATH or ''
	if not path:find(vim.pesc(dir), 1, true) then
		vim.env.PATH = dir .. ':' .. path
	end
end

prepend_path(mason_bin)
prepend_path(go_toolchain_bin())
prepend_path(go_bin_dir())

--- Resolve an LSP executable: Mason bin first, then PATH (includes ~/go/bin).
---@param executable string
---@param ... string
---@return string[]
local function lsp_cmd(executable, ...)
	local args = { ... }
	local mason_exe = vim.fs.joinpath(mason_bin, executable)
	if vim.uv.fs_stat(mason_exe) then
		return vim.list_extend({ mason_exe }, args)
	end
	return vim.list_extend({ executable }, args)
end

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

--- Mason packages are installed by config.mason (see plugins/plugins.lua).

---@type table<string, vim.lsp.Config>
local servers = {
	lua_ls = {
		cmd = lsp_cmd('lua-language-server'),
		filetypes = { 'lua' },
		root_markers = { '.git', '.luarc.json', 'stylua.toml' },
		settings = {
			Lua = {
				runtime = { version = 'LuaJIT' },
				diagnostics = { globals = { 'vim' } },
				workspace = {
					library = vim.api.nvim_get_runtime_file('', true),
					checkThirdParty = false,
				},
				telemetry = { enable = false },
			},
		},
	},

	gopls = {
		cmd = lsp_cmd('gopls'),
		filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
		root_markers = { 'go.work', 'go.mod', '.git' },
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
		cmd = lsp_cmd('yaml-language-server', '--stdio'),
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
		cmd = lsp_cmd('rust-analyzer'),
		filetypes = { 'rust' },
		root_markers = { 'Cargo.toml', 'Cargo.lock', '.git' },
	},

	jsonls = {
		cmd = lsp_cmd('vscode-json-language-server', '--stdio'),
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
		cmd = lsp_cmd('bash-language-server', 'start'),
		filetypes = { 'sh', 'bash' },
		root_markers = { '.git' },
	},

	dockerls = {
		cmd = lsp_cmd('docker-language-server', 'start', '--stdio'),
		filetypes = { 'dockerfile' },
		root_markers = { 'Dockerfile', '.git' },
	},

	pyright = {
		cmd = lsp_cmd('pyright-langserver', '--stdio'),
		filetypes = { 'python' },
		root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
	},

	taplo = {
		cmd = lsp_cmd('taplo', 'lsp', 'stdio'),
		filetypes = { 'toml' },
		root_markers = { '.git' },
	},

	ts_ls = {
		cmd = lsp_cmd('typescript-language-server', '--stdio'),
		filetypes = {
			'javascript',
			'javascriptreact',
			'typescript',
			'typescriptreact',
		},
		root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
	},

	terraform_ls = {
		cmd = lsp_cmd('terraform-ls', 'serve'),
		filetypes = terraform_filetypes,
		root_markers = terraform_root_markers,
	},

	tflint = {
		cmd = lsp_cmd('tflint', '--langserver'),
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
