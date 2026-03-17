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
          -- Angular
          angularls = {
            root_dir = function(bufnr, on_dir)
              -- The project root is where the LSP can be started from
              -- As stated in the documentation above, this LSP supports monorepos and simple projects.
              -- We select then from the project root, which is identified by the presence of a package
              -- manager lock file.
              local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }

              -- if no project_root exists, this isn't even a ts project.
              local path = vim.api.nvim_buf_get_name(bufnr)
              local project_root = vim.fs.root(path, root_markers)
              if project_root == nil then
                vim.notify("project_root not found, disabling angularls", vim.log.levels.INFO)
                return
              end

              -- exclude non-angular projects
              local angularjson_root = vim.fs.root(project_root, { 'angular.json' })
              if angularjson_root == nil or (not project_root or #angularjson_root < #project_root) then
                -- angular.json is further away from package manager lock, abort
                vim.notify("angularjson_root found, disabling angularls: '" .. tostring(angularjson_root) .. "'", vim.log.levels.INFO)
                return
              end

              on_dir(angularjson_root)
            end,
          },

          -- TypeScript
          ts_ls = {
            root_dir = function(bufnr, on_dir)
              -- The project root is where the LSP can be started from
              -- As stated in the documentation above, this LSP supports monorepos and simple projects.
              -- We select then from the project root, which is identified by the presence of a package
              -- manager lock file.
              local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
              -- Give the root markers equal priority by wrapping them in a table
              root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers, { '.git' } }
                or vim.list_extend(root_markers, { '.git' })
              -- exclude deno

              local path = vim.api.nvim_buf_get_name(bufnr)
              local project_root = vim.fs.root(path, root_markers)
              if project_root == nil then
                vim.notify("project_root not found, disabling ts_ls", vim.log.levels.INFO)
                return
              end

              local deno_root = vim.fs.root(path, { 'deno.json', 'deno.jsonc' })
              local deno_lock_root = vim.fs.root(path, { 'deno.lock' })
              if deno_lock_root ~= nil and (not project_root or #deno_lock_root > #project_root) then
                -- deno lock is closer than package manager lock, abort
                vim.notify("deno lock is closer than package manager lock, abort, disabling ts_ls", vim.log.levels.INFO)
                return
              end

              if deno_root ~= nil and (not project_root or #deno_root >= #project_root) then
                -- deno config is closer than or equal to package manager lock, abort
                vim.notify("deno config is closer than or equal to package manager lock, abort, disabling ts_ls", vim.log.levels.INFO)
                return
              end

              -- exclude angular projects
              local angularjson_root = vim.fs.root(path, { 'angular.json' })
              if angularjson_root ~= nil and (not project_root or #angularjson_root >= #project_root) then
                -- angular.json is closer than or equal to package manager lock, abort
                vim.notify("angularjson_root found, disabling ts_ls", vim.log.levels.INFO)
                return
              end

              on_dir(project_root)
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