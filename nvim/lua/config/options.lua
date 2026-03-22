-- ╔══════════════════════════════════════════════════════════════╗
-- ║  Core Neovim Options                                       ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ── Leader Keys ──────────────────────────────────────────────
-- MUST be set before lazy.nvim loads so all plugin keymaps bind correctly.
-- Space is the most ergonomic leader for modal editing.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ── Line Numbers ─────────────────────────────────────────────
-- Absolute number on the current line + relative numbers above/below.
-- This gives you the best of both worlds: you can see your position
-- in the file AND quickly calculate motion counts (e.g., 5j, 12k).
vim.opt.number = true
vim.opt.relativenumber = true

-- ── Indentation ──────────────────────────────────────────────
-- Use spaces instead of tabs; 4-space indent matches .NET conventions.
-- TypeScript/Angular files can override this via autocmds or editorconfig.
vim.opt.tabstop = 4 -- Visual width of a \t character
vim.opt.shiftwidth = 4 -- Spaces used for each step of (auto)indent
vim.opt.softtabstop = 4 -- spaces inserted when pressing <Tab>
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.smartindent = true -- auto-indent new lines based on syntax

-- ── Search ───────────────────────────────────────────────────
vim.opt.ignorecase = true -- case-insensitive search by default
vim.opt.smartcase = true -- ...unless you type an uppercase letter
vim.opt.hlsearch = true -- highlight all matches
vim.opt.incsearch = true -- show matches as you type

-- ── Appearance ───────────────────────────────────────────────
vim.opt.termguicolors = true -- 24-bit RGB color in the TUI (required by most themes)
vim.opt.signcolumn = "yes" -- always show the sign column (prevents layout shift from diagnostics/git)
vim.opt.cursorline = true -- highlight the line the cursor is on
vim.opt.wrap = false -- don't wrap long lines (code readability)
vim.opt.scrolloff = 8 -- keep 8 lines visible above/below cursor when scrolling
vim.opt.sidescrolloff = 8 -- keep 8 columns visible left/right of cursor
vim.opt.colorcolumn = "120" -- visual guide at column 120 (common .NET line length)
vim.opt.showmode = false -- hide "-- INSERT --" etc (lualine will show mode)

-- ── Splits ───────────────────────────────────────────────────
-- New splits open to the right/below, matching the JetBrains default.
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ── Undo / Backup ────────────────────────────────────────────
-- Persist undo history across sessions. No swap/backup files since
-- we use git for everything.
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false

-- ── Completion ───────────────────────────────────────────────
-- Completion menu behavior: show menu even for 1 match, don't auto-select.
-- blink.cmp will build on this in Phase 5.
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- ── Miscellaneous ─────────────────────────────────────────────────────
vim.opt.mouse = "a" -- enable mouse in all modes
vim.opt.updatetime = 250 -- faster CursorHold events (used by gitsigns, hover, etc.)
vim.opt.timeoutlen = 300 -- time (ms) to wait for a mapped sequence (which-key popup delay)
vim.opt.conceallevel = 0 -- show text normally (no concealing in markdown etc.)

-- ── Clipboard ─────────────────────────────────────────
-- In WSL, the system clipboard is accessed via win32yank.exe or
-- the built-in WSL clipboard provider. Neovim 0.10+ auto-detects
-- WSL and uses wl-copy/wl-paste or win32yank. If you have issues,
-- install win32yank.exe on the Windows PATH and it will be found
-- from WSL automatically.
vim.opt.clipboard = "unnamedplus"

-- ── Floating Window Borders ──────────────────────────────────────────
-- New in Neovim 0.11: sets the default border style for ALL floating
-- windows (LSP hover, diagnostics float, which-key, etc.).
-- Previously you had to configure borders per-plugin; this is the global default.
-- Options: "none", "single", "double", "rounded", "solid", "shadow"
vim.opt.winborder = "rounded"

-- ── Diagnostics ──────────────────────────────────────────────
-- Neovim 0.11 changed virtual_text from opt-out to opt-in.
-- Without this, inline diagnostic messages won't appear.
-- Docs: :h vim.diagnostic.config()
vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
	underline = true,
	update_in_insert = false,
	float = {
		border = "rounded",
		source = true,
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
})

-- ── Fill Characters ──────────────────────────────────────────
-- Cleaner look for folds and end-of-buffer (no ~ tildes).
-- vim.opt.fillchars = {
-- fold = " ",
-- foldopen = "",
-- foldclose = "",
-- foldsep = " ",
-- eob = " ", -- suppress ~ at end of buffer
-- }
