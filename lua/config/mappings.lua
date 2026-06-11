local function map(m, k, v, opts)
    local opts = opts or {} 
    opts.silent = true
        vim.keymap.set(m, k, v, opts)
end
-- windows - ctrl nav, fn resize
map("n", "<C-h>", "<C-w>h", nil)
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

map("n", "<C-h>", "<C-w><C-h>", {desc = "Move focus to the left window"})
map("n", "<C-l>", "<C-w><C-l>", {desc = "Move focus to the right window"})
map("n", "<C-j>", "<C-w><C-j>", {desc = "Move focus to the lower window"})
map("n", "<C-k>", "<C-w><C-k>", {desc = "Move focus to the upper window"})

-- Project Navigation
map("n", "<leader>pv", vim.cmd.Ex)
map('n', '<leader>q', vim.diagnostic.setloclist,  {desc = 'Open diagnostic [Q]uickfix list'})
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

vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = {severity = {min = vim.diagnostic.severity.WARN} },

    virtual_text = true,
    virtual_lines = false,

    jup = {
        on_jump = function(_, bufnr)
            vim.diagnostic.open_float {
		        bufnr = bufnr,
				scope = 'cursor',
				focus = false,
		    }
		end,
    },
}

-- Telescope
-- TODO: Find a better way to organize this
--

local builtin = require 'telescope.builtin'
map('n', '<leader>sh', builtin.help_tags, {desc = '[S]earch [H]elp'})
map('n', '<leader>sk', builtin.keymaps, {desc = '[S]earch [K]eymaps'})
map('n', '<leader>sf', builtin.find_files, {desc = '[S]earch [F]iles'})
map('n', '<leader>ss', builtin.builtin, {desc = '[S]earch [S]elect [F]iles'})
map({'n', 'v'}, '<leader>sw', builtin.grep_string, {desc = '[S]earch current [W]ord'})
map('n', '<leader>sg', builtin.live_grep, {desc = '[S]earch by [G]rep'})
map('n', '<leader>sd', builtin.diagnostics, {desc = '[S]earch [D]iagnostics'})
map('n', '<leader>sr', builtin.resume, {desc = '[S]earch [R]esume'})
map('n', '<leader>s.', builtin.oldfiles, {desc = '[S]earch Recent Files ("." for repeat)'})
map('n', '<leader>sc', builtin.commands, {desc = '[S]earch [C]ommands'})

map('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, {desc = '[/] Fuzzily search in current buffer'})


--- LSP
---
map('n', '<leader>ff', vim.lsp.buf.format, {desc = '[F]ormat current file'})
