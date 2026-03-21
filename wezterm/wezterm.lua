local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font =
	wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "DemiBold", stretch = "Normal", style = "Normal" })
config.font_size = 13.0

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

-- Disabling truncation of tab titles
config.tab_max_width = 9999

-- ─────────────────────────────────────────────────────────────────────────────
-- Glass / Transparency Effect (Windows only)
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Tab Bar: Transparent (Retro Style) ───────────────────────────────────────
config.use_fancy_tab_bar = false

config.colors = {
	tab_bar = {
		background = "rgba(0, 0, 0, 0)",

		active_tab = {
			bg_color = "rgba(15, 20, 40, 0.75)", -- Dark Heavy Background
			fg_color = "#c0caf5", -- tokyo night blue-white
		},

		inactive_tab = {
			bg_color = "rgba(0, 0, 0, 0)", -- Fully transparent because it's in the background
			fg_color = "#c0caf5", -- tokyo night blue-white
		},

		inactive_tab_hover = {
			bg_color = "rgba(255, 255, 255, 0.07)",
			fg_color = "#ffffff",
		},

		new_tab = {
			bg_color = "rgba(0, 0, 0, 0)",
			fg_color = "rgba(255, 255, 255, 0.45)",
		},

		new_tab_hover = {
			bg_color = "rgba(255, 255, 255, 0.07)",
			fg_color = "#ffffff",
		},
	},
}

-- ── Editor: Transparent ───────────────────────────────────────
-- Docs: https://wezterm.org/config/lua/config/win32_system_backdrop.html
-- Acrylic — frosted blur of whatever is behind the window.
-- Mica — subtle desktop wallpaper bleed, very low-resource.
-- Tabbed — like Mica but with a stronger accent color tint.
config.win32_system_backdrop = "Acrylic"

-- When using Mica/Tabbed set this to 0 for better results
config.window_background_opacity = 0.30

-- Prevent the text cell background from going fully transparent.
-- Without this, the terminal background color (e.g. from your colorscheme)
-- will also become transparent, making text hard to read.
-- Range: 0.0 (invisible) to 1.0 (fully opaque).
-- ~0.85 gives you a readable semi-transparent feel.
config.text_background_opacity = 0.85

-- Remove the titlebar so the glass effect extends to the top edge.
-- INTEGRATED_BUTTONS moves minimize/maximize/close into the tab bar itself.
-- RESIZE keeps window-edge dragging for resizing.
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

return config
