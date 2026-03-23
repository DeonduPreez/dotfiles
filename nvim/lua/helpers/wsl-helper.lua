local M = {}

local p = require("helpers.path-helper")
local array = require("helpers.arr-helper")

--- Opens the path in explorer and selects it.
--- Has protections for not opening the wrong buffer type like neo-tree.
---@param path string? Path to open. Defaults to current open buffer if nothing is specified.
function M.open_in_explorer(path)
	local bypass_filetypes = { "neo-tree", "noice" }

	local filetype = vim.bo.filetype

	if array.contains(bypass_filetypes, filetype) then
		return
	end

	if not path or path == "" then
		path = vim.api.nvim_buf_get_name(0)
	end

	if not p.check_path_exists(path) then
		vim.notify("Path doesn't exist: " .. path)
		return
	end

	path = vim.fn.system("wslpath -w " .. vim.fn.shellescape(path)):gsub("%s+$", "")

	vim.fn.jobstart({
		"explorer.exe",
		"/select," .. path,
	})

	-- For debugging purposes
	-- print(path)
	-- print(filetype)
end

function M.open_cur_in_explorer() end

return M
