-- Plugins {{{
local install_path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
local firstRun = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    firstRun = true

    vim.notify("Cloning plugin manager...")
    vim.cmd("silent !git clone --depth=1 https://github.com/savq/paq-nvim.git " .. install_path)
end

-- Plugin list{{{
require('paq') {
    "savq/paq-nvim",

    -- Treesitter
    'nvim-treesitter/nvim-treesitter',
    'nvim-treesitter/playground',
    'nvim-treesitter/nvim-treesitter-context',
    'nvim-treesitter/nvim-treesitter-textobjects',
    'p00f/nvim-ts-rainbow',
    'windwp/nvim-ts-autotag',

    -- Layout/UI
    'nvim-lualine/lualine.nvim',
    'kevinhwang91/nvim-hlslens',
    'folke/which-key.nvim',
    "kwkarlwang/bufresize.nvim",
    'levouh/tint.nvim',
    "folke/noice.nvim",
    "MunifTanjim/nui.nvim",
    'kyazdani42/nvim-web-devicons',
    "lukas-reineke/indent-blankline.nvim",
    'lewis6991/gitsigns.nvim',
    'ldelossa/nvim-ide',
    "tiagovla/scope.nvim",
    'sindrets/winshift.nvim',
    "akinsho/toggleterm.nvim",
    "folke/zen-mode.nvim",
    "folke/twilight.nvim",
    "distek/session-tabs.nvim",

    -- Filetypes
    'chrisbra/csv.vim',
    'rust-lang/rust.vim',
    'sirtaj/vim-openscad',
    'plasticboy/vim-markdown',
    'ray-x/go.nvim',

    -- lsp
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-look',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-calc',
    'hrsh7th/cmp-nvim-lua',
    'uga-rosa/cmp-dictionary',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/vim-vsnip',
    'rafamadriz/friendly-snippets',
    'onsails/lspkind-nvim',
    'jose-elias-alvarez/null-ls.nvim',
    'MunifTanjim/prettier.nvim',

    -- dap
    'mfussenegger/nvim-dap',
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'mfussenegger/nvim-dap-python',

    -- telescope
    'nvim-telescope/telescope.nvim',
    "nvim-telescope/telescope-file-browser.nvim",
    'nvim-telescope/telescope-ui-select.nvim',
    'nvim-telescope/telescope-dap.nvim',
    "LinArcX/telescope-command-palette.nvim",

    -- misc
    'vimwiki/vimwiki',
    'nvim-lua/plenary.nvim',
    'tpope/vim-commentary',
    "ThePrimeagen/refactoring.nvim",
    'windwp/nvim-autopairs',
    'tpope/vim-fugitive',
    'ThePrimeagen/git-worktree.nvim',
    'powerman/vim-plugin-AnsiEsc',
    'norcalli/nvim-colorizer.lua',
    'distek/aftermath.nvim',

    -- Themes
    'tiagovla/tokyodark.nvim',
}

-- local/development plugins
-- vim.opt.runtimepath:append("~/Programming/neovim-plugs/session-tabs.nvim")
-- }}}

if firstRun then
    vim.cmd([[PaqInstall
    qa
    ]])
end
-- }}}

-- Plugin configs{{{
-- Aftermath {{{
local addHook = require('aftermath').addHook

addHook({
    id = "auto-size-nvim-ide-components",
    desc = "Automatically resize (horizontally) nvim-ide components when vim is resized",
    event = { "VimResized", "WinEnter", "WinClosed" },
    run = function()
        local panelWidth = 35

        local terminalHeight = 20
        local bufferListHeight = 10
        local terminalBrowserHeight = 7
        local explorerHeight = vim.o.lines - terminalBrowserHeight - bufferListHeight - 1 - 1

        local function ifNameExists(n)
            for _, v in ipairs(vim.api.nvim_list_wins()) do
                local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(v))
                if string.find(name, n) then
                    return true, v
                end
            end
            return false, nil
        end

        for _, page in ipairs(vim.api.nvim_list_tabpages()) do
            -- local exists, window = ifNameExists("component://Terminal:.*:" .. page)
            -- if exists then
            --     vim.api.nvim_win_set_height(window, terminalHeight)
            --     vim.api.nvim_win_set_width(window, panelWidth)
            -- end
            exists, window = ifNameExists("component://BufferList:.*:" .. page)
            if exists then
                vim.api.nvim_win_set_height(window, bufferListHeight)
                vim.api.nvim_win_set_width(window, panelWidth)
            end
            exists, window = ifNameExists("component://TerminalBrowser:.*:" .. page)
            if exists then
                vim.api.nvim_win_set_height(window, terminalBrowserHeight)
                vim.api.nvim_win_set_width(window, panelWidth)
            end
            exists, window = ifNameExists("component://Explorer:.*:" .. page)
            if exists then
                vim.api.nvim_win_set_height(window, explorerHeight)
                vim.api.nvim_win_set_width(window, panelWidth)
            end
        end
    end
})


addHook({
    id = "auto-close-nvim-ide",
    desc = "Automatically close nvim if only remaining windows are nvim-ide components",
    event = "WinEnter",
    run = function()
        local newWinName = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(0))

        if not string.find(newWinName, "component://*") then
            return
        end

        local winCount = 0
        local compCount = 0

        for _, v in ipairs(vim.api.nvim_list_wins()) do
            local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(v))

            if vim.api.nvim_win_get_config(v).relative == "" then
                if string.find(name, "component://*") then
                    compCount = compCount + 1
                end
                winCount = winCount + 1
            end
        end

        if winCount == compCount then
            vim.cmd("qa")
        end
    end
})

require('aftermath').setup()

-- }}}
-- Bufresize{{{
require("bufresize").setup()
-- }}}
-- Completion{{{

local cmp = require 'cmp'

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and
        vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

-- cmp.register_source('look', require('cmp_look').new())
--

cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        end
    },
    formatting = {
        format = require('lspkind').cmp_format({
            with_text = true,
            maxwidth  = 50,
            menu      = ({
                buffer   = "[Buffer]",
                nvim_lsp = "[LSP]",
                vsnip    = "[Vsnip]",
                nvim_lua = "[Lua]",
                look     = "[Look]",
                spell    = "[Spell]",
                path     = "[Path]",
                calc     = "[Calc]",
            })
        })
    },
    mapping = {
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif vim.fn["vsnip#available"]() == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
                cmp.complete()
            else
                fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
            end
        end, { "i", "s" }),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
        }),
    },
    preselect = cmp.PreselectMode.None,
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'vsnip' },
        { name = 'buffer' },
        { name = 'look', keyword_length = 2, options = { convert_case = true, loud = true } },
        { name = 'path' },
        { name = 'calc' },
        { name = "dictionary" },
    })
})

require 'cmp'.setup.cmdline(':', {
    sources = {
        { name = 'cmdline' }, { name = 'path' }
    },
    mapping = {
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { "c" }),
        ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { "c" }),
    }
})

