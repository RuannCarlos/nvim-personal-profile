local options = {
	laststatus = 3,
	ruler = false,      --disable extra numbering
	showmode = false,   --mode is shown by mini.statusline
	showcmd = false,
	wrap = true,        --toggle bound to <leader>tw
	mouse = "a",        --enable mouse
	clipboard = "unnamedplus", --system clipboard integration
	history = 100,      --command line history
	swapfile = false,   --swap just gets in the way, usually
	backup = false,
	undofile = true,    --undos are saved to file
	cursorline = true,  --highlight line
	ttyfast = true,     --faster scrolling
	smoothscroll = true,
	scrolloff = 10,
	title = true,   --automatic window titlebar

	number = true,  --numbering lines
	relativenumber = true, --toggle bound to <leader>tn
	numberwidth = 4,

	smarttab = true, --indentation stuff
	cindent = true,
	autoindent = true,
	tabstop = 4, --visual width of tab

	foldmethod = "expr",
	foldlevel = 99, --disable folding, lower #s enable
	foldexpr = "v:lua.vim.treesitter.foldexpr()",

	termguicolors = true,

	ignorecase = true, --ignore case while searching
	smartcase = true, --but do not ignore if caps are used

	conceallevel = 0,
	concealcursor = "",

	splitkeep = 'screen', --stablizie window open/close
	splitright = true,
	splitbelow = true,
	inccommand = 'split',
	listchars = { tab = '» ', trail = '·', nbsp = '␣' },
	confirm = true,
	winborder = "rounded"
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

