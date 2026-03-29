-- ╔══════════════════════════════════════════════════════════════╗
-- ║  helpers/buf-helper.lua — Buffer Management Utilities      ║
-- ║                                                            ║
-- ║  Provides safe buffer operations:                          ║
-- ║  - delete/force_delete: close without quitting Neovim      ║
-- ║  - cycle: navigate prev/next listed buffer                 ║
-- ║  - go_to: jump to buffer by ordinal position               ║
-- ║  - close_others: close all buffers except current          ║
-- ║  - close_direction: close buffers left/right of current    ║
-- ║  - get_listed_bufs: ordered list of listed buffers         ║
-- ║                                                            ║
-- ║  TODO: Remplace with Snacks.bufdelete() in Phase 8.        ║
-- ╚══════════════════════════════════════════════════════════════╝

local M = {}

-- ── Helpers ──────────────────────────────────────────────────

--- Returns an ordered list of valid, listed buffer numbers.
--- This matches the order Heirline's make_buflist uses (buffer number order),
--- so ordinal positions in keymaps line up with the visual tab positions.
---@return integer[]
function M.get_listed_bufs()
	return vim.tbl_filter(function(bufnr)
		return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
	end, vim.api.nvim_list_bufs())
end

-- ── Delete ───────────────────────────────────────────────────

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

	local listed = M.get_listed_bufs()

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

-- ── Cycling ──────────────────────────────────────────────────

--- Cycle to the next or previous listed buffer.
--- Wraps around at the ends of the list.
---@param direction integer 1 for next, -1 for previous
function M.cycle(direction)
	local bufs = M.get_listed_bufs()
	if #bufs <= 1 then
		return
	end

	local current = vim.api.nvim_get_current_buf()
	for i, bufnr in ipairs(bufs) do
		if bufnr == current then
			-- Lua 1-indexed modular arithmetic:
			-- (i - 1 + direction) % #bufs + 1 wraps correctly in both directions
			local target_idx = ((i - 1 + direction) % #bufs) + 1
			vim.api.nvim_set_current_buf(bufs[target_idx])
			return
		end
	end
end

--- Cycle to the next listed buffer.
function M.next()
	M.cycle(1)
end

--- Cycle to the previous listed buffer.
function M.prev()
	M.cycle(-1)
end

-- ── Ordinal Jump ─────────────────────────────────────────────

--- Jump to a buffer by its ordinal position in the listed buffer list.
--- Position 1 = first listed buffer, 2 = second, etc.
--- This matches the visual order in the Heirline tabline.
---@param ordinal integer The 1-based position to jump to
function M.go_to(ordinal)
	local bufs = M.get_listed_bufs()
	if ordinal > 0 and ordinal <= #bufs then
		vim.api.nvim_set_current_buf(bufs[ordinal])
	end
end

-- ── Close Others ─────────────────────────────────────────────

--- Close all listed buffers except the current one.
--- Skips modified buffers (doesn't force-close them).
function M.close_others()
	local current = vim.api.nvim_get_current_buf()
	local bufs = M.get_listed_bufs()
	for _, bufnr in ipairs(bufs) do
		if bufnr ~= current and not vim.bo[bufnr].modified then
			pcall(vim.cmd, "bdelete " .. bufnr)
		end
	end
end

--- Close listed buffers to the left or right of the current buffer.
--- "Left" and "right" refer to ordinal position in the buffer list
--- (matching visual position in the tabline).
---@param direction Which side to close, -1 for left, 1 for right
function M.close_direction(direction)
	local bufs = M.get_listed_bufs()
	local current = vim.api.nvim_get_current_buf()
	local current_idx = nil

	for i, bufnr in ipairs(bufs) do
		if bufnr == current then
			current_idx = i
			break
		end
	end

	if not current_idx then
		return
	end

	local start_idx, end_idx
	if direction == -1 then
		start_idx = current_idx - 1
        end_idx = 1
	else
		start_idx = current_idx + 1
        end_idx = #bufs
	end

	for i = start_idx, end_idx, direction do
		if not vim.bo[bufs[i]].modified then
            local currentbufpath = vim.api.nvim_buf_get_name(bufs[i])
            pcall(vim.cmd, "bdelete " .. bufs[i])
		end
	end
end

return M
