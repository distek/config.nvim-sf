-- Bootstrap pre {{{
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	is_bootstrap = true
	vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
	vim.cmd([[packadd packer.nvim]])
end

local packer_group = vim.api.nvim_create_augroup("Packer", { clear = true })
vim.api.nvim_create_autocmd("VimLeavePre", {
	command = "source <afile> | PackerCompile",
	group = packer_group,
	pattern = vim.fn.expand("$MYVIMRC"),
})
-- }}}

-- Plugin list{{{
require("packer").startup(function(use)
	-- Package manager
	use({ "wbthomason/packer.nvim" })

	-- Treesitter
	use({ "nvim-treesitter/nvim-treesitter" })
	use({ "nvim-treesitter/playground" })
	use({ "nvim-treesitter/nvim-treesitter-context" })
	use({ "nvim-treesitter/nvim-treesitter-textobjects" })
	use({ "p00f/nvim-ts-rainbow" })
	use({ "windwp/nvim-ts-autotag" })

	-- Layout/UI
	use({ "nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons", opt = true } })
	use({ "kevinhwang91/nvim-hlslens" })
	use({ "folke/which-key.nvim" })
	use({ "kwkarlwang/bufresize.nvim" })
	use({ "lukas-reineke/indent-blankline.nvim" })
	use({ "lewis6991/gitsigns.nvim" })
	use({ "ldelossa/nvim-ide" })
	use({ "tiagovla/scope.nvim" })
	use({ "sindrets/winshift.nvim" })
	use({ "folke/zen-mode.nvim" })
	use({ "folke/twilight.nvim" })
	use({ "distek/session-tabs.nvim" })
	use({ "kyazdani42/nvim-web-devicons" })
	use({
		"utilyre/barbecue.nvim",
		requires = {
			"neovim/nvim-lspconfig",
			"smiteshp/nvim-navic",
			"kyazdani42/nvim-web-devicons",
		},
	})
	use({ "smiteshp/nvim-navic", requires = "neovim/nvim-lspconfig" })
	use({
		"distek/bufferline.nvim",
		branch = "tabpage-rename",
		requires = { "nvim-tree/nvim-web-devicons", opt = false },
	})

	-- Filetypes
	use({ "chrisbra/csv.vim" })
	use({ "rust-lang/rust.vim" })
	use({ "sirtaj/vim-openscad" })
	use({ "plasticboy/vim-markdown" })
	use({ "ray-x/go.nvim" })

	-- lsp
	use({ "neovim/nvim-lspconfig" })
	use({ "williamboman/mason.nvim" })
	use({ "williamboman/mason-lspconfig.nvim" })
	use({ "jayp0521/mason-null-ls.nvim", requires = { "jose-elias-alvarez/null-ls.nvim" } })
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-look",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-calc",
			"hrsh7th/cmp-nvim-lua",
			"uga-rosa/cmp-dictionary",
			"hrsh7th/vim-vsnip",
			"rafamadriz/friendly-snippets",
			"honza/vim-snippets",
		},
	})
	use({ "onsails/lspkind-nvim" })
	use({ "dnlhc/glance.nvim" })

	-- dap
	use({ "mfussenegger/nvim-dap" })
	use({ "rcarriga/nvim-dap-ui" })
	use({ "theHamsta/nvim-dap-virtual-text" })
	use({ "mfussenegger/nvim-dap-python" })

	-- telescope
	use({ "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } })
	use({ "nvim-telescope/telescope-file-browser.nvim" })
	use({ "nvim-telescope/telescope-ui-select.nvim" })
	use({ "nvim-telescope/telescope-dap.nvim" })
	use({ "LinArcX/telescope-command-palette.nvim" })

	-- misc
	use({ "jakewvincent/mkdnflow.nvim" })
	use({ "tpope/vim-commentary" })
	use({ "ThePrimeagen/refactoring.nvim", requires = {
		{ "nvim-lua/plenary.nvim" },
	} })
	use({ "windwp/nvim-autopairs" })
	use({ "tpope/vim-fugitive" })
	use({ "ThePrimeagen/git-worktree.nvim" })
	use({ "powerman/vim-plugin-AnsiEsc" })
	use({ "norcalli/nvim-colorizer.lua" })
	use({ "distek/aftermath.nvim" })
	use({ "nvim-zh/colorful-winsep.nvim" })
	use({ "famiu/bufdelete.nvim" })

	-- Themes
	use({ "tiagovla/tokyodark.nvim" })
	use({ "Shatur/neovim-ayu" })

	if is_bootstrap then
		require("packer").sync()
	end
end)
-- }}}

-- Bootstrap post {{{
if is_bootstrap then
	print("==================================")
	print("    Plugins are being installed")
	print("    Wait until Packer completes,")
	print("       then restart nvim")
	print("==================================")
	return true
end
-- }}}

-- Plugin Development {{{
-- vim.opt.runtimepath:append("~/Programming/neovim-plugs/session-tabs.nvim")
-- vim.opt.runtimepath:append("~/Programming/neovim-plugs/line.nvim")
-- vim.opt.runtimepath:append("~/git-clones/nvim-ide")
-- vim.opt.runtimepath:append("~/git-clones/bufferline.nvim")
-- }}}
return false
