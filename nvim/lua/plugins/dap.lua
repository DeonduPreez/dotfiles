return {
	-- Core DAP engine
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio", -- required by dap-ui
			"theHamsta/nvim-dap-virtual-text",
		},
		keys = {
			{
				"<leader>dq",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.open()
				end,
				desc = "Open REPL",
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Toggle DAP UI",
			},
			{
				"<leader>de",
				function()
					require("dapui").eval()
				end,
				desc = "Eval Expression",
				mode = { "n", "v" },
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- ──────────────────────────────────────────────
			-- nvim-dap-virtual-text
			-- ──────────────────────────────────────────────
			require("nvim-dap-virtual-text").setup({
				commented = true, -- show virtual text alongside comment
			})

			-- ──────────────────────────────────────────────
			-- DAP UI
			-- ──────────────────────────────────────────────
			dapui.setup({
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.4 },
							{ id = "breakpoints", size = 0.15 },
							{ id = "stacks", size = 0.25 },
							{ id = "watches", size = 0.2 },
						},
						size = 40,
						position = "left",
					},
					{
						elements = {
							{ id = "repl", size = 0.5 },
							{ id = "console", size = 0.5 },
						},
						size = 12,
						position = "bottom",
					},
				},
			})

			-- Auto-open/close UI with session
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- https://emojipedia.org/en/stickers/search?q=circle
			vim.fn.sign_define("DapBreakpoint", {
				text = "⚪",
				texthl = "DapBreakpointSymbol",
				linehl = "DapBreakpoint",
				numhl = "DapBreakpoint",
			})

			vim.fn.sign_define("DapStopped", {
				text = "🔴",
				texthl = "yellow",
				linehl = "DapBreakpoint",
				numhl = "DapBreakpoint",
			})
			vim.fn.sign_define("DapBreakpointRejected", {
				text = "⭕",
				texthl = "DapStoppedSymbol",
				linehl = "DapBreakpoint",
				numhl = "DapBreakpoint",
			})

			-- ──────────────────────────────────────────────
			-- C# / netcoredbg
			-- ──────────────────────────────────────────────
			local netcoredbg_fileName = "netcoredbg"
			-- If the OS is windows
			if package.config:sub(1, 1) == "\\" then
				netcoredbg_fileName = netcoredbg_fileName .. ".exe"
			end

			local netcoredbg_path = vim.fn.stdpath("data"):gsub("\\", "/")
				.. "/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe"

			local netcoredbg_adapter = {
				type = "executable",
				command = netcoredbg_path,
				args = { "--interpreter=vscode" },
			}

			dap.adapters.netcoredbg = netcoredbg_adapter
			dap.adapters.coreclr = netcoredbg_adapter

			local dotnet_helper = require("../helpers/nvim-dap-dotnet")
			dap.configurations.cs = {
				{
					type = "netcoredbg",
					name = "Launch (Debug)",
					request = "launch",
					program = function()
						-- TODO : Parse the launchSettings.json
						vim.env.ASPNETCORE_ENVIRONMENT = "Development"
						return dotnet_helper.build_dll_path("Debug")
					end,
				},
				{
					type = "netcoredbg",
					name = "Launch (Release)",
					request = "launch",
					program = function()
						-- TODO : Parse the launchSettings.json
						vim.env.ASPNETCORE_ENVIRONMENT = "Production"
						return dotnet_helper.build_dll_path("Release")
					end,
				},
				{
					type = "coreclr",
					name = "Attach to process",
					request = "attach",
					processId = require("dap.utils").pick_process,
				},
			}

			-- ──────────────────────────────────────────────
			-- TypeScript / js-debug-adapter
			-- ──────────────────────────────────────────────
			-- local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"

			-- dap.adapters["pwa-node"] = {
			-- type = "server",
			-- host = "localhost",
			-- port = "${port}",
			-- executable = {
			-- command = "node",
			-- args = { js_debug_path, "${port}" },
			-- },
			-- }

			-- Vitest runs under Node, so we attach to the Node process
			-- for _, lang in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
			-- dap.configurations[lang] = {
			-- {
			-- type = "pwa-node",
			-- request = "launch",
			-- name = "Launch file (Node)",
			-- program = "${file}",
			-- cwd = "${workspaceFolder}",
			-- sourceMaps = true,
			-- resolveSourceMapLocations = {
			-- "${workspaceFolder}/**",
			-- "!**/node_modules/**",
			-- },
			-- },
			-- {
			-- type = "pwa-node",
			-- request = "launch",
			-- name = "Debug Vitest (current file)",
			-- cwd = "${workspaceFolder}",
			-- program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
			-- args = { "run", "${file}" },
			-- sourceMaps = true,
			-- resolveSourceMapLocations = {
			-- "${workspaceFolder}/**",
			-- "!**/node_modules/**",
			-- },
			-- console = "integratedTerminal",
			-- },
			-- {
			-- type = "pwa-node",
			-- request = "attach",
			-- name = "Attach to Node process",
			-- processId = require("dap.utils").pick_process,
			-- cwd = "${workspaceFolder}",
			-- },
			-- }
			-- end
		end,
	},
}
