-- ╔══════════════════════════════════════════════════════════════╗
-- ║  helpers/gsty-helper.lua — Ghostty Terminal Integration    ║
-- ║                                                            ║
-- ║  Ghostty supports standard xterm escape sequences for      ║
-- ║  title setting (OSC 2) and iTerm2-compatible user vars     ║
-- ║  (OSC 1337). Unlike WezTerm, Ghostty does not yet have     ║
-- ║  a scripting layer on Linux, so we rely on escape          ║
-- ║  sequences for all terminal communication.                 ║
-- ║                                                            ║
-- ║  Replaces wztrm-helper.lua for active use.                 ║
-- ║  wztrm-helper.lua is kept for future WezTerm/kitty use.    ║
-- ╚══════════════════════════════════════════════════════════════╝

local M = {}

--- Set the terminal tab/window title using the standard xterm
--- OSC 2 escape sequence. Ghostty respects this natively.
--- This is more portable than the WezTerm user-var approach.
---@param title string The title text to display in the tab
function M.set_terminal_title(title)
	-- OSC 2 = Set Window Title
	-- \x1b]2; ... \x07  (ESC ] 2 ; <title> BEL)
	io.write("\x1b]2;" .. title .. "\x07")
	io.flush()
end

--- Set an iTerm2-compatible user variable via OSC 1337.
--- Ghostty supports a subset of iTerm2's OSC 1337 protocol.
--- Values are base64-encoded per the spec.
---@param name string The variable name
---@param value string The variable value (will be base64-encoded)
function M.set_user_var(name, value)
	local esc = "\x1b"
	local bel = "\x07"
	local encoded = vim.base64.encode(value)
	io.write(esc .. "]1337;SetUserVar=" .. name .. "=" .. encoded .. bel)
	io.flush()
end

function M.reset_cursor()
		vim.opt.guicursor = "a:ver25-blinkon0"
		-- Send OSC 112 to reset cursor color to terminal default
		io.write("\x1b]112\x07")
		io.flush()
end

return M
