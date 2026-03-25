local M = {}
M.harpoon = require("harpoon")

M._harpoon_cache = {}

function M.rebuild_harpoon_cache()
    vim.notify("Rebuilding harpoon cache")
    M._harpoon_cache = {}

    local list = M.harpoon:list()
    for i, item in pairs(list.items) do
        if type(i) == "number" and item and item.value ~= "" then
            M._harpoon_cache[vim.fn.fnamemodify(item.value, ":p")] = i
        end
    end
end

function M.get_harpoon_index(filepath)
    local itemrelativepath = vim.fn.fnamemodify(filepath, ":p")
	local cachedindex = M._harpoon_cache[itemrelativepath]
	if not cachedindex then
		return cachedindex
	end

	return M._harpoon_cache[itemrelativepath]
end

return M
