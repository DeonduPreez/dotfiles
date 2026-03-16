return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 400, -- ms before popup appears
      icons = { mappings = true },
      spec = {
        -- Register group labels so the popup is organised
        { "<leader>f",  group = "Find (Telescope)" },
        { "<leader>b",  group = "Buffers" },
        { "<leader>l",  group = "LSP" },       -- reserved for Phase 3
        { "<leader>d",  group = "Debug" },     -- reserved for Phase 4
        { "<leader>t",  group = "Test" },      -- reserved for Phase 5
        { "<leader>g",  group = "Git" },       -- reserved for Phase 6
        { "<leader>u",  group = "UI Toggles" },
      },
    },
  }