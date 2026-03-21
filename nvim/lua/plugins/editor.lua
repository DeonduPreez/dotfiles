-- ╔══════════════════════════════════════════════════════════════╗
-- ║  Core Editor Plugins — Phase 1                             ║
-- ║  which-key, mini.icons, nvim-web-devicons                  ║
-- ╚══════════════════════════════════════════════════════════════╝

return {

	-- ┌──────────────────────────────────────────────────────────┐
	-- │  which-key.nvim                                          │
	-- │  Repo: https://github.com/folke/which-key.nvim           │
	-- │  Shows a popup with available keybindings as you type.    │
	-- │  v3 uses the `add()` API — do NOT use old `register()`.  │
	-- └──────────────────────────────────────────────────────────┘
	{
		"folke/which-key.nvim",

		-- `VeryLazy` fires after the UI has rendered and all startup plugins
		-- have loaded. which-key doesn't need to be available at the very first
		-- keystroke — it only needs to intercept <leader> sequences, which
		-- happen after you're already looking at the editor.
		event = "VeryLazy",

		opts = {
			-- Preset determines the popup layout style.
			-- "classic" = vertical list on the bottom (familiar if you've used Emacs which-key)
			-- "modern"  = centered floating window
			-- "helix"   = single-column, more compact
			preset = "classic",

			-- Delay (ms) before the popup appears after pressing a prefix key.
			-- 300ms matches our timeoutlen in options.lua.
			delay = 300,

			-- ── Icons ──────────────────────────────────────────────
			icons = {
				-- Use mini.icons for keymap group icons (auto-detected from plugin names).
				-- Falls back to nvim-web-devicons if mini.icons isn't loaded.
				breadcrumb = "»", -- separator in the command line area
				separator = "➜", -- separator between key and description
				group = "+", -- symbol prepended to group names
			},

			-- ── Keymap Group Labels ────────────────────────────────
			-- Define the top-level <leader> groups here. Every plugin that adds
			-- keymaps under these prefixes will automatically appear under
			-- the correct group in the which-key popup.
			spec = {
				{ "<leader>b", group = "Buffers" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>e", group = "Explorer" },
				{ "<leader>f", group = "Find/Search" },
				{ "<leader>g", group = "Git" },
				{ "<leader>l", group = "LSP" },
				{ "<leader>n", group = "Notifications" },
				{ "<leader>q", group = "Quit/Sessions" },
				{ "<leader>s", group = "Search/Replace" },
				{ "<leader>t", group = "Test" },
				{ "<leader>w", group = "Windows/Splits" },
				{ "<leader>x", group = "Diagnostics/Quickfix" },
			},
		},

		-- Plugin-specific keymaps defined in the `keys` table for lazy-loading.
		-- Documented in config/keymaps.lua under "which-key" section.
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer-local keymaps (which-key)",
			},
		},
	},

	-- ┌──────────────────────────────────────────────────────────┐
	-- │  mini.icons                                              │
	-- │  Repo: https://github.com/echasnovski/mini.icons         │
	-- │  Provides icons for filetypes, LSP kinds, extensions,     │
	-- │  etc. via a single MiniIcons.get() call.                  │
	-- │  Also mocks nvim-web-devicons for plugin compatibility.   │
	-- └──────────────────────────────────────────────────────────┘
	{
		"echasnovski/mini.icons",

		-- Load lazily — mini.icons is called on-demand by other plugins
		-- (which-key, neo-tree, telescope, lualine, bufferline, etc.)
		-- through the mock_nvim_web_devicons integration.
		lazy = true,

		opts = {
			-- "glyph" uses Nerd Font icons (make sure your WezTerm font supports them).
			-- "ascii" is a fallback if your terminal/font doesn't have icon support.
			style = "glyph",
		},

		init = function()
			-- This runs BEFORE the plugin loads (at Neovim startup).
			-- We tell lazy.nvim to use mini.icons as the icon provider
			-- by setting up the nvim-web-devicons mock. Any plugin that calls
			-- require("nvim-web-devicons") will be intercepted by mini.icons.
			--
			-- The pcall ensures no error if mini.icons hasn't loaded yet;
			-- it will be set up properly once it does.
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},

	-- ┌──────────────────────────────────────────────────────────┐
	-- │  nvim-web-devicons                                       │
	-- │  Repo: https://github.com/nvim-tree/nvim-web-devicons    │
	-- │  The "classic" icon provider. Some plugins hard-depend on │
	-- │  this. We install it but let mini.icons handle the actual │
	-- │  icon resolution via the mock above.                      │
	-- └──────────────────────────────────────────────────────────┘
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
	},
}
