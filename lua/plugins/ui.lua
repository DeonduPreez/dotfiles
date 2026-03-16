return {
    -- Tab bar
    {
      "akinsho/bufferline.nvim",
      version = "*",
      dependencies = "nvim-tree/nvim-web-devicons",
      lazy = false,
      opts = {
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          show_buffer_close_icons = true,
          show_close_icon = false,
          separator_style = "slant",
          offsets = {
            {
              filetype = "neo-tree",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "left",
            },
          },
        },
      },
      keys = {
        { "<S-l>",     "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
        { "<S-h>",     "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
        { "<leader>bd", "<cmd>bdelete<cr>",             desc = "Delete Buffer" },
        { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin Buffer" },
      },
    },

    -- Status bar
    {
      "nvim-lualine/lualine.nvim",
      dependencies = "nvim-tree/nvim-web-devicons",
      lazy = false,
      opts = {
        options = {
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      },
    },
  }