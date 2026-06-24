local map = require('config.keymaps.utils').map

local agent = {
	buf = nil,
	win = nil,
}

local function ensure_terminal_buffer()
	if agent.buf and vim.api.nvim_buf_is_valid(agent.buf) then
		return agent.buf
	end

	vim.cmd("terminal cursor-agent")
	agent.buf = vim.api.nvim_get_current_buf()
	vim.bo[agent.buf].bufhidden = 'hide'
	vim.bo[agent.buf].swapfile = false
	return agent.buf
end

local function toggle_agent()
	if agent.win and vim.api.nvim_win_is_valid(agent.win) then
		vim.api.nvim_win_close(agent.win, true)
		agent.win = nil
		return
	end

	vim.cmd("botright 15split")
	agent.win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(agent.win, ensure_terminal_buffer())
	vim.cmd.startinsert()
end

local function open_in_cursor(opts)
	opts = opts or {}
	local file = vim.fn.expand('%:p')
	if file == '' then
		vim.notify('No file to open in Cursor', vim.log.levels.ERROR)
		return
	end

	local line = vim.fn.line('.')
	local col = vim.fn.col('.')
	local dir = vim.fn.expand('%:p:h')
	local git_root = vim.fn.system(
		'git -C ' .. vim.fn.shellescape(dir) .. ' rev-parse --show-toplevel 2>/dev/null'
	):gsub('\n', '')
	if vim.v.shell_error ~= 0 then
		git_root = dir
	end

	local args = {}
	if opts.new_window then
		table.insert(args, '-n')
	else
		table.insert(args, '-r')
	end
	table.insert(args, vim.fn.shellescape(git_root))
	table.insert(args, '-g')
	table.insert(args, vim.fn.shellescape(string.format('%s:%d:%d', file, line, col)))

	vim.fn.jobstart('cursor ' .. table.concat(args, ' '), { detach = true })
end

map('n', '<leader>aw', toggle_agent, { desc = '[A]I Toggle [W]indow' })
map('n', '<leader>ac', function()
	open_in_cursor()
end, { desc = 'Open in [C]ursor (reuse window)' })
map('n', '<leader>aC', function()
	open_in_cursor({ new_window = true })
end, { desc = 'Open in [C]ursor (new window)' })
