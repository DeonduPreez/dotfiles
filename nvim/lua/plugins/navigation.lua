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

	-- ┌──────────────────────────────────────────────────────────┐
	-- │  telescope.nvim                                          │
	-- │  Repo: https://github.com/nvim-telescope/telescope.nvim  │
	-- │  Docs: :h telescope.nvim                                 │
	-- │  The Swiss Army knife fuzzy finder. Find files, grep     │
	-- │  text, browse buffers, search help tags, and much more.  │
	-- │                                                          │
	-- │  Requirements (already installed per your setup):        │
	-- │  - ripgrep: used by live_grep and grep_string            │
	-- │  - fd: used as an alternative to `find` for find_files   │
	-- │  - fzf-native: C-compiled sorter for much faster fuzzy   │
	-- │    matching (see telescope-fzf-native below)             │
	-- │                                                          │
	-- │  Dependencies:                                           │
	-- │  - plenary.nvim (required): async utilities              │
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
				"<leader>/",
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
				"<leader>fg",
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
							-- TODO: Check if we can add an action that yoinks the selected item (like <C-y> in)

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

	-- ┌──────────────────────────────────────────────────────────┐
	-- │  auto-session                                            │
	-- │  Repo: https://github.com/rmagatti/auto-session          │
	-- │  Docs: :h auto-session  |  :checkhealth auto-session     │
	-- │  Automatic session management: saves on quit, restores   │
	-- │  on startup, with built-in Telescope picker and git      │
	-- │  branch support.                                         │
	-- │                                                          │
	-- │  Unlike persistence.nvim (which only auto-saves and      │
	-- │  requires manual restore), auto-session handles the      │
	-- │  full lifecycle — save, restore, suppress, branch-swap   │
	-- │  — without custom autocmds.                              │
	-- └──────────────────────────────────────────────────────────┘
	{
		"rmagatti/auto-session",

		-- Must load at startup (not lazy) so it can intercept VimEnter
		-- for auto-restore and VimLeavePre for auto-save.
		lazy = false,

		-- Dependent on telescope
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},

		-- ── Keymaps ──────────────────────────────────────────
		-- Documented in keymaps.lua under "Sessions (<leader>q)".
		keys = {
			-- Search and switch between saved sessions.
			-- Uses Telescope if available (it is), falls back to vim.ui.select.
			{
				"<leader>qs",
				"<cmd>AutoSession search<CR>",
				desc = "Search sessions",
			},

			-- Save the current session manually.
			-- Normally auto-session saves on quit, but this lets you
			-- snapshot the current state at any time.
			{
				"<leader>qS",
				"<cmd>AutoSession save<CR>",
				desc = "Save session",
			},

			-- Toggle auto-save on/off for the current Neovim instance.
			-- Useful when you've opened a bunch of scratch files you
			-- don't want persisted.
			{
				"<leader>qd",
				"<cmd>AutoSession toggle<CR>",
				desc = "Toggle session auto-save",
			},

			-- Delete the session for the current directory.
			-- Useful for cleaning up stale sessions.
			{
				"<leader>qD",
				"<cmd>AutoSession delete<CR>",
				desc = "Delete current session",
			},
		},

		---@module "auto-session"
		---@type AutoSession.Config
		opts = {
			-- ── Saving / restoring ────────────────────────────────
			auto_save = true, -- Enables/disables auto saving session on exit
			auto_restore = true, -- Enables/disables auto restoring session on start
			auto_create = true, -- Enables/disables auto creating new session files. Can be a function that returns true if a new session file should be allowed
			auto_restore_last_session = false, -- On startup, loads the last saved session if session for cwd does not exist
			cwd_change_handling = true, -- Automatically save/restore sessions when changing directories
			single_session_mode = false, -- Enable single session mode to keep all work in one session regardless of cwd changes. When enabled, prevents creation of separate sessions for different directories and maintains one unified session. Does not work with cwd_change_handling

			-- ── Filtering ────────────────────────────────
			suppressed_dirs = {
				"~/",
				"~/Downloads",
				"/tmp",
				"/",
				"C:/",
				"C:/Source",
				"C:/AISource",
			}, -- Suppress session restore/create in certain directories
			allowed_dirs = nil, -- Allow session restore/create in certain directories
			bypass_save_filetypes = { "neo-tree", "noice" }, -- List of filetypes to bypass auto save when the only buffer open is one of the file types listed, useful to ignore dashboards
			close_filetypes_on_save = { "checkhealth" }, -- Buffers with matching filetypes will be closed before saving
			close_unsupported_windows = true, -- Close windows that aren't backed by normal file before autosaving a session
			preserve_buffer_on_restore = nil, -- Function that returns true if a buffer should be preserved when restoring a session

			-- ── Git / Session naming ──────────────────────────
			git_use_branch_name = true, -- Include git branch name in session name, can also be a function that takes an optional path and returns the name of the branch
			git_auto_restore_on_branch_change = true, -- Should we auto-restore the session when the git branch changes. Requires git_use_branch_name
			custom_session_tag = nil, -- Function that can return a string to be used as part of the session name

			-- Deleting
			auto_delete_empty_sessions = true, -- Enables/disables deleting the session if there are only unnamed/empty buffers when auto-saving
			purge_after_minutes = nil, -- Sessions older than purge_after_minutes will be deleted asynchronously on startup, e.g. set to 14400 to delete sessions that haven't been accessed for more than 10 days, defaults to off (no purging), requires >= nvim 0.10

			-- Saving extra data
			-- TODO: Include dap breakpoints and possibly quickfix windows
			save_extra_data = nil, -- Function that returns extra data that should be saved with the session. Will be passed to restore_extra_data on restore
			restore_extra_data = nil, -- Function called when there's extra data saved for a session

			-- Argument handling
			args_allow_single_directory = true, -- Follow normal session save/load logic if launched with a single directory as the only argument
			args_allow_files_auto_save = false, -- Allow saving a session even when launched with a file argument (or multiple files/dirs). It does not load any existing session first. Can be true or a function that returns true when saving is allowed. See documentation for more detail

			-- Misc
			log_level = "error", -- Sets the log level of the plugin (debug, info, warn, error).
			root_dir = vim.fn.stdpath("data") .. "/sessions/", -- Root dir where sessions will be stored
			show_auto_restore_notif = true, -- Whether to show a notification when auto-restoring
			restore_error_handler = nil, -- Function called when there's an error restoring. By default, it ignores fold and help errors otherwise it displays the error and returns false to disable auto_save. Default handler is accessible as require('auto-session').default_restore_error_handler
			continue_restore_on_error = true, -- Keep loading the session even if there's an error
			lsp_stop_on_restore = false, -- Should language servers be stopped when restoring a session. Can also be a function that will be called if set. Not called on autorestore from startup
			lazy_support = true, -- Automatically detect if Lazy.nvim is being used and wait until Lazy is done to make sure session is restored correctly. Does nothing if Lazy isn't being used
			legacy_cmds = true, -- Define legacy commands: Session*, Autosession (lowercase s), currently true. Set to false to prevent defining them

			-- ── Session Picker (Telescope) ───────────────────
			---@type SessionLens
			session_lens = {
				picker = "telescope", -- "telescope"|"snacks"|"fzf"|"select"|nil Pickers are detected automatically but you can also set one manually. Falls back to vim.ui.select
				load_on_setup = true, -- Only used for telescope, registers the telescope extension at startup so you can use :Telescope session-lens
				picker_opts = nil, -- Table passed to Telescope / Snacks / Fzf-Lua to configure the picker. See below for more information
				previewer = "summary", -- 'summary'|'active_buffer'|function - How to display session preview. 'summary' shows a summary of the session, 'active_buffer' shows the contents of the active buffer in the session, or a custom function

				---@type SessionLensMappings
				mappings = {
					-- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
					delete_session = { "i", "<C-d>" }, -- mode and key for deleting a session from the picker
					alternate_session = { "i", "<C-s>" }, -- mode and key for swapping to alternate session from the picker
					copy_session = { "i", "<C-y>" }, -- mode and key for copying a session from the picker
				},

				---@type SessionControl
				session_control = {
					control_dir = vim.fn.stdpath("data") .. "/auto_session/", -- Auto session control dir, for control files, like alternating between two sessions with session-lens
					control_filename = "session_control.json", -- File name of the session control file
				},
			},

			-- ── Hooks ────────────────────────────
			-- After a session is restored, reopen neo-tree.
			-- auto-session closes unsupported windows before saving,
			-- so neo-tree needs to be reopened after restore.
			-- "show" opens it without stealing focus from the editor.

			--- pre_save_cmds? (string|fun(session_name:string): boolean)[] executes before a session is saved, return false to stop auto-saving
			--- post_save_cmds? (string|fun(session_name:string))[] executes after a session is saved
			--- pre_restore_cmds? (string|fun(session_name:string): boolean)[] executes before a session is restored, return false to stop auto-restoring
			--- post_restore_cmds? (string|fun(session_name:string))[] executes after a session is restored
			post_restore_cmds = {
				"Neotree show",
				function()
					local session_name = require("auto-session.lib").current_session_name(true)
					vim.g.sess_name = session_name
					if not session_name then
						session_name = "Unknown"
					end

					require("helpers.wztrm-helper").set_terminal_title(session_name)
				end,
			},

			--- pre_delete_cmds? (string|fun(session_name:string))[] executes before a session is deleted
			--- post_delete_cmds? (string|fun(session_name:string))[] executes after a session is deleted
			--- no_restore_cmds? (string|fun(is_startup:boolean))[] executes when no session is restored when auto-restoring, happens on startup or possibly on cwd/git branch changes
			no_restore_cmds = {
				function(is_startup)
					if not is_startup then
						return
					end

					if vim.g.initial_session_restore_handled then
						return
					end

					vim.g.initial_session_restore_handled = true

					local first_arg = vim.fn.argv(0)
					if not first_arg or first_arg == "" then
						vim.cmd("Neotree show")
						return
					end
					local path_helper = require("helpers.path-helper")
					local path_type = path_helper.check_path_type(first_arg)
					if path_type ~= "directory" then
						return
					end

					vim.cmd("Neotree show")
				end,
			},

			--- pre_cwd_changed_cmds? (string|fun())[] executes before cwd is changed if cwd_change_handling is true
			--- post_cwd_changed_cmds? (string|fun())[] executes after cwd is changed if cwd_change_handling is true
			post_cwd_changed_cmds = {
				function()
					require("lualine").refresh() -- example refreshing the lualine status line _after_ the cwd changes
				end,
			},
			--- save_extra_cmds? (string|fun(session_name:string): string|table|nil)[] executes to get extra data to save with the session
		},
	},
}
