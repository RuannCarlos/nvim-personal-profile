local map = require('config.keymaps.utils').map

-- Windows
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Project navigation and editing workflow
map("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw [P]roject [V]iew" })
map("n", "<leader>gg", "<cmd>Git<CR>", { desc = "[G]it status" })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('x', '<leader>p', "\"_dp")

-- Toggles
map('n', '<leader>tw', function()
	vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = '[T]oggle [W]rap' })

map('n', '<leader>tn', function()
	vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = '[T]oggle Relative [N]umber' })

vim.diagnostic.config {
	update_in_insert = false,
	severity_sort = true,
	float = { border = 'rounded', source = 'if_many' },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },
	virtual_text = true,
	virtual_lines = false,
	jump = {
		on_jump = function(_, bufnr)
			vim.diagnostic.open_float {
				bufnr = bufnr,
				scope = 'cursor',
				focus = false,
			}
		end,
	},
}
