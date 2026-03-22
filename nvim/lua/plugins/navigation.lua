-- ╔══════════════════════════════════════════════════════════════╗
-- ║  Navigation & File Management — Phase 3                    ║
-- ║  neo-tree, telescope, telescope-fzf-native, persistence    ║
-- ╚══════════════════════════════════════════════════════════════╝
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

		-- Don't lazy-load neo-tree. It handles its own deferred loading
		-- internally (the .lazy.lua file in the repo). Setting lazy = false
		-- here means lazy.nvim will install it, but neo-tree itself won't
		-- create its UI until you call :Neotree or it detects a directory arg.
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

			-- Show open buffers in the tree panel (like JetBrains' "Open Files" tab).
			{
				"<leader>be",
				function()
					require("neo-tree.command").execute({
						toggle = true,
						source = "buffers",
						position = "right",
					})
				end,
				desc = "Buffer Explorer (root dir)",
			},

			-- Show git status in the tree panel (changed/staged/untracked files).
			{
				"<leader>ge",
				function()
					require("neo-tree.command").execute({
						toggle = true,
						source = "git_status",
					})
				end,
				desc = "Git Explorer",
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

			-- Auto-open neo-tree when Neovim starts.
			vim.api.nvim_create_autocmd("BufEnter", {
				group = vim.api.nvim_create_augroup("neotree_start_open", { clear = true }),
				desc = "Open Neo-tree when nvim opens",
				once = true,
				callback = function()
					vim.cmd("Neotree show")
				end,
			})
		end,
	},

	-- ┌──────────────────────────────────────────────────────────┐
	-- │  telescope.nvim                                          │
	-- │  Repo: https://github.com/nvim-telescope/telescope.nvim  │
	-- │  Docs: :h telescope.nvim                                 │
	-- │  The Swiss Army knife fuzzy finder. Find files, grep      │
	-- │  text, browse buffers, search help tags, and much more.   │
	-- │                                                           │
	-- │  Requirements (already installed per your setup):          │
	-- │  - ripgrep: used by live_grep and grep_string             │
	-- │  - fd: used as an alternative to `find` for find_files    │
	-- │  - fzf-native: C-compiled sorter for much faster fuzzy    │
	-- │    matching (see telescope-fzf-native below)              │
	-- │                                                           │
	-- │  Dependencies:                                            │
	-- │  - plenary.nvim (required): async utilities               │
	-- └──────────────────────────────────────────────────────────┘
	{
		"nvim-telescope/telescope.nvim",

		-- Use latest stable. Telescope has only made one release tag,
		-- so we track HEAD (main branch) which is the recommended approach.
		-- See: https://github.com/nvim-telescope/telescope.nvim#installation
		version = false,

		dependencies = {
			"nvim-lua/plenary.nvim",

			-- telescope-fzf-native: compiled C sorter that replaces the
			-- default Lua sorter. Makes fuzzy matching significantly faster,
			-- especially in large projects. Requires `make` to build.
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},

		-- Lazy-load on the :Telescope command. This means telescope's Lua
		-- modules aren't loaded until you actually invoke a picker.
		cmd = "Telescope",

		-- ── Keymaps ──────────────────────────────────────────
		-- Documented in keymaps.lua under "Find/Search (<leader>f)".
		-- Each keymap triggers lazy-loading of telescope.
		keys = {
			-- ── Files ────────────────────────────────────────
			-- Find files by name. Uses fd (installed) for fast file discovery,
			-- respects .gitignore by default.
			{
				"<leader><space>",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Find files",
			},

			-- Find recently opened files. Useful for jumping back to something
			-- you were working on.
			{
				"<leader>fr",
				function()
					require("telescope.builtin").oldfiles()
				end,
				desc = "Recent files",
			},

			-- ── Text Search ──────────────────────────────────
			-- Live grep: type a pattern and see real-time results across the
			-- entire project. This is the Ctrl+Shift+F equivalent from Rider.
			-- Uses ripgrep under the hood.
			{
				"<leader>fg",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live grep (project)",
			},

			-- Search for the word currently under the cursor across the project.
			-- Like Rider's "Find Usages" but broader (plain text, not semantic).
			{
				"<leader>fw",
				function()
					require("telescope.builtin").grep_string()
				end,
				desc = "Grep word under cursor",
			},

			-- ── Buffers ──────────────────────────────────────
			-- Fuzzy-find across open buffers. Faster than cycling with Shift+H/L
			-- when you have many buffers open.
			{
				"<leader>fb",
				function()
					require("telescope.builtin").buffers({
						sort_mru = true, -- most recently used first
						ignore_current_buffer = false, -- Include the current buffer
					})
				end,
				desc = "Find buffers",
			},

			-- ── Help / Meta ──────────────────────────────────
			-- Search through Neovim help tags. Incredible for learning vim — type
			-- a concept and jump straight to the relevant help page.
			{
				"<leader>fh",
				function()
					require("telescope.builtin").help_tags()
				end,
				desc = "Help tags",
			},

			-- Search through all available keymaps (from plugins, your config, etc.).
			-- Complements which-key by letting you fuzzy-search bindings.
			{
				"<leader>fk",
				function()
					require("telescope.builtin").keymaps()
				end,
				desc = "Keymaps",
			},

			-- Search through Neovim command history.
			{
				"<leader>fc",
				function()
					require("telescope.builtin").command_history()
				end,
				desc = "Command history",
			},

			-- Search through diagnostic messages (errors, warnings).
			-- This will become much more useful once LSP is set up in Phase 5.
			{
				"<leader>fd",
				function()
					require("telescope.builtin").diagnostics()
				end,
				desc = "Diagnostics",
			},

			-- Resume the last telescope picker with its previous state.
			-- Extremely useful when you accidentally close a picker.
			{
				"<leader>f.",
				function()
					require("telescope.builtin").resume()
				end,
				desc = "Resume last picker",
			},

			-- Fuzzy-find in the current buffer (like Ctrl+F in an editor
			-- but with fuzzy matching and a preview).
			{
				"<leader>/",
				function()
					require("telescope.builtin").current_buffer_fuzzy_find()
				end,
				desc = "Fuzzy search in buffer",
			},
		},

		config = function(_, opts)
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			-- Merge any opts passed from lazy.nvim with our config function.
			-- We use config (not just opts) because we need to call
			-- load_extension() after setup, which requires imperative code.
			telescope.setup(vim.tbl_deep_extend("force", opts or {}, {
				defaults = {
					-- ── Layout ───────────────────────────────
					-- "horizontal" puts the preview on the right (like VS Code search).
					-- Other options: "vertical" (preview below), "flex" (auto-switch).
					layout_strategy = "horizontal",

					layout_config = {
						horizontal = {
							-- Preview takes 55% of the window width.
							preview_width = 0.55,
							-- Don't show preview if the window is narrower than this.
							preview_cutoff = 120,
						},
						-- Use 80% of the screen width and 80% of the height.
						width = 0.80,
						height = 0.80,
					},

					-- ── Behavior ─────────────────────────────
					-- Start in insert mode (ready to type immediately).
					-- This is the expected behavior for a fuzzy finder.
					prompt_prefix = "   ",
					selection_caret = "  ",

					-- What to do when results overflow: `cycle` wraps from bottom to top.
					scroll_strategy = "cycle",

					-- How paths are displayed in results. "smart" truncates long paths
					-- intelligently, showing the most relevant parts.
					path_display = { "smart" },

					-- ── Sorting ──────────────────────────────
					-- fzf-native will be set as the sorter via the extension below.
					-- This gives us much faster fuzzy matching.
					sorting_strategy = "ascending",

					-- Put the prompt (input line) at the top. Combined with
					-- ascending sorting, results appear below the prompt and
					-- grow downward. This is the modern convention.
					-- (Matches VS Code, fzf, and other modern fuzzy finders.)

					-- ── File Ignore ──────────────────────────
					-- Patterns to exclude from find_files results.
					-- These are passed to the underlying file finder (fd/ripgrep).
					file_ignore_patterns = {
						"node_modules",
						".git/",
						"%.lock",
						"bin/Debug",
						"bin/Release",
						"obj/",
						"dist/",
					},

					-- ── Keymaps inside telescope ─────────────
					-- These apply INSIDE the telescope popup (not globally).
					mappings = {
						i = {
							-- Use Ctrl+j/k to move up/down in results (insert mode).
							-- More ergonomic than arrow keys.
							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,

							-- Send results to quickfix list with Ctrl+q.
							-- Useful for grep results you want to iterate through.
							["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

							-- Scroll the preview pane.
							["<C-d>"] = actions.preview_scrolling_down,
							["<C-u>"] = actions.preview_scrolling_up,

							-- Close with Esc (default, but explicit for clarity).
							["<Esc>"] = actions.close,
						},
						n = {
							-- In normal mode, q also closes (vim convention).
							["q"] = actions.close,
						},
					},
				},

				pickers = {
					-- ── Per-picker overrides ─────────────────
					find_files = {
						-- Show hidden files (dotfiles). fd's --hidden flag.
						-- We still respect .gitignore via fd's default behavior.
						hidden = true,
					},

					live_grep = {
						-- Pass extra args to ripgrep for live_grep.
						additional_args = function()
							return {
								"--hidden", -- search in dotfiles
								"--glob",
								"!.git/", -- but exclude .git directory
							}
						end,
					},
				},

				extensions = {
					-- fzf-native extension config.
					-- These are the default values — included explicitly so you
					-- know what's available to tweak.
					fzf = {
						fuzzy = true, -- enable fuzzy matching (not just exact)
						override_generic_sorter = true, -- replace the default sorter
						override_file_sorter = true, -- replace the file sorter too
						case_mode = "smart_case", -- smart case like vim's ignorecase+smartcase
					},
				},
			}))

			-- Load the fzf-native extension. This MUST happen after setup().
			-- It replaces telescope's Lua-based sorter with the compiled C one.
			telescope.load_extension("fzf")
		end,
	},
}
