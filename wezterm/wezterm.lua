local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.keys = {
    {
        key = 'v',
        mods = 'CTRL',
        action = wezterm.action.PasteFrom 'Clipboard'
    },
    {
        key = 'c',
        mods = 'CTRL',
        action = wezterm.action.CopyTo 'Clipboard'
    },
    {
        key = 't',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.DisableDefaultAssignment
    },
    {
        key = 'l',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.DisableDefaultAssignment
    },
}

return config