-- links
local map = vim.keymap.set

if vim.loop.os_uname().sysname == "Darwin" then
	map("n", "gx", 'yiW:!open <C-R>"<CR><Esc>')
elseif vim.loop.os_uname().sysname == "Linux" then
	map("n", "gx", 'yiW:!xdg-open <C-R>"<CR><Esc>')
end

-- Remap for dealing with word wrap
-- Allows for navigating through wrapped lines without skipping over the wrapped portion
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

map("v", ">", "'>gv'", { expr = true, silent = true })
map("v", "<", "'<gv'", { expr = true, silent = true })

map("n", "<Esc><Esc>", ":nohl<CR>", { silent = true })

-- Better incsearch
map("n", "n", "<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>")
map("n", "N", "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>")

-- focus tabpages
map("n", "<leader><Tab>", ":tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><S-Tab>", ":tabprevious<cr>", { desc = "Previous Tab" })

-- focus buffers
map("n", "<Tab>", function()
	Util.skipUnwantedBuffers("next")
end)
map("n", "<S-Tab>", function()
	Util.skipUnwantedBuffers("prev")
end)

-- move buffers
map("n", "<A-Tab>", function()
	require("bufferline").move(1)
end)
map("n", "<A-S-Tab>", function()
	require("bufferline").move(-1)
end)

-- Window/buffer stuff
map("n", "<leader>ss", "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split Vertical" })

-- nohl
map("n", "<leader>hh", ":nohl<CR>", { desc = "No highlight" })

-- Split Terminal
map("n", "<leader>stv", "<cmd>vsplit term://" .. vim.o.shell, { desc = "Vertical Term" })
map("n", "<leader>sts", "<cmd>split term://" .. vim.o.shell, { desc = "Horizontal Term" })

-- Term escape
-- map("t", "<A-z>", "<c-\\><c-n>")

-- Close window(split)
map("n", "<A-q>", "<cmd>lua require('bufdelete').bufdelete(0, true)<CR>")

-- Delete buffer
map("n", "<A-S-q>", function()
	local compCount, winCount = Util.compVsWinCount()

	if winCount - 1 == compCount then
		vim.notify("Cannot close last editor window")
		return
	end

	vim.cmd("wincmd c")
end)

-- Window movement
map("n", "<A-S-h>", "<cmd>WinShift left<cr>")
map("n", "<A-S-j>", "<cmd>WinShift down<cr>")
map("n", "<A-S-k>", "<cmd>WinShift up<cr>")
map("n", "<A-S-l>", "<cmd>WinShift right<cr>")

-- Navigate windows/panes incl. tmux
map("n", "<A-j>", function()
	Util.win_focus_bottom()
end)
map("n", "<A-k>", function()
	Util.win_focus_top()
end)
map("n", "<A-l>", function()
	Util.win_focus_right()
end)
map("n", "<A-h>", function()
	Util.win_focus_left()
end)

map("v", "<A-j>", function()
	Util.win_focus_bottom()
end)
map("v", "<A-k>", function()
	Util.win_focus_top()
end)
map("v", "<A-l>", function()
	Util.win_focus_right()
end)
map("v", "<A-h>", function()
	Util.win_focus_left()
end)

map("t", "<A-j>", function()
	Util.win_focus_bottom()
end)
map("t", "<A-k>", function()
	Util.win_focus_top()
end)
map("t", "<A-l>", function()
	Util.win_focus_right()
end)
map("t", "<A-h>", function()
	Util.win_focus_left()
end)

map("n", "<A-C-j>", function()
	Util.win_resize("bottom")
end)
map("n", "<A-C-k>", function()
	Util.win_resize("top")
end)
map("n", "<A-C-l>", function()
	Util.win_resize("right")
end)
map("n", "<A-C-h>", function()
	Util.win_resize("left")
end)

map("v", "<A-C-j>", function()
	Util.win_resize("bottom")
end)
map("v", "<A-C-k>", function()
	Util.win_resize("top")
end)
map("v", "<A-C-l>", function()
	Util.win_resize("right")
end)
map("v", "<A-C-h>", function()
	Util.win_resize("left")
end)

map("t", "<A-C-j>", function()
	Util.win_resize("bottom")
end)
map("t", "<A-C-k>", function()
	Util.win_resize("top")
end)
map("t", "<A-C-l>", function()
	Util.win_resize("right")
end)
map("t", "<A-C-h>", function()
	Util.win_resize("left")
end)

-- Plugin maps

-- Zen
map("n", "<leader>z", ":ZenMode<cr>", { desc = "Zen mode" })

map("n", "<leader>f", Util.toggleFullscreen, { desc = "Fullscreen window" })

-- Commentary
map("n", "<leader>cm", ":Commentary<cr><esc>", { desc = "Comment line" })
map("v", "<leader>cm", ":Commentary<cr><esc>", { desc = "Comment line(s)" })

-- nvim-tree
map("n", "<leader>aa", "<cmd>Telescope file_browser path=%:p:h<CR>", { desc = "File browser" })
map("t", "<leader>aa", "<cmd>Telescope file_browser path=%:p:h<CR>", { desc = "File browser" })

map("n", "<leader>as", Util.nvimIDEToggleBottom, { desc = "Toggle terminal" })
map("t", "<leader>as", Util.nvimIDEToggleBottom, { desc = "Toggle terminal" })

