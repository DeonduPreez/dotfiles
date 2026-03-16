return {
    -- Mason tool installer: ensure our servers are always present
    {
      "mason-org/mason.nvim",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        vim.list_extend(opts.ensure_installed, {
          "omnisharp",
          "typescript-language-server",
          "angular-language-server",
          "ansible-language-server",
          "api-linter",
          "azure-pipelines-language-server",
          "bash-language-server",
          "docker-language-server",
          "cpplint",
          "cpptools",
      })
      end,
    },

    -- LSP configuration
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          -- TypeScript
          ts_ls = {
            root_dir = function(fname)
              local util = require("lspconfig.util")

              -- Don't start ts_ls if this file is inside an Angular project
              if util.root_pattern("angular.json")(fname) then
                return nil
              end

              return util.root_pattern("tsconfig.json", "package.json", ".git")(fname)
            end,
          },

          -- C# via OmniSharp
          omnisharp = {
            -- Enables Roslyn analysers for richer diagnostics
            enable_roslyn_analysers = true,
            enable_import_completion = true,
            organize_imports_on_format = true,
            -- Needed so go-to-def works across decompiled sources
            enable_decompilation_support = true,
          },
        },
      },
    },
  }