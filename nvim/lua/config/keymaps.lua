-- ╔══════════════════════════════════════════════════════════════╗
-- ║  Keymaps — Single Source of Truth                          ║
-- ║                                                            ║
-- ║  NON-PLUGIN keymaps live here directly.                    ║
-- ║  PLUGIN-SPECIFIC keymaps are defined in the plugin spec's  ║
-- ║  `keys` table (for lazy-loading), but are DOCUMENTED here  ║
-- ║  in comment blocks so you can see ALL bindings in one file.║
-- ╚══════════════════════════════════════════════════════════════╝

-- TODO : Check if refactor.nvim can delete the current scope wrapper. Like if (asdf){ {code} } should remove the if, and leave the code.

-- TODO : Update Ghostty keybinds via dotfiles config (ctrl+v) (ctrl+shift+s sometimes) (ctrl+shift+t)
-- TODO : After startup, if we opened with a directory or no args and there is no session we should auto-focus Neo-tree
-- TODO : When on the start of the line and going left go to the previous line's end
-- TODO : Add a keymap that expands selection the same way rider does. I can write this myself with test cases I 
-- TODO : Add a keymap that moves the window all the way to the left or all the way to the right (<leader>wH , <leader>wL)
-- TODO : Add a keymap that goes to the start of the file like Ctrl+Home (Ctrl+Shift+H)
-- TODO : Add a keymap that goes to the end of the file like Ctrl+End (Ctrl+Shift+L)
-- TODO : Add a keymap that yanks the whole file's contents and sets the cursor position back to previous position. Was thinking <C-A> (Ctrl+Shift+A) - maybe make it v<C-a> so Ctrl+a while in visual mode.
-- TODO : Add a keymap that copies the file's absolute path. (Ctrl+Shift+c like Rider)
-- TODO : Maybe look for/create a plugin that checks checklist lines and allows you to press shift+enter in insert mode or another key combo in visual mode to enter insert mode and create a new dotted line on the next line. Use some fancy regex, we want to allow commented/uncommented lines for this.
-- TODO : Extend the above to allow numbered lines as well.


-- TODO : Add a keymap in Neo-tree that allows adding to git (Ctrl+Shift+A)
-- TODO : In Neo-tree, when renaming, if the file exists in git, do a git move. Look at other git commands that happen in Rider from the Explorer UI.

local map = vim.keymap.set

-- ═══════════════════════════════════════════════════════════════
-- GENERAL (non-plugin)
-- ═══════════════════════════════════════════════════════════════
-- ── Pasting (<C-Home> / <C-End>) ────────────────────────────
map("i", "<C-v>", "<C-o><leader>p", { desc = "Paste without overwriting register" })
-- Paste over selection without yanking.
-- TODO : We need a better way to do this, <leader>D is not intuitive.
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- ── Home / End (<C-Home> / <C-End>) ────────────────────────────
map("n", "<leader>wv", "<C-w>v", { desc = "Split vertical" })

-- ── Insert mode editing shortcuts ────────────────────────────
map("i", "<C-BS>", "<C-w>", { desc = "Delete word backward" })
map("i", "<C-Del>", "<C-o>dw", { desc = "Delete word forward" })

-- ── Splits / Windows (<leader>w) ────────────────────────────
map("n", "<leader>wv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>ws", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>we", "<C-w>=", { desc = "Equalize splits" })
map("n", "<leader>wq", "<cmd>close<CR>", { desc = "Close split" })

-- ── Split / Window navigation (<C-h> / <C-j> / <C-k> / <C-l>) ─────────────────────────────
-- Window navigation with Ctrl+hjkl (instead of Ctrl-W then h / j / k / l). Saves one keystroke every time you switch splits.
map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to below split" })
map("n", "<C-k>", "<C-w>k", { desc = "to above split" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- ── Split / Window resizing (<C-Up> / <C-Down> / <C-Left> / <C-Right>) ─────────────────────────────
-- Resize splits with Ctrl+Arrow keys.
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- ── Line moving (J / K) ─────────────────────────────
-- Move selected lines up / down in visual mode. Also re-selects after moving so you can keep nudging.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ── Page Up / Down centering (<C-d> / <C-d>) ─────────────────────────────
-- Keep cursor centered when scrolling half-page.
map("n", "<C-d>", "<C-d>zz", { desc = "Page Down while keeping the cursor centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Page Up while keeping the cursor centered" })

-- ── Search results (n / N) ─────────────────────────────
-- Keep cursor centered when jumping to search results.
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })
map("v", "n", "nzzzv", { desc = "Next search result (centered)" })
map("v", "N", "Nzzzv", { desc = "Prev search result (centered)" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- ── Delete without yank (<leader>D) ─────────────────────────────
-- Delete without yanking (send to black hole register).
-- TODO : We need a better way to do this, <leader>D is not intuitive.
map({ "n", "v" }, "<leader>D", [["_d]], { desc = "Delete without yanking" })

-- ── Indenting (><) ─────────────────────────────
-- Better indenting: re-selects the visual selection after indent / dedent.
-- TODO : Fix bug here. It doesn't reselect the actual selected text, just the selected indexes.
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

-- ── Open in explorer (<C-S-o>) ─────────────────────────────
local wsl = require("helpers.wsl-helper")
map("n", "<C-S-o>", function()
	wsl.open_in_explorer()
end, { desc = "Open in file explorer" })

-- ── Saving (<C-s> / <C-S-s>) ─────────────────────────────
map("n", "<C-s>", "<cmd>w<CR>", {desc = "Save file"})
map("n", "<C-S-s>", "<cmd>wa<CR>", {desc = "Save all open files"})

map({ "i", "v" }, "<C-s>", "<Esc><cmd>w<CR>", {desc = "Save file"})
map({ "i", "v" }, "<C-S-s>", "<Esc><cmd>wa<CR>", {desc = "Save all open files"})

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
-- <C-f>         → Scroll forward in LSP hover / signature (noice, i / n / s modes)
-- <C-b>         → Scroll backward in LSP hover / signature (noice, i / n / s modes)

-- ── [Phase 3] Find / Search (<leader>f) ───────────────────────
-- (telescope keymaps will go here)

-- ── [Phase 3] Explorer (<leader>e) ──────────────────────────
-- (neo-tree keymaps will go here)

-- ── [Phase 4] Search / Replace (<leader>s) ────────────────────
-- (grug-far keymaps will go here)

-- ── [Phase 5] LSP (<leader>l) ───────────────────────────────
-- (lsp keymaps will go here)

-- ── [Phase 6] Debug (<leader>d) ─────────────────────────────
-- (dap keymaps will go here)

-- ── [Phase 6] Test (<leader>t) ──────────────────────────────
-- (neotest keymaps will go here)

-- ── [Phase 7] Git (<leader>g) ───────────────────────────────
-- (gitsigns / lazygit / tortoisegit keymaps will go here)

-- ── [Phase 8] Diagnostics / Quickfix (<leader>x) ─────────────
-- (diagnostic keymaps will go here)

-- ── [Phase 8] Notifications (<leader>n) ─────────────────────
-- (noice / snacks notification keymaps will go here)
