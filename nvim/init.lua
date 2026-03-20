-- Set noshellshash
vim.opt.shellslash = false

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
		}, true, {})
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Add treesitter parser path to runtimepath
vim.opt.rtp:prepend((vim.fn.stdpath("data") .. "/site"):gsub("/", "\\"))

-- Leader key must be set BEFORE lazy loads plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Bootstrap LazyVim
require("lazy").setup({
	spec = {
		-- Load LazyVim and its default plugins
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		-- Your plugins (everything in lua/plugins/)
		{ import = "plugins" },
	},
	defaults = {
		lazy = false,
		version = false, -- always use latest git commit
	},
	install = { colorscheme = { "rider", "habamax" } },
	checker = { enabled = true }, -- auto-check for plugin updates
	performance = {
		rtp = {
			-- Disable some built-in plugins we don't need
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
