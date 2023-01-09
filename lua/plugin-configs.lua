-- Aftermath {{{
local addHook = require("aftermath").addHook

addHook({
	id = "auto-size-nvim-ide-components",
	desc = "Automatically resize (horizontally) nvim-ide components when vim is resized",
	event = { "VimResized", "WinEnter", "WinClosed" },
	run = function()
		local panelWidth = 30

		local terminalHeight = 15

		for _, page in ipairs(vim.api.nvim_list_tabpages()) do
			local exists, window = Util.ifNameExists("component://Terminal:.*:" .. page)
			if exists then
				vim.api.nvim_win_set_hl_ns(window, PanelNS)
				if vim.api.nvim_win_get_height(window) > terminalHeight then
					vim.api.nvim_win_set_height(window, terminalHeight)
				end
			end

			exists, window = Util.ifNameExists("component://TerminalBrowser:.*:" .. page)
			if exists then
				vim.api.nvim_win_set_hl_ns(window, PanelNS)
				vim.api.nvim_win_set_width(window, panelWidth)
				if vim.api.nvim_win_get_height(window) > terminalHeight then
					vim.api.nvim_win_set_height(window, terminalHeight)
				end
			end

			exists, window = Util.ifNameExists("component://Explorer:.*:" .. page)
			if exists then
				vim.api.nvim_win_set_hl_ns(window, PanelNS)
				vim.api.nvim_win_set_width(window, panelWidth)
			end

			exists, window = Util.ifNameExists("term://.*")
			if exists then
				vim.api.nvim_win_set_hl_ns(window, PanelNS)
			end
		end
	end,
})

addHook({
	id = "auto-close-nvim-ide",
	desc = "Automatically close nvim if only remaining windows are nvim-ide components",
	event = "WinEnter",
	run = function()
		local newWinName = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(0))

		if not string.find(newWinName, "component://*") and not string.find(newWinName, "term://") then
			return
		end

		local compCount, winCount = Util.compVsWinCount()

		if winCount == compCount then
			vim.cmd("qa")
		end
	end,
})

addHook({
	id = "bottom-panel-close",
	desc = "Close bottom panel on vimenter",
	event = "VimEnter",
	run = function()
		local ws = require("ide.workspaces.workspace_registry").get_workspace(vim.api.nvim_get_current_tabpage())
		ws.panels[require("ide.panels.panel").PANEL_POS_BOTTOM].close()
	end,
})

require("aftermath").setup()

-- }}}
-- autopairs {{{
require("nvim-autopairs").setup()
-- }}}
-- barbecue {{{
require("barbecue").setup({
	---whether to attach navic to language servers automatically
	---@type boolean
	attach_navic = false,

	---whether to create winbar updater autocmd
	---@type boolean
	create_autocmd = true,

	---buftypes to enable winbar in
	---@type string[]
	include_buftypes = { "" },

	---filetypes not to enable winbar in
	---@type string[]
	-- exclude_filetypes = { "component://*", "term://*" },

	modifiers = {
		---filename modifiers applied to dirname
		---@type string
		dirname = ":~:.",

		---filename modifiers applied to basename
		---@type string
		basename = "",
	},

	---returns a string to be shown at the end of winbar
	---@type fun(bufnr: number): string
	-- custom_section = function()
	-- 	return ""
	-- end,

	---whether to replace file icon with the modified symbol when buffer is modified
	---@type boolean
	show_modified = false,

	symbols = {
		---modification indicator
		---@type string
		modified = "●",

		---truncation indicator
		---@type string
		ellipsis = "…",

		---entry separator
		---@type string
		separator = ">",
	},

	---icons for different context entry kinds
	---`false` to disable kind icons
	---@type table<string, string>|false
	kinds = {
		File = "",
		Package = "",
		Module = "",
		Namespace = "",
		Macro = "",
		Class = "",
		Constructor = "",
		Field = "",
		Property = "",
		Method = "",
		Struct = "",
		Event = "",
		Interface = "",
		Enum = "",
		EnumMember = "",
		Constant = "",
		Function = "",
		TypeParameter = "",
		Variable = "",
		Operator = "",
		Null = "",
		Boolean = "",
		Number = "",
		String = "",
		Key = "",
		Array = "",
		Object = "",
	},
})

vim.api.nvim_set_hl(0, "BarbecueSeparator", { bg = "none" })
-- }}}
-- Bufferline {{{
require("bufferline").setup({
	options = {
		mode = "buffers", -- set to "tabs" to only show tabpages instead
		numbers = "none",
		close_command = "lua require('bufdelete').bufdelete(0, true)", -- can be a string | function, see "Mouse actions"
		right_mouse_command = "", -- can be a string | function, see "Mouse actions"
		left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
		middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
		indicator = {
			icon = "▎", -- this should be omitted if indicator style is not 'icon'
			style = "icon",
		},
		buffer_close_icon = "",
		modified_icon = "●",
		close_icon = "",
		left_trunc_marker = "",
		right_trunc_marker = "",
		max_name_length = 18,
		max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
		truncate_names = true, -- whether or not tab names should be truncated
		tab_size = 18,
		diagnostics = "nvim_lsp",
		diagnostics_update_in_insert = false,
		-- NOTE: this will be called a lot so don't do any heavy processing here
		-- custom_filter = function(buf_number, buf_numbers)
		--     -- filter out filetypes you don't want to see
		--     if vim.bo[buf_number].filetype ~= "<i-dont-want-to-see-this>" then
		--         return true
		--     end
		--     -- filter out by buffer name
		--     if vim.fn.bufname(buf_number) ~= "<buffer-name-I-dont-want>" then
		--         return true
		--     end
		--     -- filter out based on arbitrary rules
		--     -- e.g. filter out vim wiki buffer from tabline in your work repo
		--     if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
		--         return true
		--     end
		--     -- filter out by it's index number in list (don't show first buffer)
		--     if buf_numbers[1] ~= buf_number then
		--         return true
		--     end
		-- end,
		offsets = {
			{
				filetype = "filetree",
				text = "Neovim",
				highlight = "Explorer",
				text_align = "center",
			},
		},
		color_icons = true, -- whether or not to add the filetype icon highlights
		show_buffer_icons = true, -- disable filetype icons for buffers
		show_buffer_close_icons = true,
		show_buffer_default_icon = true, -- whether or not an unrecognised filetype should show a default icon
		show_close_icon = true,
		show_tab_indicators = true,
		show_duplicate_prefix = true, -- whether to show duplicate buffer prefix
		persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
		-- can also be a table containing 2 custom separators
		-- [focused and unfocused]. eg: { '|', '|' }
		separator_style = "thick",
		always_show_bufferline = true,
		-- hover = {
		--     enabled = true,
		--     delay = 200,
		--     reveal = {'close'}
		-- },
		-- sort_by = 'insert_after_current' |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
		-- add custom logic
		-- return buffer_a.modified > buffer_b.modified
		-- end
	},
})
-- }}}
-- Bufresize{{{
require("bufresize").setup()
-- }}}
-- colorful-winsep {{{
require("colorful-winsep").setup({
	-- symbols = { "█", "█", "█", "█", "█", "█" },
	symbols = { "━", "┃", "┏", "┓", "┗", "┛" },
})
-- }}}
-- Completion{{{

local cmp = require("cmp")
local luasnip = require("luasnip")

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

cmp.setup({
	snippet = {
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
	},
	formatting = {
		format = require("lspkind").cmp_format({
			with_text = true,
			maxwidth = 50,
			menu = {
				buffer = "[Buffer]",
				nvim_lsp = "[LSP]",
				luasnip = "[Luasnip]",
				nvim_lua = "[Lua]",
				look = "[Look]",
				spell = "[Spell]",
				path = "[Path]",
				calc = "[Calc]",
			},
		}),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = false,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	preselect = cmp.PreselectMode.None,
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "look", keyword_length = 2, options = { convert_case = true, loud = true } },
		{ name = "path" },
		{ name = "calc" },
		{ name = "dictionary" },
	}),
})

require("cmp").setup.cmdline(":", {
	sources = {
		{ name = "cmdline" },
		{ name = "path" },
	},
	mapping = {
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "c" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "c" }),
	},
})