vim.g.vsnip_snippet_dir = os.getenv('HOME') ..
    "/.local/share/nvim/site/pack/packer/start/friendly-snippets/snippets"
-- }}}
-- gitsigns{{{
require('gitsigns').setup()
-- }}}
-- go.nvim {{{
require('go').setup()
-- }}}
-- hls-lens{{{
require('hlslens').setup()
-- }}}
-- Indent_blankline{{{
require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
}
-- }}}
-- LSP related{{{
local lspconfig = require('lspconfig')

vim.diagnostic.config({
    virtual_text = true,
})

-- Formatting
-- Map :Format to vim.lsp.buf.formatting()
vim.cmd [[command! Format execute 'lua vim.lsp.buf.format { async = true }']]

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
            server_uninstalled = "✗"
        }
    }
})

require("mason-lspconfig").setup({
    ensure_installed = { "bashls", "clangd", "gopls", "sumneko_lua", "golangci_lint_ls", "tsserver" },
    automatic_installation = true,
})

require("mason-lspconfig").setup_handlers({
    function(server_name)
        lspconfig[server_name].setup {}
    end,
    ["gopls"] = function()
        lspconfig.gopls.setup {
            root_dir = lspconfig.util.root_pattern("go.mod", ".git", "main.go")
        }
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
                },
            },
        })
    end
})

local null_ls = require("null-ls")

null_ls.setup({
    on_attach = function(client, bufnr)
        if client.server_capabilities.documentFormattingProvider then
            vim.cmd("autocmd BufWritePre <buffer> Prettier")
        end

        if client.server_capabilities.documentRangeFormattingProvider then
            vim.cmd("xnoremap <silent><buffer> <Leader>f :lua vim.lsp.buf.range_formatting({})<CR>")
        end
    end,
})

local prettier = require("prettier")

prettier.setup({
    bin = 'prettier', -- or `'prettierd'` (v0.22+)
    filetypes = {
        "css",
    },
    cli_options = {
        arrow_parens = "always",
        bracket_spacing = true,
        bracket_same_line = false,
        embedded_language_formatting = "auto",
        end_of_line = "lf",
        html_whitespace_sensitivity = "css",
        -- jsx_bracket_same_line = false,
        jsx_single_quote = false,
        print_width = 80,
        prose_wrap = "preserve",
        quote_props = "as-needed",
        semi = true,
        single_attribute_per_line = false,
        single_quote = false,
        tab_width = 4,
        trailing_comma = "es5",
        use_tabs = false,
        vue_indent_script_and_style = false,
    },
})
-- }}}
-- Lualine{{{
require('lualine').setup({
    options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '|', right = '|' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {},
        always_divide_middle = true,
        globalstatus = true,
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics', 'filename' },
        lualine_c = {
            {
                require("noice").api.statusline.mode.get,
                cond = require("noice").api.statusline.mode.has,
                color = { fg = "#ff9e64" },
            }
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {
        lualine_a = { 'buffers' },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { { 'tabs', mode = 1 } },
    },
    extensions = {}
})
-- }}}
-- Noice{{{
require("noice").setup({
    cmdline = {
        enabled = true, -- enables the Noice cmdline UI
        view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
        opts = {}, -- global options for the cmdline. See section on views
        ---@type table<string, CmdlineFormat>
        format = {
            -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
            -- view: (default is cmdline view)
            -- opts: any options passed to the view
            -- icon_hl_group: optional hl_group for the icon
            -- title: set to anything or empty string to hide
            cmdline = { pattern = "^:", icon = "", lang = "vim" },
            search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
            filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
            lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
            input = {}, -- Used by input()
            -- lua = false, -- to disable a format, set to `false`
        },
    },
    messages = {
        -- NOTE: If you enable messages, then the cmdline is enabled automatically.
        -- This is a current Neovim limitation.
        enabled = true, -- enables the Noice messages UI
        view = "notify", -- default view for messages
        view_error = "notify", -- view for errors
        view_warn = "notify", -- view for warnings
        view_history = "messages", -- view for :messages
        view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
    },
    popupmenu = {
        enabled = true, -- enables the Noice popupmenu UI
        ---@type 'nui'|'cmp'
        backend = "nui", -- backend to use to show regular cmdline completions
        ---@type NoicePopupmenuItemKind|false
        -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
        kind_icons = {}, -- set to `false` to disable icons
    },
    -- default options for require('noice').redirect
    -- see the section on Command Redirection
    ---@type NoiceRouteConfig
    redirect = {
        view = "popup",
        filter = { event = "msg_show" },
    },
    -- You can add any custom commands below that will be available with `:Noice command`
    ---@type table<string, NoiceCommand>
    commands = {
        history = {
            -- options for the message history that you get with `:Noice`
            view = "split",
            opts = { enter = true, format = "details" },
            filter = {
                any = {
                    { event = "notify" },
                    { error = true },
                    { warning = true },
                    { event = "msg_show", kind = { "" } },
                    { event = "lsp", kind = "message" },
                },
            },
        },
        -- :Noice last
        last = {
            view = "popup",
            opts = { enter = true, format = "details" },
            filter = {
                any = {
                    { event = "notify" },
                    { error = true },
                    { warning = true },
                    { event = "msg_show", kind = { "" } },
                    { event = "lsp", kind = "message" },
                },
            },
            filter_opts = { count = 1 },
        },
        -- :Noice errors
        errors = {
            -- options for the message history that you get with `:Noice`
            view = "popup",
            opts = { enter = true, format = "details" },
            filter = { error = true },
            filter_opts = { reverse = true },
        },
    },
    notify = {
        -- Noice can be used as `vim.notify` so you can route any notification like other messages
        -- Notification messages have their level and other properties set.
        -- event is always "notify" and kind can be any log level as a string
        -- The default routes will forward notifications to nvim-notify
        -- Benefit of using Noice for this is the routing and consistent history view
        enabled = true,
        view = "notify",
    },
    lsp = {
        progress = {
            enabled = false,
            -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
            -- See the section on formatting for more details on how to customize.
            --- @type NoiceFormat|string
            format = "lsp_progress",
            --- @type NoiceFormat|string
            format_done = "lsp_progress_done",
            throttle = 1000 / 30, -- frequency to update lsp progress message
            view = "mini",
        },
        override = {
            -- override the default lsp markdown formatter with Noice
            ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
            -- override the lsp markdown formatter with Noice
            ["vim.lsp.util.stylize_markdown"] = false,
            -- override cmp documentation with Noice (needs the other options to work)
            ["cmp.entry.get_documentation"] = false,
        },
        hover = {
            enabled = true,
            view = nil, -- when nil, use defaults from documentation
            ---@type NoiceViewOptions
            opts = {}, -- merged with defaults from documentation
        },
        signature = {
            enabled = true,
            auto_open = {
                enabled = true,
                trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
                luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
                throttle = 50, -- Debounce lsp signature help request by 50ms
            },
            view = nil, -- when nil, use defaults from documentation
            ---@type NoiceViewOptions
            opts = {}, -- merged with defaults from documentation
        },
        message = {
            -- Messages shown by lsp servers
            enabled = true,
            view = "notify",
            opts = {},
        },
        -- defaults for hover and signature help
        documentation = {
            view = "hover",
            ---@type NoiceViewOptions
            opts = {
                lang = "markdown",
                replace = true,
                render = "plain",
                format = { "{message}" },
                win_options = { concealcursor = "n", conceallevel = 3 },
            },
        },
    },
    markdown = {
        hover = {
            ["|(%S-)|"] = vim.cmd.help, -- vim help links
            ["%[.-%]%((%S-)%)"] = require("noice.util").open, -- markdown links
        },
        highlights = {
            ["|%S-|"] = "@text.reference",
            ["@%S+"] = "@parameter",
            ["^%s*(Parameters:)"] = "@text.title",
            ["^%s*(Return:)"] = "@text.title",
            ["^%s*(See also:)"] = "@text.title",
            ["{%S-}"] = "@parameter",
        },
    },
    health = {
        checker = true, -- Disable if you don't want health checks to run
    },
    smart_move = {
        -- noice tries to move out of the way of existing floating windows.
        enabled = true, -- you can disable this behaviour here
        -- add any filetypes here, that shouldn't trigger smart move.
        excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
    },
    ---@type NoicePresets
    presets = {
        -- you can enable a preset by setting it to true, or a table that will override the preset config
        -- you can also add custom presets that you can enable/disable with enabled=true
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
    },
    throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
    ---@type NoiceConfigViews
    views = {
        cmdline_popup = {
            position = {
                row = 2,
                col = "50%"
            },
            border = {
                style = "solid"
            },
            win_options = {
                winhighlight = {
                    Normal = "NoicePopup",
                    FloatBorder = "DiagnosticInfo"
                },
            },
        },
        hover = {
            border = {
                style = "solid",
                anchor = "SW",
            }
        },
        notify = {
            backed = "mini"
        }

    }, ---@see section on views
    ---@type NoiceRouteConfig[]
    routes = {
        {
            vim = "notify",
            filter = { event = "msg_showmode" }
        },
        {
            filter = { event = "msg_show", kind = "search_count" },
            opts = { skip = true }
        }
    }, --- @see section on routes
    ---@type table<string, NoiceFilter>
    status = {}, --- @see section on statusline components
    ---@type NoiceFormatOptions
    format = {}, --- @see section on formatting
})
-- }}}
-- nvim-dap (and associated plugins){{{
local dap = require('dap')

vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'red' })
vim.fn.sign_define('DapBreakpointCondition', { text = 'ﳁ', texthl = 'blue' })
vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'red' })
vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'yellow' })
vim.fn.sign_define('DapStopped', { text = '', texthl = 'green' })

