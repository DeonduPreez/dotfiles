-- ╔══════════════════════════════════════════════════════════════╗
-- ║  UI Plugins — Phase 2                                      ║
-- ║  lualine, bufferline, noice                                ║
-- ╚══════════════════════════════════════════════════════════════╝

return {
	-- ┌──────────────────────────────────────────────────────────┐
	-- │  bufferline.nvim                                         │
	-- │  Repo: https://github.com/akinsho/bufferline.nvim        │
	-- │  Docs: :h bufferline.txt                                 │
	-- │  Renders open buffers as a tab bar at the top of the     │
	-- │  editor — like browser tabs or JetBrains editor tabs.    │
	-- └──────────────────────────────────────────────────────────┘
	{
		"akinsho/bufferline.nvim",
		version = "*", -- use latest stable tag

		dependencies = { "nvim-tree/nvim-web-devicons" },

		-- Load after UI renders, same as lualine.
		event = "VeryLazy",

		-- ── Keymaps ──────────────────────────────────────────
		-- Defined here (not in keymaps.lua) so lazy.nvim can use them
		-- as lazy-load triggers. Documented in keymaps.lua under "Buffers".
		keys = {
			-- Cycle through buffers (like Ctrl+Tab in a browser / Rider).
			{ "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
			{ "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },

			-- Move buffer position in the tab bar (reorder tabs).
			{ "<leader>bh", "<cmd>BufferLineMovePrev<CR>", desc = "Move buffer left" },
			{ "<leader>bl", "<cmd>BufferLineMoveNext<CR>", desc = "Move buffer right" },

			-- Pin a buffer
			{ "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Pin buffer" },

			-- Pick a buffer by letter (like Ace-jump for tabs).
			-- Shows a letter overlay on each tab — press the letter to jump.
			{ "<leader>bj", "<cmd>BufferLinePick<CR>", desc = "Pick buffer" },

			-- Close the current buffer. Uses a safe buffer delete that doesn't close the last buffer and kill vim.
			{
				"<leader>bd",
				function(bufnr)
					require("helpers.buf-helper").delete(bufnr)
				end,
				desc = "Delete buffer",
			},
			-- Force close the current buffer. We're still not closing the IDE.
			{
				"<leader>bD",
				function(bufnr)
					require("helpers.buf-helper").force_delete(bufnr)
				end,
				desc = "Force delete buffer",
			},

			-- Close all buffers except the current one.
			{ "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Close other buffers" },

			-- Close buffers to the left/right of the current one.
			{ "<leader>bL", "<cmd>BufferLineCloseRight<CR>", desc = "Close buffers to the right" },
			{ "<leader>bH", "<cmd>BufferLineCloseLeft<CR>", desc = "Close buffers to the left" },

			-- Jump to buffer by ordinal position (first, second, third, etc.).
			{ "<leader>b1", "<cmd>BufferLineGoToBuffer 1<CR>", desc = "Go to buffer 1" },
			{ "<leader>b2", "<cmd>BufferLineGoToBuffer 2<CR>", desc = "Go to buffer 2" },
			{ "<leader>b3", "<cmd>BufferLineGoToBuffer 3<CR>", desc = "Go to buffer 3" },
			{ "<leader>b4", "<cmd>BufferLineGoToBuffer 4<CR>", desc = "Go to buffer 4" },
			{ "<leader>b5", "<cmd>BufferLineGoToBuffer 5<CR>", desc = "Go to buffer 5" },
			{ "<leader>b6", "<cmd>BufferLineGoToBuffer 6<CR>", desc = "Go to buffer 6" },
			{ "<leader>b7", "<cmd>BufferLineGoToBuffer 7<CR>", desc = "Go to buffer 7" },
			{ "<leader>b8", "<cmd>BufferLineGoToBuffer 8<CR>", desc = "Go to buffer 8" },
			{ "<leader>b9", "<cmd>BufferLineGoToBuffer 9<CR>", desc = "Go to buffer 9" },
			{ "<leader>b10", "<cmd>BufferLineGoToBuffer 10<CR>", desc = "Go to buffer 10" },
		},

		opts = {
			options = {
				-- One tab per open file.
				mode = "buffers",

				-- Available styles: "slant", "slope", "thick", "padded_slant", "thin"
				separator_style = "thin",

				-- Show close button on each tab. Clicking it closes the buffer (safely).
				close_command = function(bufnr)
					require("helpers.buf-helper").delete(bufnr, true)
				end,
				right_mouse_command = function(bufnr)
					require("helpers.buf-helper").delete(bufnr, true)
				end,

				-- Show buffer ordinal numbers (1, 2, 3...) for quick jumping.
				-- Combined with <leader>b1, b2, etc. keymaps above.
				numbers = function (opts)
                    if opts.ordinal <= 10 then
                        return opts.ordinal .. "."
                    end
                    return nil
                end,

                name_formatter = function(buf)
                    local idx = require("helpers.harpoon-helper").get_harpoon_index(buf.path)
                    if idx then
                        return buf.name .. " 󱡀 " .. idx
                    end

                    return buf.name
                end,

				-- Show LSP diagnostics in the bufferline (error/warning indicators).
				-- Requires nvim LSP (Phase 5). Until then, shows nothing extra.
				diagnostics = "nvim_lsp",

				-- Custom diagnostic indicator: shows error/warning icons with count.
				-- Only shown on non-current buffers (to reduce noise on active tab).
				---@diagnostic disable-next-line: unused-local
				diagnostics_indicator = function(count, level, diagnostics_dict, context)
					local icons = {
						error = " ",
						warning = " ",
						info = " ",
						hint = " 󰛨",
					}
					local result = ""
					for severity, icon in pairs(icons) do
						local n = diagnostics_dict[severity]
						if n and n > 0 then
							result = result .. icon .. n .. " "
						end
					end
					return vim.trim(result)
				end,

				-- ── Neo-tree offset ──────────────────────────────
				-- When neo-tree (Phase 3) opens as a left sidebar, the bufferline
				-- shifts to the right so tabs don't overlap the file tree.
				-- This creates a clean visual separation like JetBrains' project panel.
				offsets = {
					{
						filetype = "neo-tree",
						text = "Explorer",
						highlight = "Directory",
						text_align = "left",
						separator = true, -- thin line between neo-tree and bufferline
					},
				},

				-- Show the close icon on the right end of the bufferline.
				show_close_icon = false, -- we use keymaps instead; saves space
				show_buffer_close_icons = true, -- show X on individual tabs

				-- When a buffer's name collides with another (e.g., two "index.ts" files),
				-- show enough of the directory path to disambiguate them.
				-- This is the Rider/WebStorm behavior for duplicate filenames.
				enforce_regular_tabs = false,

				-- Don't show the bufferline when there's only 1 buffer open.
				-- Saves vertical space until you actually have multiple files open.
				always_show_bufferline = true,

				-- Sort buffers by their buffer number (insertion order).
				-- This means new files appear at the end, matching the mental model
				-- of "I opened this file, it goes to the right."
				sort_by = "insert_at_end",
			},
		},

		config = function(_, opts)
			require("bufferline").setup(opts)

			-- Fix bufferline when restoring a session (Phase 3: persistence.nvim).
			-- After a session restore, buffers are loaded in bulk and the bufferline
			-- might not update correctly. This autocmd forces a refresh.
			vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
				callback = function()
					vim.schedule(function()
						---@diagnostic disable-next-line: param-type-mismatch
						pcall(nvim_bufferline)
					end)
				end,
			})
		end,
	},

	-- ┌──────────────────────────────────────────────────────────┐
	-- │  noice.nvim                                              │
	-- │  Repo: https://github.com/folke/noice.nvim               │
	-- │  Docs: :h noice.nvim.txt                                 │
	-- │  Replaces the command line, messages, and popupmenu with  │
	-- │  a modern floating UI. Also provides a notification       │
	-- │  system used by other plugins (lazy.nvim, LSP, etc.).     │
	-- │                                                           │
	-- │  Dependencies:                                            │
	-- │  - nui.nvim (required): UI component library              │
	-- │  - nvim-notify (optional): we skip it — noice's built-in  │
	-- │    "mini" view handles notifications with less overhead.   │
	-- │  - treesitter parsers (optional): vim, regex, lua, bash,  │
	-- │    markdown, markdown_inline — installed in Phase 5. Until │
	-- │    then, cmdline won't have syntax highlighting but works. │
	-- └──────────────────────────────────────────────────────────┘
	{
		"folke/noice.nvim",
		event = "VeryLazy",

		dependencies = {
			-- nui.nvim: provides the floating window primitives that noice
			-- uses to render the cmdline popup, notifications, etc.
			"MunifTanjim/nui.nvim",
		},

		-- ── Keymaps ──────────────────────────────────────────
		-- Documented in keymaps.lua under "Notifications (<leader>n)".
		keys = {
			-- Scroll forward/backward in hover docs and signature help.
			-- These work when an LSP hover popup or signature help is visible.
			{
				"<c-f>",
				function()
					if not require("noice.lsp").scroll(4) then
						return "<c-f>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll forward (noice)",
				mode = { "i", "n", "s" },
			},
			{
				"<c-b>",
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<c-b>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll backward (noice)",
				mode = { "i", "n", "s" },
			},

			-- Redirect a cmdline command's output to a popup window.
			-- Useful for commands that produce a lot of output (e.g., :messages).
			{
				"<S-Enter>",
				function()
					require("noice").redirect(vim.fn.getcmdline())
				end,
				mode = "c",
				desc = "Redirect cmdline (noice)",
			},

			-- Show the last notification message.
			{
				"<leader>nl",
				function()
					require("noice").cmd("last")
				end,
				desc = "Last message",
			},

			-- Show full notification history.
			{
				"<leader>nh",
				function()
					require("noice").cmd("history")
				end,
				desc = "Message history",
			},

			-- Show all messages (including dismissed ones).
			{
				"<leader>na",
				function()
					require("noice").cmd("all")
				end,
				desc = "All messages",
			},

			-- Dismiss all visible notifications.
			{
				"<leader>nd",
				function()
					require("noice").cmd("dismiss")
				end,
				desc = "Dismiss all",
			},
		},

		opts = {
			-- ── LSP Overrides ────────────────────────────────
			-- These let noice handle LSP hover docs and signature help
			-- rendering, which gives them the same floating UI treatment
			-- as the cmdline. Requires treesitter for markdown highlighting.
			lsp = {
				signature = {
					-- TODO : Fix this when we get to Phase 5 - LSP setup
					enabled = false,
				},
				override = {
					-- Replace the default LSP markdown renderer with noice's.
					-- This gives hover docs and signature help a cleaner look
					-- with proper syntax highlighting (once treesitter is set up).
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,

					-- NOTE: We don't override cmp.entry.get_documentation here
					-- because we're using blink.cmp (Phase 5), not nvim-cmp.
					-- blink.cmp handles its own documentation rendering.
				},
			},

			-- ── Routes ───────────────────────────────────────
			-- Routes control how messages are displayed. We suppress some
			-- noisy messages that would otherwise pop up as notifications.
			routes = {
				-- Send common "written" messages (e.g., "42L, 1234B written")
				-- and undo/redo messages to the mini view instead of a full
				-- notification. They flash briefly at the bottom and disappear.
				{
					filter = {
						event = "msg_show",
						any = {
							-- { find = "%d+L, %d+B" }, -- file written messages
							-- { find = "; after #%d+" }, -- undo messages
							-- { find = "; before #%d+" }, -- redo messages
						},
					},
					view = "mini",
				},
			},

			-- ── Presets ──────────────────────────────────────
			-- Presets are pre-built configurations that noice provides
			-- for common setups. Enable the ones that match our preferences.
			presets = {
				-- Move the search (/ and ?) to the bottom of the screen
				-- instead of a floating popup. This feels more natural
				-- for vim muscle memory — search at the bottom, cmdline floating.
				bottom_search = true,

				-- Position the cmdline popup and completion menu together
				-- in the center of the screen (like VS Code's command palette).
				command_palette = true,

				-- Long messages (e.g., LSP error traces) automatically go to a
				-- split buffer instead of a floating window that might be too small.
				long_message_to_split = true,

				-- Add a border to LSP hover docs and signature help popups.
				-- Makes them stand out against the transparent background.
				lsp_doc_border = true,
			},
		},
	},
}