require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()
-- }}}
-- gitsigns{{{
require("gitsigns").setup()
-- }}}
-- glance {{{
require("glance").setup({
	border = {
		enable = true, -- Show window borders. Only horizontal borders allowed
		top_char = "―",
		bottom_char = "―",
	},
})
-- }}}
-- go.nvim {{{
require("go").setup()
-- }}}
-- hls-lens{{{
require("hlslens").setup()
-- }}}
-- Indent_blankline{{{
require("indent_blankline").setup({
	space_char_blankline = " ",
	show_current_context = true,
	show_current_context_start = true,
})
-- }}}
-- LSP related{{{
local lspconfig = require("lspconfig")

vim.diagnostic.config({
	virtual_text = true,
})

-- Formatting
-- Map :Format to vim.lsp.buf.formatting()
vim.cmd([[command! Format execute 'lua vim.lsp.buf.format { async = true }']])

-- Aesthetics
local signs = { Error = " ", Warning = " ", Hint = " ", Information = " " }

for type, icon in pairs(signs) do
	local hl = "LspDiagnosticsSign" .. type

	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

require("mason").setup({
	ui = {
		icons = {
			server_installed = "✓",
			server_pending = "➜",
			server_uninstalled = "✗",
		},
	},
})

require("mason-lspconfig").setup({
	ensure_installed = { "bashls", "clangd", "gopls", "sumneko_lua", "golangci_lint_ls", "tsserver" },
	automatic_installation = true,
})

require("mason-lspconfig").setup_handlers({
	function(server_name)
		lspconfig[server_name].setup({})
	end,
	["gopls"] = function()
		lspconfig.gopls.setup({
			root_dir = lspconfig.util.root_pattern("go.mod", ".git", "main.go"),
		})
	end,
	["sumneko_lua"] = function()
		local runtime_path = vim.split(package.path, ";")
		table.insert(runtime_path, "lua/?.lua")
		table.insert(runtime_path, "lua/?/init.lua")

		lspconfig.sumneko_lua.setup({
			settings = {
				Lua = {
					runtime = {
						-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
						version = "LuaJIT",
						-- Setup your lua path
						path = runtime_path,
					},
					diagnostics = {
						-- Get the language server to recognize the `vim` global
						globals = { "vim" },
					},
					workspace = {
						-- Make the server aware of Neovim runtime files
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
					-- Do not send telemetry data containing a randomized but unique identifier
					telemetry = {
						enable = false,
					},
					format = {
						enable = true,
						-- Put format options here
						-- NOTE: the value should be STRING!!
						defaultConfig = {
							indent_style = "space",
							indent_size = "2",
						},
					},
				},
			},
		})
	end,
})

require("mason-null-ls").setup({
	ensure_installed = { "stylua", "jq", "prettier", "golangci_lint", "clang_format", "shfmt", "goimports" },
	automatic_installation = false,
	automatic_setup = true, -- Recommended, but optional
})

require("null-ls").setup()

require("mason-null-ls").setup_handlers()
-- local prettier = require("prettier")

-- prettier.setup({
--     bin = 'prettier', -- or `'prettierd'` (v0.22+)
--     filetypes = {
--         "css",
--     },
--     cli_options = {
--         arrow_parens = "always",
--         bracket_spacing = true,
--         bracket_same_line = false,
--         embedded_language_formatting = "auto",
--         end_of_line = "lf",
--         html_whitespace_sensitivity = "css",
--         -- jsx_bracket_same_line = false,
--         jsx_single_quote = false,
--         print_width = 80,
--         prose_wrap = "preserve",
--         quote_props = "as-needed",
--         semi = true,
--         single_attribute_per_line = false,
--         single_quote = false,
--         tab_width = 4,
--         trailing_comma = "es5",
--         use_tabs = false,
--         vue_indent_script_and_style = false,
--     },
-- })
-- }}}
-- Lualine{{{

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {},
		always_divide_middle = true,
		globalstatus = true,
	},
	sections = {
		lualine_a = {
			{
				function()
					return "▊"
				end,
				padding = { left = 0, right = 0 },
				color = function()
					local utils = require("lualine.utils.utils")

					-- auto change color according to neovims mode
					local colors = {
						normal = utils.extract_color_from_hllist("fg", { "Function" }, "#000000"),
						insert = utils.extract_color_from_hllist("fg", { "String", "MoreMsg" }, "#000000"),
						replace = utils.extract_color_from_hllist("fg", { "Number", "Type" }, "#000000"),
						visual = utils.extract_color_from_hllist("fg", { "Special", "Boolean", "Constant" }, "#000000"),
						command = utils.extract_color_from_hllist("fg", { "Identifier" }, "#000000"),
						back1 = utils.extract_color_from_hllist("bg", { "Normal", "StatusLineNC" }, "#000000"),
						fore = utils.extract_color_from_hllist("fg", { "Normal", "StatusLine" }, "#000000"),
						back2 = utils.extract_color_from_hllist("bg", { "StatusLine" }, "#000000"),
					}
					local mode_color = {
						["n"] = colors.normal, -- 'NORMAL',
						["no"] = colors.normal, -- 'O-PENDING',
						["nov"] = colors.normal, -- 'O-PENDING',
						["noV"] = colors.normal, -- 'O-PENDING',
						["no\22"] = colors.normal, -- 'O-PENDING',
						["niI"] = colors.normal, -- 'NORMAL',
						["niR"] = colors.replace, -- 'NORMAL',
						["niV"] = colors.normal, -- 'NORMAL',
						["nt"] = colors.normal, -- 'NORMAL',
						["v"] = colors.visual, -- 'VISUAL',
						["vs"] = colors.visual, -- 'VISUAL',
						["V"] = colors.visual, -- 'V-LINE',
						["Vs"] = colors.visual, -- 'V-LINE',
						["\22"] = colors.visual, -- 'V-BLOCK',
						["\22s"] = colors.visual, -- 'V-BLOCK',
						["s"] = colors.replace, -- 'SELECT',
						["S"] = colors.replace, -- 'S-LINE',
						["\19"] = colors.replace, -- 'S-BLOCK',
						["i"] = colors.insert, -- 'INSERT',
						["ic"] = colors.insert, -- 'INSERT',
						["ix"] = colors.insert, -- 'INSERT',
						["R"] = colors.replace, -- 'REPLACE',
						["Rc"] = colors.replace, -- 'REPLACE',
						["Rx"] = colors.replace, -- 'REPLACE',
						["Rv"] = colors.replace, -- 'V-REPLACE',
						["Rvc"] = colors.replace, -- 'V-REPLACE',
						["Rvx"] = colors.replace, -- 'V-REPLACE',
						["c"] = colors.command, -- 'COMMAND',
						["cv"] = colors.command, -- 'EX',
						["ce"] = colors.command, -- 'EX',
						["r"] = colors.replace, -- 'REPLACE',
						["rm"] = colors.replace, -- 'MORE',
						["r?"] = colors.insert, -- 'CONFIRM',
						["!"] = colors.command, -- 'SHELL',
						["t"] = colors.insert, -- 'TERMINAL',
					}
					return { fg = mode_color[vim.fn.mode()], bg = colors.back1 }
				end,
			},
		},
		lualine_b = { "branch", "diff", "diagnostics", "filename" },
		lualine_c = {
			-- {
			-- 	require("noice").api.statusline.mode.get,
			-- 	cond = require("noice").api.statusline.mode.has,
			-- 	color = { fg = "#ff9e64" },
			-- },
		},
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = {
			{
				"location",
				color = {
					fg = require("lualine.utils.utils").extract_color_from_hllist("bg", { "Normal" }, "#000000"),
					bg = require("lualine.utils.utils").extract_color_from_hllist(
						"fg",
						{ "Special", "Boolean", "Constant" },
						"#000000"
					),
				},
			},
		},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	extensions = {},
})

-- }}}
-- mkdnflow {{{
require("mkdnflow").setup({
	links = {
		transform_explicit = function(text)
			-- Make lowercase, remove spaces, and reverse the string
			return string.lower(text:gsub(" ", "_"))
		end,
	},
	mappings = {
		MkdnEnter = { { "n", "v" }, "<CR>" },
		MkdnTab = false,
		MkdnSTab = false,
		MkdnNextLink = false,
		MkdnPrevLink = false,
		MkdnNextHeading = { "n", "]]" },
		MkdnPrevHeading = { "n", "[[" },
		MkdnGoBack = { "n", "<BS>" },
		MkdnGoForward = { "n", "<Del>" },
		MkdnFollowLink = false, -- see MkdnEnter
		MkdnDestroyLink = { "n", "<M-CR>" },
		MkdnTagSpan = { "v", "<M-CR>" },
		MkdnMoveSource = { "n", "<F2>" },
		MkdnYankAnchorLink = { "n", "ya" },
		MkdnYankFileAnchorLink = { "n", "yfa" },
		MkdnIncreaseHeading = { "n", "+" },
		MkdnDecreaseHeading = { "n", "-" },
		MkdnToggleToDo = { { "n", "v" }, "<C-Space>" },
		MkdnNewListItem = false,
		MkdnNewListItemBelowInsert = { "n", "o" },
		MkdnNewListItemAboveInsert = { "n", "O" },
		MkdnExtendList = false,
		MkdnUpdateNumbering = { "n", "<leader>nn" },
		MkdnTableNextCell = { "i", "<Tab>" },
		MkdnTablePrevCell = { "i", "<S-Tab>" },
		MkdnTableNextRow = false,
		MkdnTablePrevRow = { "i", "<M-CR>" },
		MkdnTableNewRowBelow = { "n", "<leader>ir" },
		MkdnTableNewRowAbove = { "n", "<leader>iR" },
		MkdnTableNewColAfter = { "n", "<leader>ic" },
		MkdnTableNewColBefore = { "n", "<leader>iC" },
		MkdnFoldSection = { "n", "<leader>f" },
		MkdnUnfoldSection = { "n", "<leader>F" },
	},
})
-- }}}
-- nvim-dap (and associated plugins){{{
local dap = require("dap")

vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "red" })
vim.fn.sign_define("DapBreakpointCondition", { text = "ﳁ", texthl = "blue" })
vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "red" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "yellow" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "green" })

