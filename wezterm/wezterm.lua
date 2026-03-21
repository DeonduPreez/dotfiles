local wezterm = require("wezterm")
local config = wezterm.config_builder()

wezterm.on("user-var-changed", function(window, pane, name, value)
	if name == "NVIM_DEBUG_TITLE" then
		local overrides = window:get_config_overrides() or {}
		overrides.tab_bar_style = overrides.tab_bar_style or {}
		window:set_config_overrides(overrides)

		local tab = window:active_tab()
		tab:set_title(value)
	end
end)

config.keys = {
	{
		key = "v",
		mods = "CTRL",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
	{
		key = "c",
		mods = "CTRL",
		action = wezterm.action.CopyTo("Clipboard"),
	},
	{
		key = "t",
		mods = "CTRL|SHIFT",
		action = wezterm.action.DisableDefaultAssignment,
	},
	-- {
	-- key = "l",
	-- mods = "CTRL|SHIFT",
	-- action = wezterm.action.DisableDefaultAssignment,
	-- },
	{
		key = "l",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		key = "h",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.ActivateTabRelative(-1),
	},
}

config.default_prog = { "wsl.exe", "--distribution", "Ubuntu-24.04" }
config.enable_kitty_keyboard = true

return config
