-- ╔════════════════════════════════════════════════════════════════════════════════╗
-- ║  Heirline — Statusline, Tabline, Winbar                                      ║
-- ║  Repo: https://github.com/rebelot/heirline.nvim                              ║
-- ║  Cookbook: https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md  ║
-- ║                                                                              ║
-- ║  Adds: winbar (per-window breadcrumbs/info)                                  ║
-- ║                                                                              ║
-- ║  All three areas (tabline, winbar, cursor) change color with mode.           ║
-- ║  Macro recording triggers red outlines and red winbar.                       ║
-- ╚════════════════════════════════════════════════════════════════════════════════╝

return {
	{
		"rebelot/heirline.nvim",
		event = "UIEnter",

		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		config = function()
			local conditions = require("heirline.conditions")
			local utils = require("heirline.utils")

			-- ╔══════════════════════════════════════════════════════════════╗
			-- ║  Section 1: Color Palette & Mode Map                       ║
			-- ╚══════════════════════════════════════════════════════════════╝

			vim.g.heirline_color_palette = {
				sumiInk0  = "#16161D",
				sumiInk1  = "#181820",
				sumiInk2  = "#1a1a22",
				sumiInk3  = "#363646",
				sumiInk4  = "#54546D",
				fujiGray  = "#727169",
				oldWhite  = "#C8C093",
				fujiWhite = "#DCD7BA",

				crystalBlue   = "#7E9CD8",
				springGreen   = "#98BB6C",
				oniViolet     = "#957FB8",
				peachRed      = "#FF5D62",
				samuraiRed    = "#E82424",
				surimiOrange  = "#FFA066",
				waveAqua2     = "#7AA89F",
				carpYellow    = "#E6C384",
				autumnGreen   = "#76946A",
				autumnRed     = "#C34043",
				autumnYellow  = "#DCA561",
				springViolet1 = "#938AA9",
				waveBlue1     = "#223249",
			}

			-- Map the first character of mode() to a color.
			-- Used by statusline mode indicator, tabline active tab, winbar accent, and cursor.
			local mode_color_map = {
				n     = vim.g.heirline_color_palette.crystalBlue,
				i     = vim.g.heirline_color_palette.springGreen,
				v     = vim.g.heirline_color_palette.oniViolet,
				V     = vim.g.heirline_color_palette.oniViolet,
				["\22"] = vim.g.heirline_color_palette.oniViolet,  -- Visual Block (Ctrl-V = char 22)
				c     = vim.g.heirline_color_palette.waveAqua2,
				s     = vim.g.heirline_color_palette.surimiOrange,
				S     = vim.g.heirline_color_palette.surimiOrange,
				["\19"] = vim.g.heirline_color_palette.surimiOrange, -- Select Block (Ctrl-S = char 19)
				R     = vim.g.heirline_color_palette.peachRed,
				r     = vim.g.heirline_color_palette.peachRed,
				["!"] = vim.g.heirline_color_palette.waveAqua2,
				t     = vim.g.heirline_color_palette.surimiOrange,
			}

			--- Get the mode color for the current mode.
			--- Falls back to crystalBlue (Normal) for unknown modes.
			local function get_mode_color()
				local mode = vim.fn.mode(1):sub(1, 1)
				return mode_color_map[mode] or vim.g.heirline_color_palette.crystalBlue
			end

			-- Human-readable mode names for the statusline indicator
			local mode_names = {
				n = "NORMAL", no = "O-PEND", nov = "O-PEND", noV = "O-PEND",
				["no\22"] = "O-PEND", niI = "NORMAL", niR = "NORMAL", niV = "NORMAL",
				nt = "NORMAL", ntT = "NORMAL",
				v = "VISUAL", vs = "VISUAL", V = "V-LINE", Vs = "V-LINE",
				["\22"] = "V-BLOCK", ["\22s"] = "V-BLOCK",
				s = "SELECT", S = "S-LINE", ["\19"] = "S-BLOCK",
				i = "INSERT", ic = "INSERT", ix = "INSERT",
				R = "REPLACE", Rc = "REPLACE", Rx = "REPLACE",
				Rv = "V-REPL", Rvc = "V-REPL", Rvx = "V-REPL",
				c = "COMMAND", cv = "EX", ce = "EX",
				r = "PROMPT", rm = "MORE", ["r?"] = "CONFIRM",
				["!"] = "SHELL", t = "TERMINAL",
			}

			-- Spacer/alignment helpers
			local Space = { provider = " " }
			local Align = { provider = "%=" }

			-- ╔══════════════════════════════════════════════════════════════╗
			-- ║  Section 2: Statusline Components — LEFT                   ║
			-- ╚══════════════════════════════════════════════════════════════╝

			-- ── 2.1 Mode Indicator ───────────────────────────────────────
			local ViMode = {
				init = function(self)
					self.mode = vim.fn.mode(1)
				end,
				provider = function(self)
					local name = mode_names[self.mode] or self.mode
					return " " .. name .. " "
				end,
				hl = function()
					return { fg = vim.g.heirline_color_palette.sumiInk0, bg = get_mode_color(), bold = true }
				end,
				update = {
					"ModeChanged",
					pattern = "*:*",
					callback = vim.schedule_wrap(function()
						vim.cmd("redrawstatus")
					end),
				},
			}

			-- ── 2.2 Macro Recording (shown after mode when recording) ────
			local MacroRec = {
				condition = function()
					return vim.fn.reg_recording() ~= ""
				end,
				provider = function()
					return "  REC @" .. vim.fn.reg_recording() .. " "
				end,
				hl = { fg = vim.g.heirline_color_palette.sumiInk0, bg = vim.g.heirline_color_palette.samuraiRed, bold = true },
				update = { "RecordingEnter", "RecordingLeave" },
			}

			-- ── 2.3 Git Branch ───────────────────────────────────────────
			-- Uses gitsigns data when available (Phase 7), falls back to
			-- reading .git/HEAD directly for the branch name.
			local GitBranch = {
				condition = function()
					-- gitsigns sets vim.b.gitsigns_head when in a git repo.
					-- Before gitsigns is installed, we check for .git/HEAD.
					if vim.b.gitsigns_head then
						return true
					end
					local cwd = vim.uv.cwd() or ""
					local f = io.open(cwd .. "/.git/HEAD", "r")
					if f then
						f:close()
						return true
					end
					return false
				end,
				provider = function()
					local branch = vim.b.gitsigns_head
					if not branch or branch == "" then
						-- Fallback: read .git/HEAD
						local cwd = vim.uv.cwd() or ""
						local f = io.open(cwd .. "/.git/HEAD", "r")
						if not f then
							return ""
						end
						local content = f:read("*l") or ""
						f:close()
						branch = content:match("ref: refs/heads/(.+)") or "detached"
					end
					return "  " .. branch .. " "
				end,
				hl = { fg = vim.g.heirline_color_palette.carpYellow, bold = true },
			}

			-- ── 2.4 File Info (icon + relative path + modified/readonly) ─
			local FileIcon = {
				init = function(self)
					local filename = vim.api.nvim_buf_get_name(0)
					local extension = vim.fn.fnamemodify(filename, ":e")
					self.icon, self.icon_color = require("nvim-web-devicons")
						.get_icon_color(filename, extension, { default = true })
				end,
				provider = function(self)
					return self.icon and (" " .. self.icon .. " ") or " "
				end,
				hl = function(self)
					return { fg = self.icon_color }
				end,
			}

			local FileName = {
				init = function(self)
					self.filename = vim.api.nvim_buf_get_name(0)
				end,
				provider = function(self)
					if self.filename == "" then
						return "[No Name]"
					end
					-- Relative path from cwd
					local rel = vim.fn.fnamemodify(self.filename, ":.")
					-- Shorten if it would take too much space
					if not conditions.width_percent_below(#rel, 0.30) then
						rel = vim.fn.pathshorten(rel)
					end
					return rel
				end,
				hl = function()
					if vim.bo.modified then
						return { fg = vim.g.heirline_color_palette.carpYellow, bold = true }
					end
					return { fg = vim.g.heirline_color_palette.fujiWhite }
				end,
			}

			local FileFlags = {
				-- Modified indicator
				{
					condition = function()
						return vim.bo.modified
					end,
					provider = " ●",
					hl = { fg = vim.g.heirline_color_palette.carpYellow },
				},
				-- Readonly indicator
				{
					condition = function()
						return not vim.bo.modifiable or vim.bo.readonly
					end,
					provider = " ",
					hl = { fg = vim.g.heirline_color_palette.peachRed },
				},
			}

			local FileBlock = { FileIcon, FileName, FileFlags, Space }

			-- ── 2.5 Encoding & File Format ───────────────────────────────
			-- Always shown. Red background when not utf-8 or not unix.
			local FileEncoding = {
				provider = function()
					local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
					local fmt = vim.bo.fileformat
					return " " .. enc:upper() .. "[" .. fmt .. "] "
				end,
				hl = function()
					local enc = ((vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc):lower()
					local fmt = vim.bo.fileformat
					if enc ~= "utf-8" or fmt ~= "unix" then
						-- Red alert: non-standard encoding or format
						return { fg = vim.g.heirline_color_palette.fujiWhite, bg = vim.g.heirline_color_palette.samuraiRed, bold = true }
					end
					return { fg = vim.g.heirline_color_palette.fujiGray }
				end,
			}

			-- ── 2.6 Git Diff Stats ───────────────────────────────────────
			-- Uses gitsigns data (vim.b.gitsigns_status_dict).
			-- Won't render until gitsigns is installed (Phase 7).
			local GitDiff = {
				condition = function()
					return vim.b.gitsigns_status_dict ~= nil
				end,
				init = function(self)
					local d = vim.b.gitsigns_status_dict
					self.added = d.added or 0
					self.changed = d.changed or 0
					self.removed = d.removed or 0
					self.has_changes = (self.added + self.changed + self.removed) > 0
				end,
				{
					provider = function(self)
						return self.added > 0 and (" " .. self.added) or ""
					end,
					hl = { fg = vim.g.heirline_color_palette.autumnGreen },
				},
				{
					provider = function(self)
						return self.changed > 0 and (" " .. self.changed) or ""
					end,
					hl = { fg = vim.g.heirline_color_palette.autumnYellow },
				},
				{
					provider = function(self)
						return self.removed > 0 and (" " .. self.removed) or ""
					end,
					hl = { fg = vim.g.heirline_color_palette.autumnRed },
				},
				Space,
			}

			-- ── 2.7 Diagnostics ──────────────────────────────────────────
			-- Real diagnostics when available, greyed placeholder otherwise.
			local Diagnostics = {
				condition = conditions.has_diagnostics,
				init = function(self)
					self.errors   = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
					self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
					self.info     = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
					self.hints    = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
				end,
				update = { "DiagnosticChanged", "BufEnter" },
				{
					provider = function(self)
						return self.errors > 0 and (" " .. self.errors .. " ") or ""
					end,
					hl = { fg = vim.g.heirline_color_palette.samuraiRed },
				},
				{
					provider = function(self)
						return self.warnings > 0 and (" " .. self.warnings .. " ") or ""
					end,
					hl = { fg = vim.g.heirline_color_palette.carpYellow },
				},
				{
					provider = function(self)
						return self.info > 0 and (" " .. self.info .. " ") or ""
					end,
					hl = { fg = vim.g.heirline_color_palette.waveAqua2 },
				},
				{
					provider = function(self)
						return self.hints > 0 and ("󰛨 " .. self.hints .. " ") or ""
					end,
					hl = { fg = vim.g.heirline_color_palette.springViolet1 },
				},
			}

			-- Placeholder shown when no diagnostics exist (until Phase 5 LSP)
			local DiagnosticsPlaceholder = {
				condition = function()
					return not conditions.has_diagnostics()
				end,
				provider = "  ·  ·  · 󰛨 · ",
				hl = { fg = vim.g.heirline_color_palette.sumiInk4 },
			}

			-- ── 2.8 Search Count ─────────────────────────────────────────
			local SearchCount = {
				condition = function()
					return vim.v.hlsearch ~= 0
				end,
				init = function(self)
					local ok, search = pcall(vim.fn.searchcount, { maxcount = 9999 })
					if ok and search.total then
						self.search = search
					end
				end,
				provider = function(self)
					if not self.search or self.search.total == 0 then
						return ""
					end
					return string.format("  %d/%d ", self.search.current, self.search.total)
				end,
				hl = { fg = vim.g.heirline_color_palette.surimiOrange, bold = true },
			}

			-- ╔══════════════════════════════════════════════════════════════╗
			-- ║  Section 3: Statusline Components — RIGHT                  ║
			-- ╚══════════════════════════════════════════════════════════════╝

			-- ── 3.1 Lazy.nvim Update Count ───────────────────────────────
			local LazyUpdates = {
				condition = function()
					local ok, lazy_status = pcall(require, "lazy.status")
					return ok and lazy_status.has_updates()
				end,
				provider = function()
					return " 󰒲 " .. require("lazy.status").updates() .. " "
				end,
				hl = { fg = vim.g.heirline_color_palette.surimiOrange },
				on_click = {
					callback = function()
						vim.cmd("Lazy")
					end,
					name = "heirline_lazy_click",
				},
			}

			-- ── 3.2 Auto-Session Name ────────────────────────────────────
			local SessionName = {
				provider = function()
					local ok, lib = pcall(require, "auto-session.lib")
					if not ok then
						return ""
					end
					local name = lib.current_session_name(true)
					if not name or name == "" then
						return ""
					end
					return "  " .. name .. " "
				end,
				hl = { fg = vim.g.heirline_color_palette.springViolet1 },
			}

			-- ── 3.3 Indent Style ─────────────────────────────────────────
			-- Shows "SPC:4" or "TAB:4" so you always know the buffer's indent.
			local IndentStyle = {
				provider = function()
					if vim.bo.expandtab then
						return " SPC:" .. vim.bo.shiftwidth .. " "
					else
						return " TAB:" .. vim.bo.shiftwidth .. " "
					end
				end,
				hl = { fg = vim.g.heirline_color_palette.fujiGray },
			}

			-- ── 3.4 DAP Status (Placeholder) ────────────────────────────
			-- Greyed out until Phase 6 wires up nvim-dap.
			-- When DAP is active, this will show the debug status.
			local DAPStatus = {
				condition = function()
					local ok, dap = pcall(require, "dap")
					return ok and dap.session() ~= nil
				end,
				provider = function()
					return "  " .. require("dap").status() .. " "
				end,
				hl = { fg = vim.g.heirline_color_palette.peachRed, bold = true },
			}

			local DAPPlaceholder = {
				condition = function()
					local ok, dap = pcall(require, "dap")
					return not ok or dap.session() == nil
				end,
				provider = "  DAP ",
				hl = { fg = vim.g.heirline_color_palette.sumiInk4 },
			}

			-- ── 3.5 LSP Client Names (Placeholder) ──────────────────────
			-- Greyed out until Phase 5 configures LSP servers.
			local LSPActive = {
				condition = conditions.lsp_attached,
				update = { "LspAttach", "LspDetach" },
				provider = function()
					local names = {}
					for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
						table.insert(names, server.name)
					end
					return "  " .. table.concat(names, ", ") .. " "
				end,
				hl = { fg = vim.g.heirline_color_palette.springGreen, bold = true },
			}

			local LSPPlaceholder = {
				condition = function()
					return not conditions.lsp_attached()
				end,
				provider = "  LSP ",
				hl = { fg = vim.g.heirline_color_palette.sumiInk4 },
			}

			-- ── 3.6 Treesitter Status (Placeholder) ─────────────────────
			-- Shows if treesitter highlighting is active for the buffer.
			local TreesitterStatus = {
				condition = function()
					local buf = vim.api.nvim_get_current_buf()
					local ok, _ = pcall(vim.treesitter.get_parser, buf)
					return ok
				end,
				provider = "  TS ",
				hl = { fg = vim.g.heirline_color_palette.springGreen },
			}

			local TreesitterPlaceholder = {
				condition = function()
					local buf = vim.api.nvim_get_current_buf()
					local ok, _ = pcall(vim.treesitter.get_parser, buf)
					return not ok
				end,
				provider = "  TS ",
				hl = { fg = vim.g.heirline_color_palette.sumiInk4 },
			}

			-- ── 3.7 File Progress ────────────────────────────────────────
			local FileProgress = {
				provider = " %3p%% ",
				hl = { fg = vim.g.heirline_color_palette.fujiWhite },
			}

			-- ── 3.8 Cursor Position ──────────────────────────────────────
			local CursorPosition = {
				provider = " %l:%c ",
				hl = function()
					return { fg = vim.g.heirline_color_palette.sumiInk0, bg = get_mode_color(), bold = true }
				end,
			}

			-- ╔══════════════════════════════════════════════════════════════╗
			-- ║  Section 4: Statusline Assembly                            ║
			-- ╚══════════════════════════════════════════════════════════════╝

			local StatusLine = {
				hl = { bg = vim.g.heirline_color_palette.sumiInk1 },

				-- LEFT
				ViMode,
				MacroRec,
				GitBranch,
				FileBlock,
				FileEncoding,
				GitDiff,
				Diagnostics,
				DiagnosticsPlaceholder,
				SearchCount,

				-- CENTER (push right side to the right)
				Align,

				-- RIGHT
				LazyUpdates,
				SessionName,
				IndentStyle,
				DAPStatus,
				DAPPlaceholder,
				LSPActive,
				LSPPlaceholder,
				TreesitterStatus,
				TreesitterPlaceholder,
				FileProgress,
				CursorPosition,
			}

			-- ╔══════════════════════════════════════════════════════════════╗
			-- ║  Section 5: Tabline (Buffer Tabs)                          ║
			-- ╚══════════════════════════════════════════════════════════════╝
			-- Replaces bufferline.nvim. Shows open buffers as clickable tabs.
			-- Active tab background matches the current mode color.

			-- Offset for neo-tree sidebar — pushes buffer tabs to the right
			-- so they don't overlap the file tree.
			local TablineOffset = {
				condition = function(self)
					local win = vim.api.nvim_tabpage_list_wins(0)[1]
					if not win or not vim.api.nvim_win_is_valid(win) then
						return false
					end
					local bufnr = vim.api.nvim_win_get_buf(win)
					if vim.bo[bufnr].filetype == "neo-tree" then
						self.winid = win
						return true
					end
					return false
				end,
				provider = function(self)
					local width = vim.api.nvim_win_get_width(self.winid)
					local title = " Explorer"
					local pad = math.max(width - #title, 0)
					return title .. string.rep(" ", pad)
				end,
				hl = { fg = vim.g.heirline_color_palette.fujiWhite, bg = vim.g.heirline_color_palette.sumiInk2, bold = true },
			}

			-- Individual buffer tab component (used inside make_buflist)
			local TablineBufnr = {
				provider = function(self)
					-- Show ordinal position for <leader>b1-9 jumping
					if self._buflist_ordinal then
						return self._buflist_ordinal .. "."
					end
					return ""
				end,
				hl = { fg = vim.g.heirline_color_palette.fujiGray },
			}

			local TablineFileIcon = {
				init = function(self)
					local filename = self.filename
					local extension = vim.fn.fnamemodify(filename, ":e")
					self.icon, self.icon_color = require("nvim-web-devicons")
						.get_icon_color(filename, extension, { default = true })
				end,
				provider = function(self)
					return self.icon and (self.icon .. " ") or ""
				end,
				hl = function(self)
					if self.is_active then
						return { fg = self.icon_color }
					end
					return { fg = vim.g.heirline_color_palette.fujiGray }
				end,
			}

			local TablineFileName = {
				provider = function(self)
					local name = self.filename
					if name == "" then
						return "[No Name]"
					end
					return vim.fn.fnamemodify(name, ":t")
				end,
				hl = function(self)
					if self.is_active then
						return { bold = true }
					end
					return {}
				end,
			}

			local TablineFileFlags = {
				{
					condition = function(self)
						return vim.bo[self.bufnr].modified
					end,
					provider = " ●",
					hl = { fg = vim.g.heirline_color_palette.carpYellow },
				},
			}

			-- Harpoon index shown in each buffer tab
			local TablineHarpoon = {
				condition = function(self)
					local ok, helper = pcall(require, "helpers.harpoon-helper")
					if not ok then
						return false
					end
					local idx = helper.get_harpoon_index(self.filename)
					if idx then
						self.harpoon_idx = idx
						return true
					end
					return false
				end,
				provider = function(self)
					return " 󱡀" .. self.harpoon_idx
				end,
				hl = { fg = vim.g.heirline_color_palette.carpYellow },
			}

			-- Close button per tab
			local TablineCloseButton = {
				provider = " 󰅖",
				hl = function(self)
					if self.is_active then
						return { fg = vim.g.heirline_color_palette.fujiGray }
					end
					return { fg = vim.g.heirline_color_palette.sumiInk4 }
				end,
				on_click = {
					callback = function(_, minwid)
						vim.schedule(function()
							require("helpers.buf-helper").delete(minwid)
						end)
					end,
					minwid = function(self)
						return self.bufnr
					end,
					name = "heirline_tabline_close",
				},
			}

			-- Assemble the single buffer tab template
			local TablineBufferBlock = {
				init = function(self)
					self.filename = vim.api.nvim_buf_get_name(self.bufnr)
					-- Calculate ordinal position for display
					local bufs = require("helpers.buf-helper").get_listed_bufs()
					for i, b in ipairs(bufs) do
						if b == self.bufnr then
							self._buflist_ordinal = i
							break
						end
					end
				end,
				hl = function(self)
					if self.is_active then
						-- Active tab uses mode color as background
						return { fg = vim.g.heirline_color_palette.sumiInk0, bg = get_mode_color() }
					elseif self.is_visible then
						return { fg = vim.g.heirline_color_palette.fujiWhite, bg = vim.g.heirline_color_palette.sumiInk3 }
					else
						return { fg = vim.g.heirline_color_palette.fujiGray, bg = vim.g.heirline_color_palette.sumiInk2 }
					end
				end,
				on_click = {
					callback = function(_, minwid, _, button)
						if button == "m" then
							-- Middle-click closes the buffer
							vim.schedule(function()
								require("helpers.buf-helper").delete(minwid)
							end)
						else
							vim.api.nvim_win_set_buf(0, minwid)
						end
					end,
					minwid = function(self)
						return self.bufnr
					end,
					name = "heirline_tabline_buffer_click",
				},
				{ provider = " " }, -- left padding
				TablineBufnr,
				TablineFileIcon,
				TablineFileName,
				TablineFileFlags,
				TablineHarpoon,
				TablineCloseButton,
				{ provider = " " }, -- right padding
			}

			-- Build the buffer list from the template
			local BufferList = utils.make_buflist(
				TablineBufferBlock,
				{ provider = " ", hl = { fg = vim.g.heirline_color_palette.fujiGray } }, -- left truncation
				{ provider = " ", hl = { fg = vim.g.heirline_color_palette.fujiGray } }  -- right truncation
			)

			-- Fill the rest of the tabline with a background color
			local TablineFill = {
				provider = "%=",
				hl = { bg = vim.g.heirline_color_palette.sumiInk1 },
			}

			-- Assemble the complete tabline
			local TabLine = {
				TablineOffset,
				BufferList,
				TablineFill,
			}

			-- ╔══════════════════════════════════════════════════════════════╗
			-- ║  Section 6: Winbar                                         ║
			-- ╚══════════════════════════════════════════════════════════════╝
			-- Shows per-window: mode-colored accent + harpoon index + filename.
			-- During macro recording, the active winbar turns red.

			local WinbarHarpoon = {
				condition = function(self)
					local ok, helper = pcall(require, "helpers.harpoon-helper")
					if not ok then
						return false
					end
					local filename = vim.api.nvim_buf_get_name(0)
					local idx = helper.get_harpoon_index(filename)
					if idx then
						self.harpoon_idx = idx
						return true
					end
					return false
				end,
				provider = function(self)
					return " 󱡀 " .. self.harpoon_idx .. " "
				end,
				hl = function()
					if conditions.is_active() then
						return { fg = vim.g.heirline_color_palette.carpYellow, bold = true }
					end
					return { fg = vim.g.heirline_color_palette.sumiInk4 }
				end,
			}

			local WinbarFileName = {
				init = function(self)
					self.filename = vim.api.nvim_buf_get_name(0)
				end,
				provider = function(self)
					if self.filename == "" then
						return "[No Name]"
					end
					return " " .. vim.fn.fnamemodify(self.filename, ":t") .. " "
				end,
				hl = function()
					if conditions.is_active() then
						if vim.bo.modified then
							return { fg = vim.g.heirline_color_palette.carpYellow, bold = true }
						end
						return { fg = vim.g.heirline_color_palette.fujiWhite }
					end
					return { fg = vim.g.heirline_color_palette.fujiGray }
				end,
			}

			-- Mode accent: thin colored segment on the left of the active winbar.
			-- During macro recording, this turns red.
			local WinbarModeAccent = {
				condition = conditions.is_active,
				provider = "▎",
				hl = function()
					if vim.fn.reg_recording() ~= "" then
						return { fg = vim.g.heirline_color_palette.samuraiRed }
					end
					return { fg = get_mode_color() }
				end,
			}

			local WinBar = {
				-- Disable winbar for special buffer types
				condition = function()
					return not conditions.buffer_matches({
						filetype = { "neo-tree", "noice", "qf", "help", "terminal", "toggleterm", "lazy" },
						buftype = { "nofile", "prompt", "quickfix", "terminal" },
					})
				end,
				hl = function()
					if conditions.is_active() then
						-- During macro recording, red background on active winbar
						if vim.fn.reg_recording() ~= "" then
							return { bg = vim.g.heirline_color_palette.sumiInk3, fg = vim.g.heirline_color_palette.peachRed }
						end
						return { bg = vim.g.heirline_color_palette.sumiInk2 }
					end
					return { bg = vim.g.heirline_color_palette.sumiInk1, fg = vim.g.heirline_color_palette.fujiGray }
				end,
				WinbarModeAccent,
				WinbarHarpoon,
				WinbarFileName,
				Align,
			}

			-- ╔══════════════════════════════════════════════════════════════╗
			-- ║  Section 7: Setup & Theming                                ║
			-- ╚══════════════════════════════════════════════════════════════╝

			require("heirline").setup({
				statusline = StatusLine,
				tabline = TabLine,
				winbar = WinBar,
				opts = {
					-- Disable winbar for these buffer types
					disable_winbar_cb = function(args)
						return conditions.buffer_matches({
							filetype = { "neo-tree", "noice", "qf", "help", "terminal", "toggleterm", "lazy" },
							buftype = { "nofile", "prompt", "quickfix", "terminal" },
						}, args.buf)
					end,
				},
			})

			-- ── Colorscheme reload ───────────────────────────────────────
			-- Reset heirline highlight cache when the colorscheme changes.
			-- This ensures our hardcoded colors don't conflict with dynamic
			-- highlight groups that other plugins might set.
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("heirline_colorscheme", { clear = true }),
				callback = function()
					utils.on_colorscheme()
				end,
			})

			-- ── Macro recording redraw ───────────────────────────────────
			-- Force full UI refresh on recording start/stop so the winbar
			-- and statusline update their recording indicators immediately.
			vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
				group = vim.api.nvim_create_augroup("heirline_macro_redraw", { clear = true }),
				callback = vim.schedule_wrap(function()
					vim.cmd("redrawstatus!")
					vim.cmd("redrawtabline")
				end),
			})
		end,
	},
}