dap.adapters.go = function(callback, config)
	local handle
	local port = 38697
	handle, _ = vim.loop.spawn("dlv", {
		args = { "dap", "-l", "127.0.0.1:" .. port },
		detached = true,
	}, function(code)
		handle:close()
		print("Delve exited with exit code: " .. code)
	end)
	-- Wait 100ms for delve to start
	vim.defer_fn(function()
		dap.repl.open()
		callback({ type = "server", host = "127.0.0.1", port = port })
	end, 100)
end

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
require("dapui").setup({
	icons = { expanded = "▾", collapsed = "▸" },
	mappings = {
		-- use(a table to apply multiple mappings
		expand = { "<CR>", "<2-LeftMouse>" },
		open = "o",
		remove = "d",
		edit = "e",
		repl = "r",
	},
	layouts = {
		{
			elements = {
				"scopes",
				"breakpoints",
				"stacks",
				"watches",
			},
			size = 40,
			position = "left",
		},
		{
			elements = {
				"repl",
				"console",
			},
			size = 10,
			position = "bottom",
		},
	},
	floating = {
		max_height = nil, -- These can be integers or a float between 0 and 1.
		max_width = nil, -- Floats will be treated as percentage of your screen.
		mappings = {
			close = { "q", "<Esc>" },
		},
	},
	windows = { indent = 1 },
})

dap.adapters.dlv_spawn = function(cb)
	local stdout = vim.loop.new_pipe(false)
	local handle
	local pid_or_err
	local port = 38697
	local opts = {
		stdio = { nil, stdout },
		args = { "dap", "-l", "127.0.0.1:" .. port },
		detached = true,
	}
	handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
		stdout:close()
		handle:close()
		if code ~= 0 then
			print("dlv exited with code", code)
		end
	end)
	assert(handle, "Error running dlv: " .. tostring(pid_or_err))
	stdout:read_start(function(err, chunk)
		assert(not err, err)
		if chunk then
			vim.schedule(function()
				--- You could adapt this and send `chunk` to somewhere else
				require("dap.repl").append(chunk)
			end)
		end
	end)
	-- Wait for delve to start
	vim.defer_fn(function()
		cb({ type = "server", host = "127.0.0.1", port = port })
	end, 100)
