--- Treesitter: install parsers, enable highlight + indent per filetype.
local M = {}

local ensure_parsers = {
	'lua',
	'terraform',
	'hcl',
	'go',
	'gomod',
	'gowork',
	'gotmpl',
	'yaml',
	'rust',
	'javascript',
	'typescript',
	'tsx',
	'json',
	'bash',
	'dockerfile',
	'python',
	'toml',
	'markdown',
	'html',
	'css',
	'sql',
	'make',
}

local function mason_bin_on_path()
	local mason_bin = vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'bin')
	local path = vim.env.PATH or ''
	if vim.uv.fs_stat(mason_bin) and not path:find(vim.pesc(mason_bin), 1, true) then
		vim.env.PATH = mason_bin .. ':' .. path
	end
end

local function refresh_treesitter_highlights()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if not vim.api.nvim_buf_is_loaded(buf) then
			goto continue
		end

		local filetype = vim.bo[buf].filetype
		local language = vim.treesitter.language.get_lang(filetype)
		if language and vim.treesitter.language.add(language) then
			pcall(vim.treesitter.start, buf, language)
		end

		::continue::
	end
end

function M.setup()
	mason_bin_on_path()

	require('nvim-treesitter.config').setup({
		install_dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'site'),
	})

	vim.api.nvim_create_autocmd('FileType', {
		group = vim.api.nvim_create_augroup('config-treesitter', { clear = true }),
		callback = function(args)
			local buf, filetype = args.buf, args.match
			local language = vim.treesitter.language.get_lang(filetype)
			if not language or not vim.treesitter.language.add(language) then
				return
			end

			vim.treesitter.start(buf, language)
			vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end,
	})

	local ts = require('nvim-treesitter')
	local installed = ts.get_installed('parsers')
	local missing = vim.tbl_filter(function(lang)
		return not vim.tbl_contains(installed, lang)
	end, ensure_parsers)

	if #missing == 0 then
		return
	end

	-- Install after startup; requires tree-sitter-cli (Mason) and a C compiler (build-essential).
	vim.schedule(function()
		local ok = ts.install(missing, { summary = true })
		if ok then
			refresh_treesitter_highlights()
			return
		end

		vim.notify(
			('Treesitter parser install failed (%s). Ensure build-essential is installed, then run :TSInstall %s'):format(
				table.concat(missing, ', '),
				table.concat(missing, ' ')
			),
			vim.log.levels.WARN
		)
	end)
end

return M
