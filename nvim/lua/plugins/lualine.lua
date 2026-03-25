-- Eviline config for lualine
-- https://github.com/nvim-lualine/lualine.nvim/blob/master/examples/evil_lualine.lua

return {
-- ┌──────────────────────────────────────────────────────────┐
	-- │  lualine.nvim                                            │
	-- │  Repo: https://github.com/nvim-lualine/lualine.nvim      │
	-- │  Docs: :h lualine.txt                                    │
	-- │  A fast statusline written in Lua. Replaces the default  │
	-- │  statusline with mode, branch, diagnostics, file info.   │
	-- └──────────────────────────────────────────────────────────┘
	{
		"nvim-lualine/lualine.nvim",

		-- Dependencies: needs icons for filetype display.
		-- mini.icons mocks nvim-web-devicons (set up in Phase 1),
		-- so lualine gets icons automatically.
		dependencies = { "nvim-tree/nvim-web-devicons" },

		-- Load after UI renders. Lualine doesn't need to be there for
		-- the very first frame — VeryLazy fires after startup completes.
		event = "VeryLazy",

		-- We use `opts` (not `config`) so lazy.nvim auto-calls
		-- require("lualine").setup(opts). Keeps things declarative.
		opts = {
			options = {
				-- "auto" picks the closest match to your active colorscheme.
				-- rider.nvim is a kanagawa fork, so this will use kanagawa's
				-- lualine theme (dark purples, muted blues — fits the vibe).
				theme = "auto",

				-- Single statusline at the bottom of the editor, shared across
				-- all splits. This is the modern default and avoids a per-window
				-- statusline which looks noisy with transparent backgrounds.
				globalstatus = true,

				-- Section separators: the angled powerline arrows.
				-- These use Nerd Font glyphs (your JetBrainsMono NF has them).
				-- left/right refers to which side of the section the separator sits.
				section_separators = { left = "", right = "" },

				-- Component separators: the small pipe between items *within* a section.
				-- Using the thin powerline arrows for a subtler look.
				component_separators = { left = "", right = "" },

				-- Don't render the statusline on these filetypes.
				-- "dashboard" is for a future snacks.nvim dashboard (Phase 8).
				-- "alpha" is another common dashboard plugin (safety net).
				disabled_filetypes = {
					statusline = { "dashboard", "alpha", "snacks_dashboard" },
				},
			},

			-- ── Sections ─────────────────────────────────────────
			-- lualine has 6 sections: a/b/c on the left, x/y/z on the right.
			--
			--  ┌───┬─────┬──────────────────────────────┬──────┬──────┬───┐
			--  │ a │  b  │             c                │  x   │  y   │ z │
			--  └───┴─────┴──────────────────────────────┴──────┴──────┴───┘
			--
			-- a = mode (NORMAL/INSERT/VISUAL/etc.)
			-- b = git branch + diff stats + diagnostics
			-- c = filename (with path context)
			-- x = encoding + filetype (right side info)
			-- y = progress through file (percentage)
			-- z = cursor location (line:column)
			sections = {
				lualine_a = { "mode" },

				lualine_b = {
					-- Git branch name (e.g., "main", "feature/xyz").
					-- Only shows when inside a git repo.
					"branch",

					-- Git diff: shows +added, ~modified, -removed line counts.
					-- Uses gitsigns data when available (Phase 7), falls back to git cli.
					{
						"diff",
						symbols = {
							added = " ", -- nerd font icon
							modified = " ",
							removed = " ",
						},
					},

					-- LSP diagnostics summary (error/warn/info/hint counts).
					-- Won't show anything until LSP is configured in Phase 5,
					-- but the component is ready and waiting.
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = {
							error = " ",
							warn = " ",
							info = " ",
							hint = " 󰛨",
						},
					},
				},

				lualine_c = {
					-- Show the filename with relative path from project root.
					-- `path = 1` means relative path (not just the filename).
					-- This helps distinguish files with the same name in different dirs.
					{
						"filename",
						path = 1, -- 0=filename, 1=relative, 2=absolute, 3=absolute with ~ for home
						symbols = {
							modified = " ●", -- indicator for unsaved changes
							readonly = " ", -- lock icon for readonly files
							unnamed = "[No Name]",
							newfile = "[New]",
						},
					},
				},

				lualine_x = {
					function()
						return require("auto-session.lib").current_session_name(true)
					end,

					-- Show encoding only if it's something unusual (not utf-8).
					-- Most files are utf-8 so this saves space in the common case.
					{
						"encoding",
						cond = function()
							return vim.bo.fileencoding ~= "utf-8"
						end,
					},

					-- Show file format only if it's not unix (i.e., show on windows/dos files).
					-- In WSL everything should be unix, so this is a safety net.
					{
						"fileformat",
						cond = function()
							return vim.bo.fileformat ~= "unix"
						end,
					},

					-- Filetype with icon (e.g., " lua", " typescript").
					"filetype",
				},

				lualine_y = {
					-- Percentage through the file (e.g., "42%").
					"progress",
				},

				lualine_z = {
					-- Cursor position as line:column (e.g., "128:15").
					"location",
				},
			},

			-- Inactive windows get a minimal statusline (just filename + location).
			-- With globalstatus = true, these rarely show — only in edge cases
			-- like floating windows or when Neovim falls back to local statuslines.
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},

			-- Extensions customize the statusline for specific plugin windows.
			-- "neo-tree" simplifies the statusline when neo-tree is focused (Phase 3).
			-- "lazy" shows a clean statusline in the lazy.nvim UI.
			extensions = { "neo-tree", "lazy", "quickfix" },
		},
	},
}
