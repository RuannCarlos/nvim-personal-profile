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

map('n', '<leader>aw', toggle_agent, { desc = '[A]I Toggle [W]indow' })
