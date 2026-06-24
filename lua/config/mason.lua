--- Mason setup and automatic package installation.
local M = {}

M.packages = {
	'gopls',
	'lua-language-server',
	'yaml-language-server',
	'rust-analyzer',
	'json-lsp',
	'bash-language-server',
	'docker-language-server',
	'pyright',
	'taplo',
	'typescript-language-server',
	'terraform-ls',
	'tflint',
	'tree-sitter-cli',
}

local default_opts = {
	ui = {
		icons = {
			package_installed = '✓',
			package_pending = '➜',
			package_uninstalled = '✗',
		},
	},
}

local setup_done = false
local ensure_running = false

function M.ensure_installed()
	if ensure_running or not setup_done then
		return
	end

	local ok, registry = pcall(require, 'mason-registry')
	if not ok then
		vim.notify('Mason registry unavailable; is mason.nvim loaded?', vim.log.levels.WARN)
		return
	end

	ensure_running = true
	vim.schedule(function()
		local refresh_ok = registry.refresh()
		if not refresh_ok then
			ensure_running = false
			vim.notify('Failed to refresh Mason registry; run :MasonUpdate', vim.log.levels.ERROR)
			return
		end

		local pending = {}
		for _, name in ipairs(M.packages) do
			if not registry.has_package(name) then
				vim.notify(('Unknown Mason package: %s'):format(name), vim.log.levels.WARN)
			else
				local pkg = registry.get_package(name)
				if not pkg:is_installed() and not pkg:is_installing() then
					pending[#pending + 1] = name
					pkg:install()
				end
			end
		end

		if #pending > 0 then
			vim.notify(
				('Installing %d Mason package(s): %s'):format(#pending, table.concat(pending, ', ')),
				vim.log.levels.INFO
			)
		end

		ensure_running = false
	end)
end

---@param opts MasonSettings?
function M.setup(opts)
	local ok, mason = pcall(require, 'mason')
	if not ok then
		return false
	end

	if not mason.has_setup then
		mason.setup(vim.tbl_deep_extend('force', default_opts, opts or {}))
	end

	setup_done = true
	M.ensure_installed()
	return true
end

vim.api.nvim_create_user_command('MasonEnsure', function()
	M.ensure_installed()
end, { desc = 'Install Mason packages listed in config' })

return M
