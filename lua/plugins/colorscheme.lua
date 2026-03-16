return {
    -- Tell LazyVim to use rider.nvim instead of its default colorscheme
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "rider",
      },
    },
    -- The actual rider.nvim plugin
    {
      "tomstolarczuk/rider.nvim",
      lazy = false,    -- load at startup
      priority = 1000, -- load before everything else
      opts = {
        commentStyle = { italic = true },
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        transparent = false,
        terminalColors = true,
      },
      config = function(_, opts)
        require("rider").setup(opts)
      end,
    },
}