end

dap.configurations.go = {
	{
		type = "dlv_spawn",
		name = "Launch dlv & file",
		request = "launch",
		program = "${workspaceFolder}",
	},
	{
		type = "go",
		name = "Debug",
		request = "launch",
		program = "${workspaceFolder}",
	},
	{
		type = "dlv_spawn",
		name = "Debug with arguments",
		request = "launch",
		program = "${workspaceFolder}",
		args = function()
			local args_string = vim.fn.input("Arguments: ")
			return vim.split(args_string, " +")
		end,
	},
	{
		type = "go",
		name = "Debug test",
		request = "launch",
		mode = "test", -- Mode is important
		program = "${file}",
	},
}

require("nvim-dap-virtual-text").setup()

-- }}}
-- nvim-ide{{{
local explorer = require("ide.components.explorer")
local outline = require("ide.components.outline")
local terminal = require("ide.components.terminal")
local terminalbrowser = require("ide.components.terminal.terminalbrowser")

require("ide").setup({
	log_level = "error",
	-- the global icon set to use.
	-- values: "nerd", "codicon", "default"
	icon_set = "codicon",
	-- place Component config overrides here.
	-- they key to this table must be the Component's unique name and the value
	-- is a table which overrides any default config values.
	components = {
		global_keymaps = {
			-- example, change all Component's hide keymap to "h"
			hide = "H",
		},
	},
	-- default panel groups to display on left and right.
	panels = {
		left = "explorer",
		right = "outline",
	},
	-- panels defined by groups of components, user is free to redefine these
	-- or add more.
	panel_groups = {
		explorer = {
			explorer.Name,
		},
		terminal = {
			terminal.Name,
			terminalbrowser.Name,
		},
		outline = {
			outline.Name,
		},
	},

	workspaces = {
		--     auto_close = true
		auto_open = "none",
	},

	panel_sizes = {
		bottom = 15,
		left = 30,
		right = 40,
	},
})
-- }}}
-- scope.nvim {{{
require("scope").setup()
-- }}}
-- session-tabs {{{
require("session-tabs").setup({
	rename_tab = "bufferline",
})
-- }}}
-- Telescope{{{
CommandPaletteAllTheThings = function()
	vim.cmd("Workspace LeftPanelToggle")
	vim.cmd(":lua Util.nvimIDEToggleBottom()")

	-- This fixes a weird issue where the component is called "term://" by default instead of "component://Terminal"
	vim.cmd(":lua Util.nvimIDEToggleBottom()")
	vim.cmd(":lua Util.nvimIDEToggleBottom()")
end

require("telescope").setup({
	defaults = {
		mappings = {
			n = {
				["<esc>"] = require("telescope.actions").close,
			},
		},
	},
	extensions = {
		command_palette = {
			{
				"IDE",
				{ "Workspace", ":Workspace" },
				{ "Toggle Left", ":Workspace LeftPanelToggle" },
				{ "Toggle Right", ":Workspace RightPanelToggle" },
				{ "Toggle Bottom", ":lua Util.nvimIDEToggleBottom()" },
				{ "New Term", ":Workspace TerminalBrowser New" },
				{ "All the things", "lua CommandPaletteAllTheThings()" },
			},
			{
				"Session",
				{ "Delete", "lua require('session-tabs').deleteSession()" },
				{ "Save", "lua require('session-tabs').saveSession()" },
				{ "Load", "lua require('session-tabs').selectSession()" },
			},
		},
	},
})

require("telescope").load_extension("command_palette")
require("telescope").load_extension("file_browser")
require("telescope").load_extension("git_worktree")
-- }}}
-- Treesitter (and associated plugins){{{
require("nvim-treesitter.configs").setup({
	ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	ignore_install = { "haskell", "phpdoc", "norg" }, -- List of parsers to ignore installing
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
		-- custom_captures = {
		--     ["variable"] = "Constant",
	},
	indent = {
		enable = true,
	},
	rainbow = {
		enable = false,
		-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
		extended_mode = false, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = nil, -- Do not enable for files with more than n lines, int
		-- colors = {}, -- table of hex strings
		-- termcolors = {} -- table of colour name strings
	},
	autotag = {
		enable = true,
	},
	textobjects = {
		-- syntax-aware textobjects
		select = {

			enable = true,
			keymaps = {
				-- or you use the queries from supported languages with textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["aC"] = "@class.outer",
				["iC"] = "@class.inner",
				["ac"] = "@conditional.outer",
				["ic"] = "@conditional.inner",
				["ae"] = "@block.outer",
				["ie"] = "@block.inner",
				["al"] = "@loop.outer",
				["il"] = "@loop.inner",
				["is"] = "@statement.inner",
				["as"] = "@statement.outer",
				["ad"] = "@comment.outer",
				["am"] = "@call.outer",
				["im"] = "@call.inner",
			},
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
				["]]"] = { query = "@class.outer", desc = "Next class start" },
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			},
		},
	},
})

require("treesitter-context").setup({
	enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
	max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
	trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
	patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
		-- For all filetypes
		-- Note that setting an entry here replaces all other patterns for this entry.
		-- By setting the 'default' entry below, you can control which nodes you want to
		-- appear in the context window.
		default = {
			"class",
			"function",
			"method",
			"for",
			"while",
			"if",
			"switch",
			"case",
		},
		-- Patterns for specific filetypes
		-- If a pattern is missing, *open a PR* so everyone can benefit.
		tex = {
			"chapter",
			"section",
			"subsection",
			"subsubsection",
		},
		rust = {
			"impl_item",
			"struct",
			"enum",
		},
		scala = {
			"object_definition",
		},
		vhdl = {
			"process_statement",
			"architecture_body",
			"entity_declaration",
		},
		markdown = {
			"section",
		},
		elixir = {
			"anonymous_function",
			"arguments",
			"block",
			"do_block",
			"list",
			"map",
			"tuple",
			"quoted_content",
		},
		json = {
			"pair",
		},
		yaml = {
			"block_mapping_pair",
		},
	},
	exact_patterns = {
		-- Example for a specific filetype with Lua patterns
		-- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
		-- exactly match "impl_item" only)
		-- rust = true,
	},

	-- [!] The options below are exposed but shouldn't require your attention,
	--     you can safely ignore them.

	zindex = 20, -- The Z-index of the context window
	mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
	-- Separator between context and content. Should be a single character string, like '-'.
	-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
	separator = nil,
})

