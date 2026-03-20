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
				nowait = true,
				remap = false,
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.open()
				end,
				desc = "Open REPL",
				nowait = true,
				remap = false,
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Toggle DAP UI",
				nowait = true,
				remap = false,
			},
			{
				"<leader>de",
				function()
					require("dapui").eval()
				end,
				desc = "Eval Expression",
				mode = { "n", "v" },
				nowait = true,
				remap = false,
			},
			{
				"<leader>db",
				function()
					require("dap").list_breakpoints()
				end,
				desc = "List breakpoints",
				nowait = true,
				remap = false,
			},
			{
				"<leader>de",
				function()
					require("dap").set_exception_breakpoints({ "all" })
				end,
				desc = "Set Exception breakpoints",
				nowait = true,
				remap = false,
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
					-- Run in a terminal (useful for apps with stdin/stdout)
					-- "integratedTerminal" | "externalTerminal" | "none" (uses dap console)
					-- console = "externalTerminal",
					justMyCode = true, -- Default is true
					env = {
						ASPNETCORE_ENVIRONMENT = "Development",
						-- ASPNETCORE_URLS = "http://localhost:5000",
					},
					cwd = function()
						local configuration = "Debug"
						local cwf = vim.api.nvim_buf_get_name(0):gsub("\\", "/")
						local cwd = vim.fn.fnamemodify(cwf, ":p:h")

						local project_setup = dotnet_helper.get_dotnet_project_setup(cwf, cwd, configuration)
						if not project_setup then
							vim.notify("Failed to get the working directory for the dll. Good luck :)")
							return cwd
						end

						return project_setup.dll_root_dir
					end,
					program = function()
						-- TODO : Parse the launchSettings.json and build a config for each profile
						local wezterm = require("../helpers/wztrm-helper")

						local configuration = "Debug"

						-- Get the current "working" file and current working directory
						local cwf = vim.api.nvim_buf_get_name(0):gsub("\\", "/")
						local cwd = vim.fn.fnamemodify(cwf, ":p:h")

						local project_setup = dotnet_helper.get_dotnet_project_setup(cwf, cwd, configuration)

						if not project_setup then
							return nil
						end

						local build_error = dotnet_helper.build_project(configuration, project_setup)
						if build_error then
							vim.notify("Build FAILED:\n" .. build_error, vim.log.levels.ERROR)
							return nil
						end

						vim.notify("Build Succeeded.", vim.log.levels.DEBUG)

						wezterm.set_terminal_title(configuration .. " " .. project_setup.project_name)

						-- TODO : We are keeping track of the old working directory and return to it when done with current debugging session.
						-- Could get complex when running multiple configs at the same time. At that point, just disable the cwd change maybe?

						return project_setup.dll_path
					end,
				},
				{
					type = "netcoredbg",
					name = "Launch (Release)",
					request = "launch",
					program = function()
						-- TODO : Parse the launchSettings.json and build a config for each profile
						local configuration = "Release"

						local cwf = vim.api.nvim_buf_get_name(0):gsub("\\", "/")
						local cwd = vim.fn.fnamemodify(cwf, ":p:h")

						local corenet_env = "Production"
						local project_setup = dotnet_helper.get_dotnet_project_setup(cwf, cwd, configuration)

						if not project_setup then
							return nil
						end

						local build_error = dotnet_helper.build_project(configuration, project_setup)
						if build_error then
							vim.notify("Build FAILED:\n" .. build_error, vim.log.levels.ERROR)
							return nil
						end

						vim.notify("Build Succeeded.", vim.log.levels.DEBUG)

						-- Set the working directory to the highest_net_folder so we execute in that directory
						vim.fn.chdir(project_setup.dll_root_dir)

						-- TODO : We are keeping track of the old working directory and return to it when done with current debugging session.
						-- Could get complex when running multiple configs at the same time. At that point, just disable the cwd change maybe?
						vim.env.ASPNETCORE_ENVIRONMENT = corenet_env

						return project_setup.dll_path
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
			local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"

			local pwa_node_adapter = "pwa-node"

			dap.adapters[pwa_node_adapter] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = { js_debug_path, "${port}" },
				},
			}

			-- Vitest runs under Node, so we attach to the Node process
			-- TODO : We need a system that can save configurations per project
			-- TODO : Need to figure out if this runs every time we open a new project
			for _, lang in ipairs({ "typescript", "javascript" }) do
				vim.notify("We are here!", vim.log.levels.DEBUG)
				dap.configurations[lang] = {
					{
						type = pwa_node_adapter,
						request = "launch",
						name = "Launch file (Node)",
						program = "${file}",
						cwd = "${workspaceFolder}",
						sourceMaps = true,
						resolveSourceMapLocations = {
							"${workspaceFolder}/**",
							"!**/node_modules/**",
						},
					},
					{
						type = pwa_node_adapter,
						request = "launch",
						name = "Debug Vitest (current file)",
						cwd = "${workspaceFolder}",
						program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
						args = { "run", "${file}" },
						sourceMaps = true,
						resolveSourceMapLocations = {
							"${workspaceFolder}/**",
							"!**/node_modules/**",
						},
						console = "integratedTerminal",
					},
					{
						type = pwa_node_adapter,
						request = "attach",
						name = "Attach to Node process",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-chrome",
						request = "launch",
						name = "Launch & Debug Chrome",
						url = function()
							local co = coroutine.running()
							return coroutine.create(function()
								vim.ui.input({
									prompt = "Enter URL: ",
									default = "http://localhost:3000",
								}, function(url)
									if url == nil or url == "" then
										return
									else
										coroutine.resume(co, url)
									end
								end)
							end)
						end,
						webRoot = vim.fn.getcwd(),
						protocol = "inspector",
						sourceMaps = true,
						userDataDir = false,
					},
					{
						name = "----- ↓ launch.json configs ↓ -----",
						type = "",
						request = "launch",
					},
				}
			end
		end,
	},
}
