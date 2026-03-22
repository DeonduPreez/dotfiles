local M = {}

function M.set_terminal_title(title)
	M.set_user_var("WEZTERM_TITLE", title)
end

function M.set_user_var(name, value)
	local esc = "\x1b"
	local bel = "\x07"
	local encoded = vim.base64.encode(value)
	io.write(esc .. "]1337;SetUserVar=" .. name .. "=" .. encoded .. bel)
	io.flush()
end

return M