dap.adapters.go = function(callback, config)
    local handle
    local port = 38697
    handle, _ = vim.loop.spawn("dlv", {
        args = { "dap", "-l", "127.0.0.1:" .. port },
        detached = true
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
                'scopes',
                'breakpoints',
                'stacks',
                'watches',
            },
            size = 40,
            position = 'left',
        },
        {
            elements = {
                'repl',
                'console',
            },
            size = 10,
            position = 'bottom',
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
        detached = true
    }
    handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
        stdout:close()
        handle:close()
        if code ~= 0 then
            print('dlv exited with code', code)
        end
    end)
    assert(handle, 'Error running dlv: ' .. tostring(pid_or_err))
    stdout:read_start(function(err, chunk)
        assert(not err, err)
        if chunk then
            vim.schedule(function()
                --- You could adapt this and send `chunk` to somewhere else
                require('dap.repl').append(chunk)
            end)
        end
    end)
    -- Wait for delve to start
    vim.defer_fn(
        function()
            cb({ type = "server", host = "127.0.0.1", port = port })
        end,
        100)
end

dap.configurations.go = {
    {
        type = 'dlv_spawn',
        name = 'Launch dlv & file',
        request = 'launch',
        program = "${workspaceFolder}";
    },
    {
        type = "go",
        name = "Debug",
        request = "launch",
        program = "${workspaceFolder}"
    },
    {
        type = "dlv_spawn",
        name = "Debug with arguments",
        request = "launch",
        program = "${workspaceFolder}",
        args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, " +")
        end,

    },
    {
        type = "go",
        name = "Debug test",
        request = "launch",
        mode = "test", -- Mode is important
        program = "${file}"
    }
}

require('nvim-dap-virtual-text').setup()

