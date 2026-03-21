-- Load core settings first (before plugins, so leader is set early)
require("config.options")

-- Bootstrap lazy.nvim and load all plugins
require("config.lazy")

-- Load keymaps after plugins are loaded
require("config.keymaps")

-- Load autocommands
require("config.autocmds")
