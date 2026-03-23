-- ╔══════════════════════════════════════════════════════════════╗
-- ║  Keymaps — Single Source of Truth                          ║
-- ║                                                            ║
-- ║  NON-PLUGIN keymaps live here directly.                    ║
-- ║  PLUGIN-SPECIFIC keymaps are defined in the plugin spec's  ║
-- ║  `keys` table (for lazy-loading), but are DOCUMENTED here  ║
-- ║  in comment blocks so you can see ALL bindings in one file.║
-- ╚══════════════════════════════════════════════════════════════╝

local map = vim.keymap.set

-- ═══════════════════════════════════════════════════════════════
-- GENERAL (non-plugin)
-- ═══════════════════════════════════════════════════════════════

-- Clear search highlighting with <Esc> in normal mode.
-- Pressing Esc already exits insert mode; in normal mode it does nothing
-- useful by default, so we repurpose it.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- ── Splits / Windows (<leader>w) ────────────────────────────
map("n", "<leader>wv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>ws", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>we", "<C-w>=", { desc = "Equalize splits" })
map("n", "<leader>wq", "<cmd>close<CR>", { desc = "Close split" })

-- Better window navigation with Ctrl+hjkl (instead of Ctrl-W then h/j/k/l).
-- Saves one keystroke every time you switch splits.
map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to below split" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to above split" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- Resize splits with Ctrl+Arrow keys.
-- More intuitive than the default Ctrl-W +/- / < / > keybinds.
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Move selected lines up/down in visual mode.
-- Also re-selects after moving so you can keep nudging.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when scrolling half-page.
map("n", "<C-d>", "<C-d>zz", { desc = "Page Down while keeping the cursor centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Page Up while keeping the cursor centered" })

-- Keep cursor centered when jumping to search results.
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })

-- Paste over selection without losing the paste register.
-- By default, pasting over selected text puts the replaced text into the
-- register, so your next paste is the text you just replaced. This fixes that.
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- Delete without yanking (send to black hole register).
map({ "n", "v" }, "<leader>D", [["_d]], { desc = "Delete without yanking" })

-- Better indenting: re-selects the visual selection after indent/dedent.
map("v", "<", "<gv", { desc = "Dedent and re-select" })
map("v", ">", ">gv", { desc = "Indent and re-select" })

-- ── Boolean toggling (<leader>t) ─────────────────────────────
-- This can actually be extended to be more than boolean toggling.
-- <leader>tb — Toggle boolean word under cursor
--   Logic lives in: lua/helpers/toggle.lua  →  M.toggle_bool()
local toggle = require("helpers.toggle")
map("n", "<leader>tb", toggle.toggle_bool, {
	desc = "Toggle boolean",
	noremap = true,
	silent = true,
})

local wsl = require("helpers.wsl-helper")
map("n", "<C-O>", function()
	wsl.open_in_explorer()
end, { desc = "Open in file explorer" })

-- ── Quit / Sessions (<leader>q) ─────────────────────────────
-- These mappings are disabled because I don't want to quit so easily. I want quiting to be deliberate with :qa or :qw
-- map("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit all" })
-- map("n", "<leader>qw", "<cmd>wqa<CR>", { desc = "Write and quit all" })

-- ═══════════════════════════════════════════════════════════════
-- PLUGIN KEYMAPS REFERENCE
-- (actual bindings are in each plugin spec's `keys` table)
-- ═══════════════════════════════════════════════════════════════

-- ── which-key (plugins/editor.lua) ──────────────────────────
-- <leader>?     → Show buffer-local keymaps

-- ── [Phase 2] Buffers (<leader>b) — plugins/ui.lua ──────────
-- Shift+H       → Prev buffer (BufferLineCyclePrev)
-- Shift+L       → Next buffer (BufferLineCycleNext)
-- <leader>bh    → Move buffer left (reorder)
-- <leader>bl    → Move buffer right (reorder)
-- <leader>bp    → Pick buffer by letter overlay
-- <leader>bd    → Delete (close) current buffer
-- <leader>bo    → Close all other buffers
-- <leader>bH    → Close all buffers to the left
-- <leader>bL    → Close all buffers to the right
-- <leader>b1-5  → Jump to buffer by ordinal position

-- ── [Phase 2] Notifications (<leader>n) — plugins/ui.lua ────
-- <leader>nl    → Show last notification message (noice)
-- <leader>nh    → Show notification history (noice)
-- <leader>na    → Show all messages (noice)
-- <leader>nd    → Dismiss all visible notifications (noice)
-- <S-Enter>     → Redirect cmdline output to popup (noice, cmdline mode)
-- <C-f>         → Scroll forward in LSP hover/signature (noice, i/n/s modes)
-- <C-b>         → Scroll backward in LSP hover/signature (noice, i/n/s modes)

-- ── [Phase 3] Find/Search (<leader>f) ───────────────────────
-- (telescope keymaps will go here)

-- ── [Phase 3] Explorer (<leader>e) ──────────────────────────
-- (neo-tree keymaps will go here)

-- ── [Phase 4] Search/Replace (<leader>s) ────────────────────
-- (grug-far keymaps will go here)

-- ── [Phase 5] LSP (<leader>l) ───────────────────────────────
-- (lsp keymaps will go here)

-- ── [Phase 6] Debug (<leader>d) ─────────────────────────────
-- (dap keymaps will go here)

-- ── [Phase 6] Test (<leader>t) ──────────────────────────────
-- (neotest keymaps will go here)

-- ── [Phase 7] Git (<leader>g) ───────────────────────────────
-- (gitsigns / lazygit / tortoisegit keymaps will go here)

-- ── [Phase 8] Diagnostics/Quickfix (<leader>x) ─────────────
-- (diagnostic keymaps will go here)

-- ── [Phase 8] Notifications (<leader>n) ─────────────────────
-- (noice / snacks notification keymaps will go here)
