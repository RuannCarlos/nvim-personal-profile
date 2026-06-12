local map = require('config.keymaps.utils').map

map('n', '<leader>ff', vim.lsp.buf.format, { desc = '[F]ormat current file' })
