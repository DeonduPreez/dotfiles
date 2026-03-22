--- lua/helpers/toggle.lua
--- Toggle utility helpers.
--- Currently handles boolean word toggling under the cursor.
--- Designed to be extended with additional toggle operations over time.

local M = {}

-- ---------------------------------------------------------------------------
-- Boolean toggling
-- ---------------------------------------------------------------------------

--- Map of every recognised boolean word to its opposite.
--- Keys are the canonical forms; the lookup function normalises case before
--- hitting this table and then re-applies the original casing style.
---
--- Extend this table if you want to support other paired words in the future
--- (e.g. "yes"/"no", "on"/"off", "enable"/"disable").
M.bool_pairs = {
	["true"] = "false",
	["false"] = "true",
	["1"] = "0",
	["0"] = "1",
	["yes"] = "no",
	["no"] = "yes",
	["enable"] = "disable",
	["disable"] = "enable",
	["enabled"] = "disabled",
	["disabled"] = "enabled",
	["checked"] = "unchecked",
	["unchecked"] = "checked",
	["check"] = "uncheck",
	["uncheck"] = "check",
}

--- Detect the casing style of a word so we can re-apply it after the swap.
---
--- Returns one (checks in this order):
---   "lower"  — all characters are lowercase   (true / false)
---   "title"  — first character upper, rest lower (True / False)
---   "upper"  — all characters are uppercase  (TRUE / FALSE)
---   "mixed"  — anything else (tRuE, fAlSe, …) — treated as lowercase
---@param word string
---@return "upper"|"title"|"lower"|"mixed"
local function detect_case(word)
	if word == word:lower() then
		return "lower"
	end

	-- Title case: first char upper, everything else lower
	local first = word:sub(1, 1)
	local rest = word:sub(2)
	if first == first:upper() and rest == rest:lower() then
		return "title"
	end

	if word == word:upper() then
		return "upper"
	end

	return "mixed"
end

--- Re-apply a casing style to a (lowercase) word.
---@param word string   already-lowercase target word
---@param style "upper"|"title"|"lower"|"mixed"
---@return string
local function apply_case(word, style)
	if style == "upper" then
		return word:upper()
	elseif style == "title" then
		return word:sub(1, 1):upper() .. word:sub(2):lower()
	else
		-- "lower" and "mixed" both fall through as-is
		return word
	end
end

--- Toggle the boolean word under the cursor.
--- Handles lowercase (true/false), Title case (True/False), UPPER CASE
--- (TRUE/FALSE), and mixed case (tRuE → normalised to lowercase false).
---
--- Uses `<cword>` to grab the word under the cursor and `ciw` to replace it,
--- so normal undo (u) works as expected.
function M.toggle_bool()
	local word = vim.fn.expand("<cword>")
	local style = detect_case(word)

	-- We only act on recognised words; silently do nothing otherwise.
	local lower = word:lower()
	local opposite = M.bool_pairs[lower]

	if not opposite then
		-- Not a boolean word — nothing to do.
		return
	end

	-- Mixed case falls through to "lower" in apply_case, normalising
	-- tRuE → false and fAlSe → true rather than skipping them.
	local replacement = apply_case(opposite, style)

	-- `ciw` changes the inner word and drops us into Insert mode, then
	-- <Esc> returns to Normal.  This keeps the change in the undo tree like
	-- any other edit.
	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
	vim.cmd("normal! ciw" .. replacement .. esc .. "b")
end

return M
