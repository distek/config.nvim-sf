local function remove(input, path)
	local retTable = {}
	local ret = ""

	for s in string.gmatch(input, "([^,]+)") do
		if string.match(s, path) == nil then
			table.insert(retTable, s)
		end
	end

	for _, v in pairs(retTable) do
		ret = ret .. v .. ","
	end

	return ret
end

vim.o.packpath = remove(vim.o.packpath, ".local/share/nvim/site")
vim.o.runtimepath = remove(vim.o.runtimepath, ".local/share/nvim/site/pack(.*)")

vim.cmd([[filetype off]])
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.backspace = { "indent", "eol", "start" }
vim.o.clipboard = "unnamedplus"
vim.cmd([[filetype plugin indent on]])
vim.o.ignorecase = true
vim.o.inccommand = "nosplit"
vim.o.smartcase = true
vim.o.startofline = 0

vim.o.swapfile = false
vim.o.undodir = os.getenv("HOME") .. "/.cache/nvim/undodir"
vim.o.undofile = true

local opts = { noremap = true, silent = true }

local map = function(mode, keys, command)
	vim.api.nvim_set_keymap(mode, keys, command, opts)
end

local exmap = function(mode, keys, command)
	vim.api.nvim_set_keymap(mode, keys, command, { noremap = true, expr = true, silent = true })
end

exmap("n", "k", "v:count == 0 ? 'gk' : 'k'")
exmap("n", "j", "v:count == 0 ? 'gj' : 'j'")

exmap("v", ">", "'>gv'")
exmap("v", "<", "'<gv'")

map("v", "<leader>cm", "<Plug>VSCodeCommentarygv<Esc>")
map("n", "<leader>cm", "<Plug>VSCodeCommentaryLine<Esc>")
