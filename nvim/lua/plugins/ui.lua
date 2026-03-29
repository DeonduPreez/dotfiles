-- ╔══════════════════════════════════════════════════════════════╗
-- ║  UI Plugins — Phase 2                                      ║
-- ║  noice.nvim                                                ║
-- ╚══════════════════════════════════════════════════════════════╝

return {
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
	-- │    markdown, markdown_inline — installed in Phase 5.      │
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
