local M = {}

--- Checks if a value exists in an array-like table.
--- @param table table The table to check.
--- @param value any The value to search for.
--- @return boolean True if the value is found, false otherwise.
function M.contains(table, value)
	for _, table_value in ipairs(table) do
		if table_value == value then
			return true
		end
	end
	return false
end

return M