map("n", "<leader>ad", "<cmd>Workspace LeftPanelToggle<CR>", { desc = "Toggle left panel" })
map("t", "<leader>ad", "<cmd>Workspace LeftPanelToggle<CR>", { desc = "Toggle left panel" })

map("n", "<leader>af", "<cmd>Workspace RightPanelToggle<CR>", { desc = "Toggle right panel" })

-- LSP
map("n", "<leader>lD", "<Cmd>Glance definitions<CR>", { desc = "Peek definition" })
map("n", "<leader>ld", vim.lsp.buf.hover, { desc = "Hover Definition" })
map("n", "<leader>lr", "<cmd>Glance references<cr>", { desc = "Peek References" })
map("n", "<leader>lo", vim.diagnostic.open_float, { desc = "Show diagnostics" })
map("n", "<leader>lh", vim.diagnostic.goto_prev, { desc = "Next diagnostic" })
map("n", "<leader>ll", vim.diagnostic.goto_next, { desc = "Prev diagnostic" })
map("n", "<leader>ln", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code action" })

-- Telescopic Johnson
map("n", "<leader>kr", require("telescope.builtin").live_grep, { desc = "Live grep" })
map("n", "<leader>kw", require("telescope.builtin").grep_string, { desc = "Grep string under cursor" })

map("n", "<leader>kF", require("telescope.builtin").find_files, { desc = "Find files" })
map("n", "<leader>kf", require("telescope.builtin").buffers, { desc = "Find buffers" })
map("n", "<leader>kh", require("telescope.builtin").help_tags, { desc = "Search help" })

map("n", "<leader>kF", require("telescope.builtin").quickfix, { desc = "Quickfix list" })
map("n", "<leader>kL", require("telescope.builtin").loclist, { desc = "Location list" })

-- Debug maps
map("n", "<leader>db", require("dap").toggle_breakpoint, { desc = "Toggle breakpoint" })
map("n", "<leader>di", require("dap").step_into, { desc = "Step into" })
map("n", "<leader>dn", require("dap").step_over, { desc = "Step over" })
map("n", "<leader>do", require("dap").step_out, { desc = "Step out" })
map("n", "<leader>du", require("dap").up, { desc = "Up" })
map("n", "<leader>dd", require("dap").down, { desc = "Down" })
map("n", "<leader>drn", require("dap").run_to_cursor, { desc = "Run to cursor" })
map("n", "<leader>dc", require("dap").continue, { desc = "Continue" })
map("n", "<leader>ds", Util.dapStart, { desc = "Start Debug" })
map("n", "<leader>dS", Util.dapStop, { desc = "Stop Debug" })

-- refactoring.nvim
map(
	"v",
	"<leader>re",
	[[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]],
	{ desc = "Extract function" }
)
map(
	"v",
	"<leader>rf",
	[[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]],
	{ desc = "Extract function to file" }
)
map(
	"v",
	"<leader>rv",
	[[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]],
	{ desc = "Extract variable" }
)
map(
	"v",
	"<leader>ri",
	[[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
	{ desc = "Inline variable" }
)
map(
	"n",
	"<leader>ri",
	[[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
	{ desc = "Inline variable" }
)
map("n", "<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]], { desc = "Extact block" })
map(
	"n",
	"<leader>rbf",
	[[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]],
	{ desc = "Extract block to file" }
)

-- Meta LSP stuff
map("n", "<leader>Li", "<cmd>Mason<CR>", { desc = "Mason" })
map("n", "<leader>Lr", "<cmd>LspRestart<CR>", { desc = "Restart LSP" })
map("n", "<leader>Ls", "<cmd>LspStart<CR>", { desc = "Start LSP" })
map("n", "<leader>LS", "<cmd>LspStop<CR>", { desc = "Stop LSP" })

-- Fugitive
map("n", "<leader>gg", "<cmd>vert Git<cr>", { desc = "Git stage" })
map("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git commit" })
map("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git push" })
map("n", "<leader>gl", "<cmd>Gclog<cr>", { desc = "Git commit log" })

-- gitsigns
map("v", "<leader>gs", ":Gitsigns stage_hunk<cr>", { desc = "Stage hunk" })
map("v", "<leader>gu", ":Gitsigns reset_hunk<cr>", { desc = "Reset hunk" })

-- Sessions
map("n", "<leader>Ss", require("session-tabs").saveSession, { desc = "Save session" })
map("n", "<leader>Sl", require("session-tabs").selectSession, { desc = "Load session" })
map("n", "<leader>Sd", require("session-tabs").deleteSession, { desc = "Delete session" })

-- Shift block
map("v", "<C-K>", "xkP`[V`]")
map("v", "<C-J>", "xp`[V`]")

-- nvim-ide
map("n", "<A-Space>", "<cmd>Telescope command_palette<CR>")

-- Fuck q:
-- https://www.reddit.com/r/neovim/comments/lizyxj/how_to_get_rid_of_q/
-- wont work if you take too long to do perform the action, but that's fine
map("n", "q:", "<nop>")

-- AmBiGuOuS UsE oF UsEr-dEfInEd cOmMaNd
vim.api.nvim_create_user_command("W", "w", {})
