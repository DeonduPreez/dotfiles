local M = {}

local p = require("helpers.path-helper")

--- Opens the path in explorer and selects it.
---@param path string Path to open
function M.open_in_explorer(path)
	select = select or false

	if not p.check_path_exists(path) then
		vim.notify("Path doesn't exist: " .. path)
		return
	end

	path = vim.fn.system("wslpath -w " .. vim.fn.shellescape(path)):gsub("%s+$", "")

	vim.fn.jobstart({
		"explorer.exe",
		"/select," .. path,
	})
end

return M
