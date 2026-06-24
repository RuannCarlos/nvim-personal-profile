--- Filetype and Treesitter language associations not covered by Neovim defaults.
local M = {}

function M.setup()
	vim.filetype.add({
		extension = {
			tfbackend = 'terraform',
		},
		filename = {
			Dockerfile = 'dockerfile',
			['docker-compose%.ya%ml'] = 'yaml.docker-compose',
			['compose%.ya%ml'] = 'yaml.docker-compose',
			['.gitlab%-ci%.ya%ml'] = 'yaml.gitlab',
		},
	})

	-- .tfvars -> terraform-vars at the Vim level; use the terraform parser for highlight/indent.
	vim.treesitter.language.register('terraform', 'terraform-vars')
end

return M