-- }}}
-- nvim-ide{{{
local explorer        = require('ide.components.explorer')
local outline         = require('ide.components.outline')
local timeline        = require('ide.components.timeline')
local terminal        = require('ide.components.terminal')
local terminalbrowser = require('ide.components.terminal.terminalbrowser')
local changes         = require('ide.components.changes')
local commits         = require('ide.components.commits')
local branches        = require('ide.components.branches')
local buffers         = require('ide.components.bufferlist')

require('ide').setup({
    -- the global icon set to use.
    -- values: "nerd", "codicon", "default"
    icon_set = "codicon",
    -- place Component config overrides here.
    -- they key to this table must be the Component's unique name and the value
    -- is a table which overrides any default config values.
    components = {
        global_keymaps = {
            -- example, change all Component's hide keymap to "h"
            hide = "H"
        },
    },
    -- default panel groups to display on left and right.
    panels = {
        left = "explorer",
        right = "outline"
    },
    -- panels defined by groups of components, user is free to redefine these
    -- or add more.
    panel_groups = {
        explorer = {
            buffers.Name,
            explorer.Name,
            terminalbrowser.Name
        },
        terminal = {
            terminal.Name
        },
        git = { changes.Name,
            commits.Name,
            timeline.Name,
            branches.Name
        },
        outline = {
            outline.Name,
        }
    },

    workspaces = {
        --     auto_close = true
        auto_open = 'none'
    },

    panel_sizes = {
        bottom = 15,
        left = 30,
        right = 40
    }
})
-- }}}
-- scope.nvim {{{
require("scope").setup()
-- }}}
-- session-tabs {{{
require('session-tabs').setup()
-- }}}
-- Telescope{{{
CommandPaletteAllTheThings = function()
    vim.cmd("Workspace LeftPanelToggle")
    vim.cmd("Workspace TerminalBrowser New")

    -- This fixes a weird issue where the component is called "term://" by default instead of "component://Terminal"
    vim.cmd("Workspace BottomPanelToggle")
    vim.cmd("Workspace BottomPanelToggle")
end

require('telescope').setup({
    extensions = {
        command_palette = {
            { "IDE",
                { "Workspace", ":Workspace" },
                { "Toggle Left", ":Workspace LeftPanelToggle" },
                { "Toggle Right", ":Workspace RightPanelToggle" },
                { "Toggle Bottom", ":Workspace BottomPanelToggle" },
                { "Swap right", "lua Util.nvimIDESwapRightPanel()" },
                { "New Term", ":Workspace TerminalBrowser New" },
                { "All the things", "lua CommandPaletteAllTheThings()" }
            },
            { "Session",
                { "Delete", "lua require('session-tabs').deleteSession()" },
                { "Save", "lua require('session-tabs').saveSession()" },
                { "Load", "lua require('session-tabs').selectSession()" },
            },
        }
    }
})

require('telescope').load_extension('command_palette')
require('telescope').load_extension('file_browser')
require("telescope").load_extension("git_worktree")
-- }}}
-- tint{{{
require("tint").setup({
    tint = -2, -- Darken colors, use a positive value to brighten
    saturation = 0.8, -- Saturation to preserve
    transforms = require("tint").transforms.SATURATE_TINT, -- Showing default behavior, but value here can be predefined set of transforms
    tint_background_colors = true, -- Tint background portions of highlight groups
    highlight_ignore_patterns = { "WinSeparator", "Status.*" }, -- Highlight group patterns to ignore, see `string.find`
    window_ignore_function = function(winid)
        -- local bufid = vim.api.nvim_win_get_buf(winid)
        -- local buftype = vim.api.nvim_buf_get_option(bufid, "buftype")
        -- local floating = vim.api.nvim_win_get_config(winid).relative ~= ""

        -- Do not tint `terminal` or floating windows, tint everything else
        return false
    end
})
-- }}}
-- toggleterm.nvim{{{

require("toggleterm").setup {
    open_mapping = [[<c-`>]],
    size = 15,
    hide_numbers = true,
    shade_terminals = true,
    shading_factor = '0.4',
    start_in_insert = true,
    terminal_mappings = true,
    persist_size = true,
    direction = 'horizontal',
    close_on_exit = false,
}

local lazygitCfg = {
    cmd = "lazygit",
    direction = "float",
}

local lazygit = require('toggleterm.terminal').Terminal:new(lazygitCfg)

function LazygitFloat()
    lazygit:toggle()
end

local normalTermCfg = {
    cmd = Vimterm,
    direction = "float",
}

local normalTerm = require('toggleterm.terminal').Terminal:new(normalTermCfg)

function NormalTermFloat()
    normalTerm:toggle()
end

-- }}}
-- Treesitter (and associated plugins){{{
require 'nvim-treesitter.configs'.setup {
    ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    ignore_install = { 'haskell', 'phpdoc', 'norg' }, -- List of parsers to ignore installing
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
                ["im"] = "@call.inner"
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
    }
}

require 'treesitter-context'.setup {
    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
    trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
        -- For all filetypes
        -- Note that setting an entry here replaces all other patterns for this entry.
        -- By setting the 'default' entry below, you can control which nodes you want to
        -- appear in the context window.
        default = {
            'class',
            'function',
            'method',
            'for',
            'while',
            'if',
            'switch',
            'case',
        },
        -- Patterns for specific filetypes
        -- If a pattern is missing, *open a PR* so everyone can benefit.
        tex = {
            'chapter',
            'section',
            'subsection',
            'subsubsection',
        },
        rust = {
            'impl_item',
            'struct',
            'enum',
        },
        scala = {
            'object_definition',
        },
        vhdl = {
            'process_statement',
            'architecture_body',
            'entity_declaration',
        },
        markdown = {
            'section',
        },
        elixir = {
            'anonymous_function',
            'arguments',
            'block',
            'do_block',
            'list',
            'map',
            'tuple',
            'quoted_content',
        },
        json = {
            'pair',
        },
        yaml = {
            'block_mapping_pair',
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
    mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
    -- Separator between context and content. Should be a single character string, like '-'.
    -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    separator = nil,
}

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

vim.o.conceallevel = 2
-- }}}
-- vimwiki --{{{
vim.g.vimwiki_key_mappings = {
    all_maps = 1,
    global = 1,
    headers = 1,
    text_objs = 1,
    table_format = 1,
    table_mappings = 0,
    lists = 1,
    links = 0,
    html = 1,
    mouse = 0,
}
-- }}}
-- Whichkey{{{
require("which-key").setup {
    triggers_blacklist = {
        c = { "h" },
    },
    show_help = false
}
-- }}}
-- Zen-mode{{{
require("zen-mode").setup(
    {
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
    }
)
-- }}}
-- }}}

-- Global sets {{{
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.autoread = true
vim.backspace = { "indent", "eol", "start" }
vim.o.breakindent = true
vim.o.clipboard = "unnamedplus"
vim.o.cmdheight = 1
vim.wo.colorcolumn = "0"
vim.o.cursorline = true
vim.o.encoding = "utf-8"
vim.o.expandtab = true
vim.o.fileformats = "unix,dos,mac"
vim.cmd [[filetype plugin indent on]]
vim.o.fillchars = "vert:│,fold:-,eob: "
vim.o.foldmethod = "marker"
vim.o.hidden = true
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.inccommand = "nosplit"
vim.o.incsearch = true
vim.opt.laststatus = 3
vim.o.linebreak = true
vim.o.modeline = true
vim.o.modelines = 5
vim.o.mouse = "a"
vim.o.number = true
vim.o.numberwidth = 5
vim.o.pumblend = 15
vim.o.relativenumber = true
vim.o.ruler = true
vim.o.scrolloff = 2
vim.o.shell = os.getenv("SHELL")
-- Vimterm = vim.fn.expand("~") .. "/.config/nvim/scripts/vimterm.sh"
Vimterm = vim.o.shell
vim.o.shiftwidth = 4
vim.o.showbreak = "↪ "
vim.o.showmode = false
vim.o.showtabline = 2
vim.o.signcolumn = "yes:2"
vim.o.smartcase = true
vim.o.softtabstop = 0
vim.opt.spell = false
vim.opt.spelllang = { 'en_us' }
vim.o.startofline = 0
vim.o.syntax = "on"
vim.o.tabstop = 4
vim.o.termguicolors = true
vim.o.timeoutlen = 250
vim.o.updatetime = 250
vim.o.wildignore = "*.o,*.obj,.git,*.rbc,*.pyc,__pycache__"
vim.o.wildmode = "list:longest,list:full"
vim.o.wrap = true

vim.cmd [[set sessionoptions-=blank]]

vim.o.swapfile = false
vim.o.undodir = os.getenv("HOME") .. "/.cache/nvim/undodir"
vim.o.undofile = true

vim.o.splitright = true
vim.o.splitbelow = true

-- Cursor shape:
-- Insert - line; Normal - block; Replace - underline
-- Works with tmux as well
vim.cmd [[
    if empty($TMUX)
        let &t_SI = "\<Esc>]50;CursorShape=1\x7"
        let &t_EI = "\<Esc>]50;CursorShape=0\x7"
        let &t_SR = "\<Esc>]50;CursorShape=2\x7"
    else
        let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
        let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
        let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
    endif
]]

-- netrw Sexplore or Lexplore
vim.cmd [[let g:netrw_winsize = 20]]

-- Disabled builtins {{{
-- Improves startup time just ever so slightly
local disabled_built_ins = {
    -- Need netrw for certain things, like remote editing
    -- "netrw",
    -- "netrwPlugin",
    -- "netrwSettings",
    -- "netrwFileHandlers",
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit",
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end
--}}}
--}}}

-- Util{{{
function len(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

Util = {}

-- Returns to previous position in file
Util.line_return = function()
    local line = vim.fn.line

    if line("'\"") > 0 and line("'\"") <= line("$") then
        vim.cmd("normal! g`\"zvzz'")
    end
end

Util.bufFocus = function(dir)
    local bufs = require('lualine.components.buffers').bufpos2nr

    local currentBuf = vim.api.nvim_get_current_buf()

    local pos = 0

    for i, v in ipairs(bufs) do
        if v == currentBuf then
            pos = i
            break
        end
    end

    if pos == 0 then
        return
    end

    if dir == "next" then
        pos = pos + 1

        if pos > #bufs then
            pos = 1
        end
    elseif dir == "prev" then
        pos = pos - 1

        if pos <= 0 then
            pos = #bufs
        end
    end

    vim.api.nvim_set_current_buf(bufs[pos])
end

-- Skips over quickfix buf when tabbing through buffers
-- Reason: QF appears to overwrite the <Tab> mappings
Util.skipUnwantedBuffers = function(dir)
    Util.bufFocus(dir)

    local buftype = vim.api.nvim_buf_get_option(0, "buftype")

    if buftype == "quickfix" or buftype == "terminal" then
        if buftype == "terminal" then
            -- if the terminal is not open elsewhere
            if len(vim.fn.win_findbuf(vim.fn.bufnr('%'))) == 1 then
                return
            end

            vim.cmd [[stopinsert]]

            return
        end

        Util.skipUnwantedBuffers(dir)
    end
end

Util.nvimIDESwapRightPanel = function()
    local ws = require('ide.workspaces.workspace_registry').get_workspace(vim.api.nvim_get_current_tabpage())
    if ws == nil then
        return
    end

    if ws.panels["right"] == ws.panel_groups["outline"] then
        ws.swap_panel("right", "git")
    else
        ws.swap_panel("right", "outline")
    end

    -- ws.swap_panel(pos, group)
end

DAPIDEStates = {
    bottom = false,
    left = false,
    right = false
}

local function closeNvimIDEPanels()
    if pcall(require, 'ide') then
        local ws = require('ide.workspaces.workspace_registry').get_workspace(vim.api.nvim_get_current_tabpage())
        if ws ~= nil then
            local left = ws.panels[require('ide.panels.panel').PANEL_POS_LEFT]
            local right = ws.panels[require('ide.panels.panel').PANEL_POS_RIGHT]
            local bottom = ws.panels[require('ide.panels.panel').PANEL_POS_BOTTOM]

            print(left)
            if left ~= nil then
                if left.is_open() then
                    left.close()
                    DAPIDEStates.left = true
                end
            end
            if right ~= nil then
                if right.is_open() then
                    right.close()
                    DAPIDEStates.right = true
                end
            end
            if bottom ~= nil then
                if bottom.is_open() then
                    bottom.close()
                    DAPIDEStates.bottom = true
                end
            end
        end
    end
end

local function restoreNvimIDEPanels()
    if pcall(require, 'ide') then
        local ws = require('ide.workspaces.workspace_registry').get_workspace(vim.api.nvim_get_current_tabpage())
        if ws ~= nil then
            local left = ws.panels[require('ide.panels.panel').PANEL_POS_LEFT]
            local right = ws.panels[require('ide.panels.panel').PANEL_POS_RIGHT]
            local bottom = ws.panels[require('ide.panels.panel').PANEL_POS_BOTTOM]
            if left ~= nil then
                if DAPIDEStates.left then
                    left.open()
                end
            end
            if right ~= nil then
                if DAPIDEStates.right then
                    right.open()
                end
            end
            if bottom ~= nil then
                if DAPIDEStates.bottom then
                    bottom.open()
                end
            end
        end
    end
end

Util.dapStart = function()
    local dapui = require("dapui")
    closeNvimIDEPanels()
    dapui.open()
end

Util.dapStop = function()
    local dap = require('dap')
    local dapui = require('dapui')

    if dap.session() then
        dap.disconnect()
    end

    dap.close()
    dapui.close({})
    restoreNvimIDEPanels()
end

local function hexToRgb(hex_str)
    if hex_str == "none" then
        return
    end

    local hex = "[abcdef0-9][abcdef0-9]"
    local pat = "^#(" .. hex .. ")(" .. hex .. ")(" .. hex .. ")$"
    hex_str = string.lower(hex_str)

    assert(string.find(hex_str, pat) ~= nil, "hex_to_rgb: invalid hex_str: " .. tostring(hex_str))

    local r, g, b = string.match(hex_str, pat)
    return { tonumber(r, 16), tonumber(g, 16), tonumber(b, 16) }
end

local function blend(fg, bg, alpha)
    bg = hexToRgb(bg)
    fg = hexToRgb(fg)

    local blendChannel = function(i)
        local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
        return math.floor(math.min(math.max(0, ret), 255) + 0.5)
    end

    return string.format("#%02X%02X%02X", blendChannel(1), blendChannel(2), blendChannel(3))
end

Util.darken = function(hex, amount)
    return blend(hex, "#000000", math.abs(amount))
end

Util.lighten = function(hex, amount)
    return blend(hex, "#ffffff", math.abs(amount))
end

Util.getColor = function(group, attr)
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), attr)
end

Util.inspect = function(vars, ...)
    print(vim.inspect(vars, ...))
end

Util.win_focus_bottom = function()
    local currentWin = vim.fn.winnr()

    if currentWin == vim.fn.winnr('j') then
        vim.cmd("silent !tmux select-pane -D")
        return
    end

    vim.cmd("wincmd j")
end

Util.win_focus_top = function()
    local currentWin = vim.fn.winnr()

    if currentWin == vim.fn.winnr('k') then
        vim.cmd("silent !tmux select-pane -U")
        return
    end

    vim.cmd("wincmd k")
end

Util.win_focus_left = function()
    local currentWin = vim.fn.winnr()

    if currentWin == vim.fn.winnr('h') then
        vim.cmd("silent !tmux select-pane -L")
        return
    end

    vim.cmd("wincmd h")
end

Util.win_focus_right = function()
    local currentWin = vim.fn.winnr()

    if currentWin ~= vim.fn.winnr('l') then
        vim.cmd("wincmd l")
        return
    end

    vim.cmd("silent !tmux select-pane -R")
end

local function getNeighbors()
    local ret = {
        top = false,
        bottom = false,
        left = false,
        right = false,
    }

    if len(vim.api.nvim_list_wins()) == 1 then
        return ret
    end

    local currentWin = vim.fn.winnr()

    if currentWin ~= vim.fn.winnr('k') then
        ret.top = true
    end

    if currentWin ~= vim.fn.winnr('j') then
        ret.bottom = true
    end

    if currentWin ~= vim.fn.winnr('h') then
        ret.left = true
    end

    if currentWin ~= vim.fn.winnr('l') then
        ret.right = true
    end

    return ret
end

Util.win_resize = function(dir)
    local n = getNeighbors()

    -- I wish lua had a switch case
    if dir == "top" then
        -- middle split
        if n.top and n.bottom then
            vim.cmd("res +1")
            return
        end

        -- top split with bottom neighbor
        if not n.top and n.bottom then
            vim.cmd(vim.fn.winnr("j") .. "res +1")
            return
        end

        -- bottom split with top neighbor
        if n.top and not n.bottom then
            vim.cmd(vim.fn.winnr("k") .. "res -1")
            return
        end

        -- only horizontal window, attempt tmux resize
        if not n.top and not n.bottom then
            vim.cmd("silent !tmux resize-pane -U 1")
        end
    end

    if dir == "bottom" then
        -- middle split
        if n.top and n.bottom then
            vim.cmd(vim.fn.winnr("k") .. "res +1")
            vim.cmd("res -1")
            return
        end

        -- top split with bottom neighbor
        if not n.top and n.bottom then
            vim.cmd(vim.fn.winnr("k") .. "res +1")
            return
        end

        -- bottom split with top neighbor
        if n.top and not n.bottom then
            vim.cmd(vim.fn.winnr("j") .. "res -1")
            return
        end

        -- only horizontal window, attempt tmux resize
        if not n.top and not n.bottom then
            vim.cmd("silent !tmux resize-pane -D 1")
        end
    end

    if dir == "left" then
        if not n.left and n.right or
            n.left and n.right then
            vim.cmd("vert res -1")
            return
        end

        if not n.right and n.left then
            vim.cmd("vert res +1")
            return
        end

        if n.right then
            vim.cmd("vert res +1")
            return
        end


        vim.cmd("silent !tmux resize-pane -L 1")
    end

    if dir == "right" then
        -- middle
        if n.left and n.right then
            vim.cmd("vert res +1")
            return
        end

        -- left
        if not n.left and n.right then
            vim.cmd("vert res +1")
            return
        end

        -- right
        if n.left then
            vim.cmd("vert res -1")
            return
        end

        vim.cmd("silent !tmux resize-pane -R 1")
    end
end

function Float(floatWidthDivisor, floatHeightDivisor)
    -- Allow it to fail if the window can't be floated
    if len(vim.api.nvim_list_wins()) < 2
    then
        print("Float() can only be used if there is more than one window")
        return
    end

    local curWin = vim.api.nvim_get_current_win()
    local ui = vim.api.nvim_list_uis()[1]

    -- Allow the divisor to be set elsewhere
    local heightDivisor, widthDivisor = 2, 2
    if floatWidthDivisor then
        widthDivisor = floatWidthDivisor
    end
    if floatHeightDivisor then
        heightDivisor = floatHeightDivisor
    end

    local width, height = math.floor(ui.width / widthDivisor), math.floor(ui.height / heightDivisor)
    local quadBufHeight = vim.api.nvim_buf_line_count(vim.api.nvim_get_current_buf()) * 4

    -- Ensure the window is not ridiculously large for the content
    if quadBufHeight < height then
        height = quadBufHeight
    end

    local opts = {
        relative = "editor",
        width = width,
        height = height,
        col = math.floor(ui.width / 2) - math.floor(width / 2),
        row = math.floor(ui.height / 2) - math.floor(height / 2),
        anchor = "NW",
        style = "minimal",
        border = "shadow",
    }
    -- Make it purtier
    vim.cmd('highlight FloatWinCustom guibg=' .. Util.lighten(Util.getColor("Normal", "bg#"), 0.95))
    vim.api.nvim_win_set_option(curWin, "winhighlight", "Normal:FloatWinCustom")

    vim.api.nvim_win_set_config(curWin, opts)
    return curWin
end

Util.newTerm = function()
    if vim.fn.winnr('$') > 1 then
        vim.cmd("split term://" .. Vimterm)
        return
    else
        vim.cmd("vsplit term://" .. Vimterm)
        return
    end
end

local function get_file_name(include_path)
    local file_split = vim.split(vim.api.nvim_buf_get_name(0), "/")
    local file_name = file_split[len(file_split)]

    if vim.fn.bufname '%' == '' then return '' end
    if include_path == false then return file_name end

    local sep = vim.loop.os_uname().sysname == 'Windows' and '\\' or '/'
    local path_list = vim.split(string.gsub(vim.fn.expand '%:~:.:h', '%%', ''), sep)
    local file_path = ''
    for _, cur in ipairs(path_list) do
        file_path = (cur == '.' or cur == '~') and '' or
            file_path .. cur .. ' ' .. ' %*'
    end
    return file_path .. file_name
end

local function config_winbar()
    local exclude = {
        ['teminal'] = true,
        ['toggleterm'] = true,
        ['prompt'] = true,
        ['NvimTree'] = true,
        ['help'] = true,
        ['bufferlist'] = true,
        ['filetree'] = true,
        [''] = true
    }
    if vim.api.nvim_win_get_config(0).zindex or exclude[vim.bo.filetype] then
        return
    else
        local win_val = get_file_name(true)
        vim.wo.winbar = win_val
    end
end

local events = { 'BufEnter', 'BufWinEnter', 'CursorMoved' }

vim.api.nvim_create_autocmd(events, {
    pattern = '*',
    callback = function() config_winbar() end,
})

local function preview_location_callback(_, method, result)
    if result == nil or vim.tbl_isempty(result) then
        vim.lsp.log.info(method, 'No location found')
        return nil
    end
    if vim.tbl_islist(result) then
        vim.lsp.util.preview_location(result[1])
    else
        vim.lsp.util.preview_location(result)
    end
end

local function peek_definition()
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, 'textDocument/definition', params, preview_location_callback)
end

Util.printAllWindowBuffers = function()
    for _, v in ipairs(vim.api.nvim_list_wins()) do
        local name = vim.fn.bufname(vim.api.nvim_win_get_buf(v))
        if name then
            print(name)
        else
            print("unnamed")
        end
    end
end

Util.printAllWindowConfigs = function()
    for _, v in ipairs(vim.api.nvim_list_wins()) do
        Util.inspect(vim.api.nvim_win_get_config(v))
    end
end

-- stole from here:
-- https://github.com/propet/toggle-fullscreen.nvim
tF = {
    win = 0,
    toggle = true,
    previous_height = 0,
    previous_width = 0
}

function tF.toggle_fullscreen()
    tF.win = vim.api.nvim_get_current_win()

    if (tF.toggle) then
        -- Save height and width
        tF.previous_height = vim.api.nvim_win_get_height(tF.win)
        tF.previous_width = vim.api.nvim_win_get_width(tF.win)
        -- Turn window fullscreen
        vim.api.nvim_command([[execute "normal! \<C-w>|"]])
        vim.api.nvim_command([[execute "normal! \<C-w>_"]])
    else
        -- Back to previous size
        vim.api.nvim_win_set_height(tF.win, tF.previous_height)
        vim.api.nvim_win_set_width(tF.win, tF.previous_width)
    end

    -- toggle
    tF.toggle = not tF.toggle
end

-- }}}

