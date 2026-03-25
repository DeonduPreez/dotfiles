return {
    -- ┌─────────────────────────────────────────────────────────────┐
	-- │  neo-tree.nvim                                              │
	-- │  Repo: https://github.com/nvim-neo-tree/neo-tree.nvim       │
	-- │  Docs: :h neo-tree                                          │
	-- │  Wiki: https://github.com/nvim-neo-tree/neo-tree.nvim/wiki  │
	-- │  File tree sidebar with git status, buffer list, and        │
	-- │  git_status sources. Replaces JetBrains' Project panel.     │
	-- │                                                             │
	-- │  Dependencies:                                              │
	-- │  - nui.nvim (required): UI component library for the tree   │
	-- │  - plenary.nvim (required): filesystem scanning utils       │
	-- │  - nvim-web-devicons (optional): file icons                 │
	-- └─────────────────────────────────────────────────────────────┘
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x", -- pin to v3 stable; never auto-upgrade to v4

		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},

		lazy = false,

		-- ── Keymaps ──────────────────────────────────────────
		-- Documented in keymaps.lua under "Explorer (<leader>e)".
		keys = {
			-- Toggle the sidebar. If it's open, close it. If closed, open
			-- and focus it. `reveal = true` scrolls the tree to the current file.
			{
				"<leader>e",
				function()
					require("neo-tree.command").execute({
						toggle = true,
						source = "filesystem",
						reveal = true,
					})
				end,
				desc = "Toggle Explorer",
			},

			-- Focus the tree (open if not visible, focus if already open).
			-- Unlike toggle, this never closes the tree.
			{
				"<leader>o",
				function()
					require("neo-tree.command").execute({
						source = "filesystem",
						reveal = true,
					})
				end,
				desc = "Focus Explorer",
			},
		},

		opts = {
			event_handlers = {
				-- {
				-- event = "neo_tree_buffer_leave",
				-- handler = function()
				-- vim.cmd("highlight! Cursor guibg=#5f87af blend=0")
				-- end,
				-- },
			},
			-- ── Sources ──────────────────────────────────────
			-- These are the "tabs" at the top of the neo-tree sidebar.
			-- filesystem = project files, buffers = open files, git_status = changed files.
			sources = { "filesystem", "buffers", "git_status" },

			-- When neo-tree opens a file, don't replace these special buffer types.
			-- Without this, opening a file from neo-tree could hijack a terminal
			-- or quickfix window.
			open_files_do_not_replace_types = {
				"terminal",
				"Trouble",
				"trouble",
				"qf",
				"Outline",
			},

			-- Close neo-tree if it's the last window open. Prevents leaving
			-- an empty neo-tree window when you close all file buffers.
			close_if_last_window = false,

			-- ── Default Component Config ─────────────────────
			-- Controls how tree items are rendered (icons, indentation, git symbols).
			default_component_configs = {
				indent = {
					-- Show expand/collapse arrows for directories.
					-- Makes the tree feel more interactive (like JetBrains' tree).
					with_expanders = false,
					-- expander_collapsed = "", -- right-pointing triangle
					-- expander_expanded = "", -- down-pointing triangle
					-- expander_highlight = "NeoTreeExpander",
				},

				-- Git status icons shown next to filenames.
				git_status = {
					symbols = {
						unstaged = "󰄱", -- checkbox empty
						staged = "󰱒", -- checkbox checked
					},
				},
			},

			-- ── Window ───────────────────────────────────────
			-- Controls the sidebar window itself (position, width, mappings).
			window = {
				-- Sidebar width. 35 columns is comfortable for most filenames
				-- without eating too much editor space.
				width = 30,

				-- Key mappings inside the neo-tree window.
				mappings = {
					-- Use l/h for open/close (vim-style navigation in the tree).
					-- This matches the LazyVim convention and feels natural.
					["l"] = "open",
					["h"] = "close_node",

					["e"] = function()
						vim.api.nvim_exec2("Neotree focus filesystem left", { output = true })
					end,
					["b"] = function()
						vim.api.nvim_exec2("Neotree focus buffers left", { output = true })
					end,
					["g"] = function()
						vim.api.nvim_exec2("Neotree focus git_status left", { output = true })
					end,

					["O"] = "open_in_explorer",

					-- Disable space in neo-tree so it doesn't conflict with <leader>.
					-- Without this, pressing space (our leader) in the tree would
					-- trigger neo-tree's default space action instead of which-key.
					["<space>"] = "none",

					-- Copy the absolute path of the selected file to clipboard.
					-- Useful when you need the path for terminal commands, imports, etc.
					["Y"] = {
						function(state)
							local node = state.tree:get_node()
							local path = node:get_id()
							vim.fn.setreg("+", path, "c")
							vim.notify("Copied path: " .. path)
						end,
						desc = "Copy path to clipboard",
					},

					-- Preview file without leaving neo-tree (opens in split, not float).
					-- Pressing P again on the same file will close the preview.
					["P"] = { "toggle_preview", config = { use_float = false } },
				},
			},

			commands = {
				open_in_explorer = function(state)
					local node = state.tree:get_node()
					local path = node:get_id()

					local wsl = require("helpers.wsl-helper")
					wsl.open_in_explorer(path)

					-- Windows: Without removing the file from the path, it opens in code.exe instead of explorer.exe
					-- local p
					-- local lastSlashIndex = path:match("^.+()\\[^\\]*$") -- Match the last slash and everything before it
					-- if lastSlashIndex then
					-- p = path:sub(1, lastSlashIndex - 1) -- Extract substring before the last slash
					-- else
					-- p = path -- If no slash found, return original path
					-- end
					-- vim.cmd("silent !start explorer " .. p)
				end,
			},

			-- ── Filesystem Source ─────────────────────────────
			filesystem = {
				-- Don't bind neo-tree to Neovim's `:cd` (current working directory).
				-- When false, neo-tree maintains its own root independent of pwd.
				-- This is safer for multi-project workflows.
				bind_to_cwd = true,

				-- Auto-reveal the current file in the tree as you switch buffers.
				-- This is the JetBrains "always select open file" behavior.
				follow_current_file = {
					enabled = true,
					-- Don't auto-close expanded directories when following.
					-- Keeps your tree state stable as you navigate.
					leave_dirs_open = true,
				},

				-- Use libuv (native async) file watcher to detect external changes
				-- (e.g., git checkout, file creation from terminal). Without this,
				-- you'd need to manually refresh the tree with `R`.
				use_libuv_file_watcher = true,

				-- Configure which files are visible/hidden by default.
				filtered_items = {
					-- Show dotfiles (like .gitignore, .env) — we're developers,
					-- we need to see config files. Toggle visibility with `H` in the tree.
					hide_dotfiles = true,

					-- Show gitignored files (dimmed). Useful for seeing node_modules
					-- exists without it cluttering the view.
					hide_gitignored = true,

					-- Files that NEVER show even when "show hidden" is on.
					-- These are truly garbage files you never need to see.
					never_show = {
						".DS_Store",
						"thumbs.db",
						".idea",
					},
				},
			},

			-- ── Buffers Source ────────────────────────────────
			buffers = {
				-- Same "follow current file" behavior for the buffers view.
				follow_current_file = {
					enabled = true,
					leave_dirs_open = true,
				},
			},
		},

		-- We need a custom init to handle the case where Neovim is opened
		-- with a directory argument (e.g., `nvim .`). In that case, we want
		-- neo-tree to open automatically in the netrw-style position.
		init = function()
			-- Disable netrw (the built-in file explorer) completely.
			-- Without this, opening `nvim .` would load netrw before neo-tree.
			vim.g.loaded_netrwPlugin = 1
			vim.g.loaded_netrw = 1
		end,
	},

	-- ┌────────────────────────────────────────────────────────────────┐
	-- │  nvim-lsp-file-operations                                      │
	-- │  Repo: https://github.com/antosha417/nvim-lsp-file-operations  │
	-- │  Docs: :h nvim-lsp-file-operations                             │
	-- │  Adds support for file operations using LSP support.           │
	-- │  This plugin subscribes to events in neo-tree.                 │
	-- │                                                                │
	-- │  Dependencies:                                                 │
	-- │  - plenary.nvim (required): async utilities                    │
	-- │  - neo-tree.nvim (required): Provides file operation events.   │
	-- └────────────────────────────────────────────────────────────────┘
	{
		"antosha417/nvim-lsp-file-operations",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
		},
		config = function()
			require("lsp-file-operations").setup({
				operations = {
					willRenameFiles = true,
					didRenameFiles = true,
					willCreateFiles = true,
					didCreateFiles = true,
					willDeleteFiles = true,
					didDeleteFiles = true,
				},
				timeout_ms = 10000, -- how long to wait (in milliseconds) for file rename information before cancelling
			})
		end,
	},
}
