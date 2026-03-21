-- ╔══════════════════════════════════════════════════════════════╗
-- ║  lazy.nvim Bootstrap & Setup                               ║
-- ║  Docs: https://lazy.folke.io/installation                  ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ── Bootstrap ────────────────────────────────────────────────
-- Clone lazy.nvim into the Neovim data directory if it's not there.
-- This runs ONCE on a fresh machine — after that, lazy.nvim manages itself.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none", -- partial clone (don't download full blob history)
		"--branch=stable", -- pin to latest stable release tag
		lazyrepo,
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

-- Prepend lazy.nvim to the runtime path so `require("lazy")` works.
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- `spec` tells lazy.nvim where to find plugin spec files.
	-- `{ import = "plugins" }` auto-imports every .lua file in lua/plugins/.
	-- Each file returns a table (or list of tables) that is a lazy.nvim spec.
	spec = {
		{ import = "plugins" },
	},

	-- When installing plugins for the first time, use this colorscheme
	-- so there's something reasonable before our theme loads.
	install = {
		colorscheme = { "rider", "habamax" },
	},

	-- Automatically check for plugin updates (shows a notification).
	-- You still have to manually run `:Lazy update` to apply them.
	checker = {
		enabled = true,
		notify = false, -- don't spam notifications on every check
	},

	-- Detect when a plugin spec file changes and auto-reload.
	change_detection = {
		-- notify = false, -- suppress "reloading..." messages
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