-- Autocommands{{{

--
vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
    end
})

-- Return to previous line in file
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = { "*" },
    callback = function()
        Util.line_return()
    end
})

-- Automatically format buffers
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*" },
    callback = function()
        vim.cmd("mkview")
        vim.lsp.buf.format({
            async = false
        })
    end
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "*" },
    callback = function()
        vim.cmd("loadview")
    end
})

-- LSP - documentHighlight
-- highlight - normal
vim.api.nvim_create_autocmd("CursorHold", {
    pattern = { "<buffer>" },
    callback = function()
        local clients = vim.lsp.get_active_clients()

        if not next(clients) then
            return
        end

        if clients[1].server_capabilities.documentHighlightProvider then
            vim.lsp.buf.document_highlight()
        end
    end
})

-- highlight - insert
vim.api.nvim_create_autocmd("CursorHoldI", {
    pattern = { "<buffer>" },
    callback = function()
        local clients = vim.lsp.get_active_clients()

        if not next(clients) then
            return
        end

        if clients[1].server_capabilities.documentHighlightProvider then
            vim.lsp.buf.document_highlight()
        end
    end
})

-- highlight clear on move
vim.api.nvim_create_autocmd("CursorMoved", {
    pattern = { "<buffer>" },
    callback = function()
        vim.lsp.buf.clear_references()
    end
})

