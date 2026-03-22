local M = {}

--- Check the type of the path passed in
--- Returns nil when path is not file system path
---@param path any
---@return nil|"file"|"directory"|"other"
function M.check_path_type(path)
	local stat = vim.loop.fs_stat(path)
	if not stat then
		return nil
	elseif stat.type == "file" then
		return "file"
	elseif stat.type == "directory" then
		return "directory"
	else
		return "other"
	end
end

return M
