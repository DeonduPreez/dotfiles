-- ╔══════════════════════════════════════════════════════════════╗
-- ║  Colorscheme — rider.nvim                                  ║
-- ║  Repo: https://github.com/tomstolarczuk/rider.nvim         ║
-- ║  Fork of kanagawa.nvim recolored to match JetBrains Rider  ║
-- ╚══════════════════════════════════════════════════════════════╝

return {
	"tomstolarczuk/rider.nvim",

	-- `lazy = false` means load immediately at startup (not lazy-loaded).
	-- Colorschemes MUST load early — before any UI renders — otherwise
	-- you'll see a flash of the default theme.
	lazy = false,

	-- `priority = 1000` ensures this loads before any other plugin.
	-- The default priority is 50; 1000 puts it at the front of the queue.
	priority = 1000,

	config = function()
		require("rider").setup({
			-- Compile highlight groups to Lua bytecode for faster startup.
			-- Run :RiderCompile after changing any config below.
			-- TODO : When happy with config, set this to true. Then we have to run :RiderCompile every time we change anything
			compile = false,

			-- Underline style for spell/diagnostics (requires terminal support).
			undercurl = true,

			-- Syntax highlighting styles — match the Rider look:
			commentStyle = { italic = true }, -- italicize comments (Rider default)
			keywordStyle = { italic = true }, -- italicize keywords (if/else/return)
			statementStyle = { bold = true }, -- bold statements

			-- Transparent background: set to true if your WezTerm has a
			-- background image or transparency effect you want to show through.
			transparent = true,

			-- Dim inactive windows (like Rider's focus-follows-tab behavior).
			-- Gives a visual cue which split is active.
			dimInactive = true,

			-- Use the colorscheme's terminal colors (for :terminal buffers).
			terminalColors = true,

			-- Color overrides — empty tables mean "use the defaults."
			-- If you want to tweak specific colors later, add them here.
			-- See :h rider.nvim or the kanagawa docs for the palette keys.
			colors = {
				palette = {},
				theme = {
					rider = {},
					all = {},
				},
			},

			-- Per-highlight-group overrides for transparency compatibility.
			-- When transparent = true, some UI elements lose their background
			-- and become hard to read against the glass. These overrides add
			-- subtle semi-transparent backgrounds back where needed.
			overrides = function(colors)
				return {
					-- Floating windows (which-key, lazy.nvim UI, LSP hover, etc.)
					-- need a solid-ish background so they're readable over glass.
					NormalFloat = { bg = colors.palette.sumiInk2 },
					FloatBorder = { bg = "NONE" },
					FloatTitle = { bg = colors.palette.sumiInk2 },

					-- Inactive windows: NormalNC (Non-Current) applies to every
					-- unfocused split. sumiInk2 (#1a1a22) adds a dark tint that's
					-- still partially transparent (WezTerm's Acrylic bleeds through)
					-- but noticeably darker than the active window's fully clear bg.
					-- This gives you the Rider-style "active tab stands out" feel.
					NormalNC = { bg = colors.palette.sumiInk2 },

					-- Cursorline: a subtle highlight so you can track your cursor
					-- against the transparent background.
					CursorLine = { bg = colors.palette.sumiInk3 },

					-- Sign column and fold column: match the transparent bg
					-- so they don't create a visible seam on the left edge.
					SignColumn = { bg = "NONE" },
					FoldColumn = { bg = "NONE" },

					-- Line numbers: keep them readable but not heavy.
					LineNr = { fg = colors.palette.fujiGray, bg = "NONE" },
					CursorLineNr = { bg = colors.palette.sumiInk3 },

					-- Status line: give it a subtle background so it's distinct
					-- from the editor area. This will be replaced by lualine in
					-- Phase 2 but keeps things clean until then.
					StatusLine = { bg = colors.palette.sumiInk2 },
					StatusLineNC = { bg = colors.palette.sumiInk1 },

					-- Popup menu (completion, cmdline suggestions):
					Pmenu = { bg = colors.palette.sumiInk2 },
					PmenuSel = { bg = colors.palette.sumiInk4 },
					PmenuSbar = { bg = colors.palette.sumiInk2 },
					PmenuThumb = { bg = colors.palette.sumiInk4 },

					-- Vertical split separator: thin subtle line, not a thick bar.
					WinSeparator = { fg = colors.palette.sumiInk4, bg = "NONE" },
				}
			end,
		})

		-- Apply the colorscheme. This must happen AFTER setup().
		vim.cmd.colorscheme("rider")
	end,
}