-- Deal with quickfix
-- set nobuflisted and close if last window
vim.api.nvim_create_augroup("qf", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "qf" },
    callback = function()
        vim.o.buflisted = false
    end,
    group = "qf",
})

vim.api.nvim_create_autocmd("WinEnter", {
    pattern = { "*" },
    callback = function()
        if vim.fn.winnr('$') == 1 and vim.bo.buftype == "quickfix" then
            vim.cmd [[q]]
        end
    end,
    group = "qf",
})

-- Terminal
vim.api.nvim_create_augroup("Terminal", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { "term://*", "components://Terminal:*" },
    callback = function()
        vim.cmd [[startinsert]]
    end,
    group = "Terminal",
})

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = { "*" },
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.wrap = true
        vim.opt_local.list = true
        vim.opt_local.signcolumn = "no"
    end,
    group = "Terminal",
})

vim.api.nvim_create_augroup("markdown", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { "*.md" },
    callback = function()
        vim.cmd [[setlocal spell]]
    end,
    group = "markdown",
})

-- Remove cursorline in insert mode
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
    pattern = { "*" },
    callback = function()
        vim.o.cursorline = true
    end
})

vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
    pattern = { "*" },
    callback = function()
        vim.o.cursorline = false
    end
})


-- }}}

-- Themes{{{
Themes = {}

Themes["tokyodark"] = function()
    vim.g.tokyodark_transparent_background = false
    vim.g.tokyodark_enable_italic_comment = true
    vim.g.tokyodark_enable_italic = true
    vim.g.tokyodark_color_gamma = "1.0" -- I wish everyone did this
    vim.cmd "colorscheme tokyodark"

    local splitColor = Util.darken(Util.getColor("Normal", "bg#"), 0.8)
end

if not firstRun then
    Themes.tokyodark()
end
-- }}}

