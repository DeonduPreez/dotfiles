-- ╔══════════════════════════════════════════════════════════════╗
-- ║  helpers/safe-buf-delete.lua — Safe Buffer Delete                ║
-- ║                                                            ║
-- ║  Closes a buffer without quitting Neovim. If the target    ║
-- ║  is the last listed buffer, creates an empty scratch       ║
-- ║  buffer first so there's always something to land on.      ║
-- ║                                                            ║
-- ║  Can be replaced with Snacks.bufdelete() in       ║
-- ║  Phase 8 if desired.                                       ║
-- ╚══════════════════════════════════════════════════════════════╝

local M = {}

--- Delete a buffer safely without closing the window or quitting Neovim unless force is true
---@param bufnr? integer Buffer number to delete. Defaults to current buffer.
---@param force? boolean Force-delete even if buffer has unsaved changes.
function M.delete(bufnr, force)
	bufnr = bufnr or 0
	-- Resolve 0 (current) to the actual buffer number.
	if bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	end

	-- If the buffer has unsaved changes and we're not forcing, warn the user.
	if not force and vim.bo[bufnr].modified then
		vim.notify("Buffer has unsaved changes. Save first or use force delete.", vim.log.levels.WARN)
		return
	end

	-- Collect all listed (real, visible-in-bufferline) buffers.
	local listed = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted
	end, vim.api.nvim_list_bufs())

	-- If this is the last listed buffer, create an empty one first.
	-- This is the key trick: Neovim always has a buffer to show,
	-- so it never falls through to quitting.
	if #listed <= 1 then
		vim.cmd("enew") -- create a new empty buffer
		vim.bo.buflisted = true -- make sure it shows in bufferline
	else
		-- Switch to the next buffer before deleting, so the window
		-- doesn't close. Try the previous buffer first (more natural
		-- when closing rightmost tabs), fall back to next.
		local alt = vim.fn.bufnr("#")
		if alt ~= -1 and alt ~= bufnr and vim.bo[alt].buflisted then
			vim.api.nvim_set_current_buf(alt)
		else
			vim.cmd("bprevious")
		end
	end

	-- Now delete the original buffer. Use pcall in case something
	-- else already closed it (race condition with autocmds).
	local cmd = force and "bdelete!" or "bdelete"
	pcall(vim.cmd, cmd .. " " .. bufnr)
end

--- Force-delete a buffer (discards unsaved changes).
---@param bufnr? integer Buffer number to delete. Defaults to current buffer.
function M.force_delete(bufnr)
	M.delete(bufnr, true)
end

return M
