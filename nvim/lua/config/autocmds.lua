-- ╔══════════════════════════════════════════════════════════════╗
-- ║  User Commands                                             ║
-- ╚══════════════════════════════════════════════════════════════╝
-- ── :HP - quick health check for this IDE config ────────────────────────────────────────
vim.api.nvim_create_user_command("HP", function()
	vim.cmd("checkhealth hp")
end, { desc = "Health Points - IDE health check" })

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  Autocommands                                              ║
-- ╚══════════════════════════════════════════════════════════════╝

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── Highlight on Yank ────────────────────────────────────────
-- Briefly flash the yanked text so you can see what was copied.
-- Built into Neovim 0.10+ via vim.highlight.on_yank().
augroup("highlight_yank", { clear = true })
autocmd("TextYankPost", {
	group = "highlight_yank",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})


augroup("set_terminal_title", { clear = true })
autocmd("BufEnter", {
    group = "set_terminal_title",
    callback = function(event)
        if not event.file or event.file == "" then
            return
        end

        local sess_name = vim.g.sess_name and vim.g.sess_name or ""
        local title = sess_name .. " " .. event.file
        require("helpers.gsty-helper").set_terminal_title(title)
    end
})

-- ── Cursor Management ──────────────────────────────────
-- When re-opening a file, jump back to where you were last time.
-- Neovim stores this in the ShaDa file (like viminfo).
augroup("restore_cursor", { clear = true })
autocmd("BufReadPost", {
	group = "restore_cursor",
	callback = function(event)
		local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(event.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Restore default cursor when leaving Neovim so the terminal
-- isn't stuck with our custom cursor shape/color.
augroup("vim_reset_cursor", { clear = true }) 
autocmd("VimLeave", {
	group = "vim_reset_cursor",
	callback = function()
        -- TODO : Check if this does anything?
        require("helpers.gsty-helper").reset_cursor()
	end,
})

-- ── Auto-resize Splits on Window Resize ──────────────────────
-- If you resize the terminal (or WezTerm pane), all splits
-- equalize automatically.
augroup("auto_resize", { clear = true })
autocmd("VimResized", {
	group = "auto_resize",
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- ── Close Certain Filetypes with `q` ────────────────────────
-- Help, man pages, quickfix, etc. can be closed with a single `q`
-- instead of :q — saves keystrokes for read-only info buffers.
augroup("close_with_q", { clear = true })
autocmd("FileType", {
	group = "close_with_q",
	pattern = {
		"help",
		"man",
		"qf",
		"notify",
		"lspinfo",
		"checkhealth",
		"startuptime",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})

-- ── TypeScript/Angular 2-Space Indent ────────────────────────
-- Override the default 4-space indent for TS/JS/HTML/CSS files,
-- matching the Angular/TypeScript community convention.
augroup("frontend_indent", { clear = true })
autocmd("FileType", {
	group = "frontend_indent",
	pattern = {
		"typescript",
		"javascript",
		"typescriptreact",
		"javascriptreact",
		"html",
		"css",
		"scss",
		"json",
		"yaml",
	},
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
	end,
})