-- Mappings{{{
local opts = { noremap = true, silent = true }
local map = function(mode, keys, command)
    vim.api.nvim_set_keymap(mode, keys, command, opts)
end

local exmap = function(mode, keys, command)
    vim.api.nvim_set_keymap(mode, keys, command, { noremap = true, expr = true, silent = true })
end

-- links
if vim.loop.os_uname().sysname == "Darwin" then
    map("n", "gx", 'yiW:!open <C-R>"<CR><Esc>')
elseif vim.loop.os_uname().sysname == "Linux" then
    map("n", "gx", 'yiW:!xdg-open <C-R>"<CR><Esc>')
end

-- Remap for dealing with word wrap
-- Allows for navigating through wrapped lines without skipping over the wrapped portion
exmap('n', 'k', "v:count == 0 ? 'gk' : 'k'")
exmap('n', 'j', "v:count == 0 ? 'gj' : 'j'")

exmap('v', ">", "'>gv'")
exmap('v', "<", "'<gv'")

-- Better incsearch
map("n", "n", "<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>")
map("n", "N", "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>")

-- focus tabpages
map("n", "<leader><Tab>", ':tabnext<cr>')
map("n", "<leader><S-Tab>", ':tabprevious<cr>')

-- focus buffers
map("n", "<Tab>", ':lua   Util.skipUnwantedBuffers("next")<cr>')
map("n", "<S-Tab>", ':lua Util.skipUnwantedBuffers("prev")<cr>')

-- move buffers
map("n", "<A-Tab>", '<Cmd>lua require("bufferline").move(1)<CR>')
map("n", "<A-S-Tab>", '<Cmd>lua require("bufferline").move(-1)<CR>')

-- Window/buffer stuff
map("n", "<leader>ss", "<cmd>split<cr>")
map("n", "<leader>sv", "<cmd>vsplit<cr>")

-- nohl
map("n", "<leader>hh", ":nohl<CR>")

-- Split Terminal
map("n", "<leader>St", "<cmd>vsplit term://" .. vim.o.shell)
map("n", "<leader>st", "<cmd>split term://" .. vim.o.shell)

-- Term escape
map("t", "<A-z>", "<c-\\><c-n>")

-- Close window(split)
map("n", "<A-q>", '<cmd>wincmd c<cr>')

-- Delete buffer
map("n", "<A-S-q>", ':bn<bar>:bd#<cr>')

-- Window movement
map("n", "<A-S-h>", '<cmd>WinShift left<cr>')
map("n", "<A-S-j>", '<cmd>WinShift down<cr>')
map("n", "<A-S-k>", '<cmd>WinShift up<cr>')
map("n", "<A-S-l>", '<cmd>WinShift right<cr>')


-- Navigate windows/panes incl. tmux
map("n", "<A-j>", "<cmd>lua Util.win_focus_bottom()<CR>")
map("n", "<A-k>", "<cmd>lua Util.win_focus_top()<CR>")
map("n", "<A-l>", "<cmd>lua Util.win_focus_right()<CR>")
map("n", "<A-h>", "<cmd>lua Util.win_focus_left()<CR>")

map("v", "<A-j>", "<cmd>lua Util.win_focus_bottom()<CR>")
map("v", "<A-k>", "<cmd>lua Util.win_focus_top()<CR>")
map("v", "<A-l>", "<cmd>lua Util.win_focus_right()<CR>")
map("v", "<A-h>", "<cmd>lua Util.win_focus_left()<CR>")

map("t", "<A-j>", "<cmd>lua Util.win_focus_bottom()<CR>")
map("t", "<A-k>", "<cmd>lua Util.win_focus_top()<CR>")
map("t", "<A-l>", "<cmd>lua Util.win_focus_right()<CR>")
map("t", "<A-h>", "<cmd>lua Util.win_focus_left()<CR>")

map("n", "<A-C-j>", '<cmd>lua Util.win_resize("bottom")<cr>')
map("n", "<A-C-k>", '<cmd>lua Util.win_resize("top")<cr>')
map("n", "<A-C-l>", '<cmd>lua Util.win_resize("right")<cr>')
map("n", "<A-C-h>", '<cmd>lua Util.win_resize("left")<cr>')

map("v", "<A-C-j>", '<cmd>lua Util.win_resize("bottom")<cr>')
map("v", "<A-C-k>", '<cmd>lua Util.win_resize("top")<cr>')
map("v", "<A-C-l>", '<cmd>lua Util.win_resize("right")<cr>')
map("v", "<A-C-h>", '<cmd>lua Util.win_resize("left")<cr>')

map("t", "<A-C-j>", '<cmd>lua Util.win_resize("bottom")<cr>')
map("t", "<A-C-k>", '<cmd>lua Util.win_resize("top")<cr>')
map("t", "<A-C-l>", '<cmd>lua Util.win_resize("right")<cr>')
map("t", "<A-C-h>", '<cmd>lua Util.win_resize("left")<cr>')

-- Plugin maps

-- Zen
map("n", "<leader>z", ':ZenMode<cr>')

map("n", "<leader>f", "<cmd>lua tF.toggle_fullscreen()<cr>")

-- Commentary
map("n", "<leader>cm", ':Commentary<cr><esc>')
map("v", "<leader>cm", ':Commentary<cr><esc>')

-- nvim-tree
map("n", "<leader>aa", "<cmd>Telescope file_browser path=%:p:h<CR>")
map("t", "<leader>aa", "<cmd>Telescope file_browser path=%:p:h<CR>")

map("n", "<leader>as", "<cmd>Workspace BottomPanelToggle<CR>")
map("t", "<leader>as", "<cmd>Workspace BottomPanelToggle<CR>")

map("n", "<leader>ad", "<cmd>Workspace LeftPanelToggle<CR>")
map("t", "<leader>ad", "<cmd>Workspace LeftPanelToggle<CR>")

map("n", "<leader>af", "<cmd>Workspace RightPanelToggle<CR>")

-- float toggleterm
map("n", "<leader>at", "<cmd>lua NormalTermFloat()<CR>")
map("t", "<leader>at", "<cmd>lua NormalTermFloat()<CR>")

-- Lazygit
map("n", "<leader>ag", ":lua LazygitFloat()<cr>")

-- LSP
-- map('n', '<leader>lD', '<Cmd>lua vim.lsp.buf.declaration()<CR>')
map('n', '<leader>lD', '<Cmd>lua vim.lsp.buf.definition()<CR>')
-- map('n', '<leader>ld', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
map('n', '<leader>ld', "<cmd>lua vim.lsp.buf.hover()<CR>")
map('n', '<leader>lp', "<cmd>lua peek_definition()<CR>")
map("n", '<leader>lr', "<cmd>lua require('telescope.builtin').lsp_references()<cr>")
map('n', '<leader>lo', '<cmd>lua vim.diagnostic.open_float()<CR>')
map('n', '<leader>lh', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
map('n', '<leader>ll', '<cmd>lua vim.diagnostic.goto_next()<CR>')
map('n', '<leader>ln', "<cmd>lua vim.lsp.buf.rename()<CR>")
map('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>')

-- Telescopic Johnson
map('n', '<leader>kr', "<cmd>lua require('telescope.builtin').live_grep()<cr>")
map('n', '<leader>kw', "<cmd>lua require('telescope.builtin').grep_string()<cr>")

map("n", "<leader>kF", "<cmd>lua require('telescope.builtin').find_files()<cr>")
map("n", "<leader>kg", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
map("n", "<leader>kf", "<cmd>lua require('telescope.builtin').buffers()<cr>")
map("n", "<leader>kh", "<cmd>lua require('telescope.builtin').help_tags()<cr>")

map("n", "<leader>kF", "<cmd>lua require('telescope.builtin').quickfix()<cr>")
map('n', '<leader>kL', "<cmd>lua require('telescope.builtin').loclist()<cr>")

map('n', '<leader>kp', "<cmd>Telescope projects<cr>")

-- Debug maps
map("n", "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<CR>")
map("n", "<leader>di", "<cmd>lua require('dap').step_into()<CR>")
map("n", "<leader>dn", "<cmd>lua require('dap').step_over()<CR>")
map("n", "<leader>do", "<cmd>lua require('dap').step_out()<CR>")
map("n", "<leader>du", "<cmd>lua require('dap').up()<CR>")
map("n", "<leader>drn", "<cmd>lua require('dap').run_to_cursor()<CR>")
map("n", "<leader>dd", "<cmd>lua require('dap').down()<CR>")
map("n", "<leader>dc", "<cmd>lua require('dap').continue()<CR>")
map("n", "<leader>ds", "<cmd>lua Util.dapStart()<cr>")
map("n", "<leader>dS", "<cmd>lua Util.dapStop()<cr>")

-- term split like any ol TWM
map("n", "<M-CR>", "<cmd>lua Util.newTerm()<cr>")
map("t", "<M-CR>", "<cmd>lua Util.newTerm()<cr>")
map("i", "<M-CR>", "<cmd>lua Util.newTerm()<cr>")

-- refactoring.nvim
map("v", "<leader>re", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]])
map("v", "<leader>rf", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]])
map("v", "<leader>rv", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]])
map("v", "<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]])

map("n", "<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]])
map("n", "<leader>rbf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]])

map("n", "<leader>ri", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]])

-- Meta LSP stuff
map("n", "<leader>Li", "<cmd>LspInstallInfo<CR>")
map("n", "<leader>Lr", "<cmd>LspRestart<CR>")
map("n", "<leader>Ls", "<cmd>LspStart<CR>")
map("n", "<leader>LS", "<cmd>LspStop<CR>")

-- Fugitive
map("n", "<leader>gs", "<cmd>vert Git<cr>")
map("n", "<leader>gc", "<cmd>Git commit<cr>")
map("n", "<leader>gp", "<cmd>Git push<cr>")
map("n", "<leader>gl", "<cmd>Gclog<cr>")

-- gitsigns
map("v", "<leader>hs", ":Gitsigns stage_hunk<cr>")
map("v", "<leader>hu", ":Gitsigns reset_hunk<cr>")

map("n", "<leader>hc", ":Git commit<cr>")

-- Sessions
map("n", "<leader>Ss", "<cmd>lua require('session-tabs').saveSession()<CR>")
map("n", "<leader>Sl", "<cmd>lua require('session-tabs').selectSession()<CR>")
map("n", "<leader>Sd", "<cmd>lua require('session-tabs').deleteSession()<CR>")

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
-- }}}