-- }}}
-- Twilight{{{
require("twilight").setup({
	dimming = {
		alpha = 0.25,
		color = { "Normal", "#ffffff" },
		inactive = false,
	},
	context = 10,
	treesitter = true,
	expand = {
		"function",
		"method",
		"table",
		"if_statement",
	},
	exclude = {},
})
-- }}}
-- vim-markdown{{{
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_no_default_key_mappings = 1
vim.g.vim_markdown_conceal = 1
vim.g.vim_markdown_conceal_code_blocks = 0
vim.g.vim_markdown_strikethrough = 1

-- }}}
-- Whichkey{{{
require("which-key").setup({
	triggers_blacklist = {
		c = { "h" },
	},
	show_help = false,
})
-- }}}
-- Zen-mode{{{
require("zen-mode").setup({
	window = {
		backdrop = 0.95,
		width = 120,
		height = 1, -- >1 dicates height of the actual window
		options = {
			signcolumn = "no",
			number = true,
			relativenumber = true,
			cursorline = true,
			cursorcolumn = false,
			foldcolumn = "0",
			list = false,
		},
	},
	plugins = {
		options = {
			enabled = true,
			ruler = true,
			showcmd = true,
		},
		twilight = { enabled = false },
		gitsigns = { enabled = true },
		tmux = { enabled = false },
	},
	on_open = function(win)
		-- can be used to completely disable/enable completion and lsp diags
		-- vim.cmd[[LspStop]]
		-- require('cmp').setup.buffer { enabled = false }
	end,
	on_close = function()
		-- vim.cmd[[LspStart]]
		-- require('cmp').setup.buffer { enabled = true }
	end,
})
-- }}}
