-- ==========================================================================
-- helpers/health.lua — "HP" (Health Points) custom health check
-- ==========================================================================
-- Usage:
--   :HP              (user command shortcut)
--   :checkhealth hp  (standard checkhealth integration)
--
-- Checks everything relevant to this Neovim IDE build:
--   • Core CLI tools (git, rg, fd, fzf, node, python, etc.)
--   • WSL environment & clipboard
--   • Treesitter parsers (for noice + your languages)
--   • LSP servers (mason-installed)
--   • DAP adapters (mason-installed)
--   • Neovim providers (node, python)
--   • Plugin status (lazy.nvim)
-- ==========================================================================

local M = {}

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

--- Check if an executable exists and return its version string.
--- @param cmd string — the binary name
--- @param args string[]|nil — args to get version (default: {"--version"})
--- @return string|nil version — first line of output, or nil if not found
local function get_version(cmd, args)
	-- Guard: check the binary exists before spawning a process.
	-- vim.system throws ENOENT if the executable isn't found, which
	-- crashes the entire healthcheck instead of reporting a clean error.
	if vim.fn.executable(cmd) ~= 1 then
		return nil
	end

	args = args or { "--version" }
	local full = vim.list_extend({ cmd }, args)

	-- pcall as a safety net — even with the executable check above,
	-- edge cases (broken symlinks, permission issues) can still throw.
	local ok, result = pcall(function()
		return vim.system(full, { text = true }):wait()
	end)

	if not ok or result.code ~= 0 then
		return nil
	end

	-- Return the first non-empty line
	local output = result.stdout or ""
	for line in output:gmatch("[^\r\n]+") do
		local trimmed = vim.trim(line)
		if trimmed ~= "" then
			return trimmed
		end
	end
	return nil
end

--- Check a required CLI tool — report ok or error.
local function check_tool(name, cmd, args, advice)
	local ver = get_version(cmd, args)
	if ver then
		vim.health.ok(("%s: %s"):format(name, ver))
	else
		vim.health.error(
			("%s: `%s` not found in $PATH"):format(name, cmd),
			advice or { ("Install %s and make sure it's in your $PATH"):format(name) }
		)
	end
end

--- Check an optional CLI tool — report ok or warn.
local function check_optional_tool(name, cmd, args, advice)
	local ver = get_version(cmd, args)
	if ver then
		vim.health.ok(("%s: %s"):format(name, ver))
	else
		vim.health.warn(
			("%s: `%s` not found in $PATH"):format(name, cmd),
			advice or { ("Install %s for full functionality"):format(name) }
		)
	end
end

--- Check if a Lua module can be required.
local function module_available(mod)
	local ok = pcall(require, mod)
	return ok
end

-- ---------------------------------------------------------------------------
-- Section: Neovim version
-- ---------------------------------------------------------------------------
local function check_neovim()
	vim.health.start("Neovim")

	local v = vim.version()
	local ver_str = ("%d.%d.%d"):format(v.major, v.minor, v.patch)
	if v.prerelease then
		ver_str = ver_str .. "-" .. v.prerelease
	end

	if vim.fn.has("nvim-0.11") == 1 then
		vim.health.ok("Neovim " .. ver_str .. " (>= 0.11)")
	else
		vim.health.error("Neovim " .. ver_str .. " — 0.11+ is required for this config")
	end
	-- Build type
	local build = vim.fn.execute("version")
	if build:find("Release") then
		vim.health.ok("Build type: Release")
	elseif build:find("Debug") then
		vim.health.warn("Build type: Debug (slower, use Release for daily use)")
	end
end

-- ---------------------------------------------------------------------------
-- Section: Core tools
-- ---------------------------------------------------------------------------
local function check_core_tools()
	vim.health.start("Core tools")

	check_tool("Git", "git", { "--version" })
	check_tool("ripgrep", "rg", { "--version" })
	check_tool("fd", "fdfind", { "--version" }, {
		"Install fd-find: `sudo apt install fd-find`",
		"Or check if it's named `fd` on your system",
	})
	check_tool("fzf", "fzf", { "--version" })
	check_tool("GCC", "gcc", { "--version" })
	check_tool("Make", "make", { "--version" })
	check_tool("unzip", "unzip", { "-v" })
	check_tool("wget", "wget", { "--version" })
	check_tool("curl", "curl", { "--version" })

	-- Node & npm — required for LSP servers + Neovim provider
	check_tool("Node.js", "node", { "--version" })
	check_tool("npm", "npm", { "--version" })

	-- Python — required for some tooling
	check_tool("Python 3", "python3", { "--version" })
	check_optional_tool("pip", "pip3", { "--version" })

	-- Lua & luarocks
	check_optional_tool("Lua", "lua5.4", { "-v" }, {
		"Lua 5.4 is optional but used by some plugins via luarocks",
	})
	check_optional_tool("luarocks", "luarocks", { "--version" })

	-- lazygit — primary git UI
	check_tool("lazygit", "lazygit", { "--version" })
end

-- ---------------------------------------------------------------------------
-- Section: WSL & Terminal environment
-- ---------------------------------------------------------------------------
local function check_environment()
	vim.health.start("Environment (WSL + Terminal)")

	-- WSL detection
	local is_wsl = vim.fn.has("wsl") == 1
		or (
			vim.fn.filereadable("/proc/version") == 1
			and vim.fn.readfile("/proc/version")[1]:lower():find("microsoft") ~= nil
		)

	if is_wsl then
		vim.health.ok("Running inside WSL")
	else
		vim.health.info("Not running in WSL (some WSL-specific features won't apply)")
	end

	-- WezTerm detection
	local term_program = vim.env.TERM_PROGRAM or ""
	if term_program == "WezTerm" then
		vim.health.ok("Terminal: WezTerm detected")
	else
		vim.health.warn(
			("Terminal: %s (expected WezTerm)"):format(term_program ~= "" and term_program or "$TERM_PROGRAM not set")
		)
	end

	-- True color
	if vim.env.COLORTERM == "truecolor" then
		vim.health.ok("True color: $COLORTERM=truecolor")
	else
		vim.health.warn("True color: $COLORTERM is not 'truecolor' — colors may look wrong")
	end

	-- Clipboard
	local clipboard = vim.fn.has("clipboard") == 1
	if clipboard then
		-- Check what tool is being used
		local cb_tool = nil
		for _, tool in ipairs({ "xclip", "xsel", "win32yank.exe", "wl-copy" }) do
			if vim.fn.executable(tool) == 1 then
				cb_tool = tool
				break
			end
		end
		if cb_tool then
			vim.health.ok("Clipboard: " .. cb_tool)
		else
			vim.health.ok("Clipboard: supported (unknown tool)")
		end
	else
		vim.health.error("Clipboard: not available", {
			"Install xclip (`sudo apt install xclip`) or win32yank",
		})
	end

	-- wslview (for opening files in Windows from WSL)
	if is_wsl then
		if vim.fn.executable("wslview") == 1 then
			vim.health.ok("wslview: available (for opening files in Windows)")
		else
			vim.health.warn("wslview: not found", {
				"Install wslu for `wslview`: `sudo apt install wslu`",
				"Needed for 'open with system viewer' in neo-tree",
			})
		end
	end
end

-- ---------------------------------------------------------------------------
-- Section: Neovim providers
-- ---------------------------------------------------------------------------
local function check_providers()
	vim.health.start("Neovim providers")

	-- Node provider
	local node_host = vim.fn.exepath("neovim-node-host")
	if node_host ~= "" then
		vim.health.ok("Node.js provider: neovim-node-host found at " .. node_host)
	else
		vim.health.warn("Node.js provider: neovim-node-host not found", {
			"Install: `npm install -g neovim`",
		})
	end

	-- Python provider
	local py3 = vim.fn.exepath("python3")
	if py3 == "" then
		vim.health.warn("Python 3 provider: python3 not found in $PATH")
	else
		-- Check pynvim
		local pynvim_ok = pcall(function()
			local result = vim.system({
				"python3",
				"-c",
				"import pynvim; print(pynvim.VERSION.minor)",
			}, { text = true }):wait()
			return result.code == 0
		end)

		if pynvim_ok then
			vim.health.ok("Python 3 provider: pynvim installed")
			-- Version check (pip3 might not exist separately)
			if vim.fn.executable("pip3") == 1 then
				local ver_ok, ver_result = pcall(function()
					return vim.system({ "pip3", "show", "pynvim" }, { text = true }):wait()
				end)
				if ver_ok and ver_result.code == 0 then
					local ver_line = ver_result.stdout:match("Version: ([^\n]+)")
					if ver_line then
						vim.health.info("  pynvim version: " .. ver_line)
					end
				end
			end
		else
			vim.health.warn("Python 3 provider: pynvim may not be installed", {
				"Install: `pip3 install pynvim --break-system-packages`",
			})
		end
	end
end

-- ---------------------------------------------------------------------------
-- Section: Treesitter parsers
-- ---------------------------------------------------------------------------
local function check_treesitter()
	vim.health.start("Treesitter parsers")

	-- Parsers needed by noice.nvim for cmdline highlighting
	local noice_parsers = { "vim", "regex", "lua", "bash", "markdown", "markdown_inline" }
	-- Parsers for your primary languages
	local lang_parsers = { "c_sharp", "typescript", "tsx", "javascript", "html", "css", "json", "yaml", "toml" }
	-- Config languages
	local config_parsers = { "lua", "luadoc", "query" }

	-- Merge all, deduplicate
	local all = {}
	local seen = {}
	for _, list in ipairs({ noice_parsers, lang_parsers, config_parsers }) do
		for _, p in ipairs(list) do
			if not seen[p] then
				seen[p] = true
				all[#all + 1] = p
			end
		end
	end

	-- Check if treesitter is available
	local ts_ok, ts_parsers = pcall(require, "nvim-treesitter.parsers")
	if not ts_ok then
		-- Fallback: use vim.treesitter directly (nvim 0.10+)
		local installed_count = 0
		local missing = {}
		for _, parser in ipairs(all) do
			local ok = pcall(vim.treesitter.language.inspect, parser)
			if ok then
				installed_count = installed_count + 1
			else
				missing[#missing + 1] = parser
			end
		end

		vim.health.info(("Checked %d parsers (%d installed, %d missing)"):format(#all, installed_count, #missing))

		if #missing > 0 then
			-- Separate noice-required from language parsers for clearer advice
			local noice_missing = {}
			local lang_missing = {}
			local noice_set = {}
			for _, p in ipairs(noice_parsers) do
				noice_set[p] = true
			end
			for _, p in ipairs(missing) do
				if noice_set[p] then
					noice_missing[#noice_missing + 1] = p
				else
					lang_missing[#lang_missing + 1] = p
				end
			end

			if #noice_missing > 0 then
				vim.health.warn(
					"Missing parsers needed by noice.nvim: " .. table.concat(noice_missing, ", "),
					{ (":TSInstall %s"):format(table.concat(noice_missing, " ")) }
				)
			end
			if #lang_missing > 0 then
				vim.health.warn(
					"Missing parsers for your languages: " .. table.concat(lang_missing, ", "),
					{ (":TSInstall %s"):format(table.concat(lang_missing, " ")) }
				)
			end
		else
			vim.health.ok("All expected parsers installed")
		end
		return
	end

	-- nvim-treesitter is loaded, use its API
	local installed_count = 0
	local missing = {}
	for _, parser in ipairs(all) do
		if ts_parsers.has_parser(parser) then
			installed_count = installed_count + 1
		else
			missing[#missing + 1] = parser
		end
	end

	vim.health.info(("Checked %d parsers (%d installed, %d missing)"):format(#all, installed_count, #missing))

	if #missing > 0 then
		vim.health.warn(
			"Missing parsers: " .. table.concat(missing, ", "),
			{ (":TSInstall %s"):format(table.concat(missing, " ")) }
		)
	else
		vim.health.ok("All expected parsers installed")
	end
end

-- ---------------------------------------------------------------------------
-- Section: LSP servers (via mason)
-- ---------------------------------------------------------------------------
local function check_lsp()
	vim.health.start("LSP servers (Mason)")

	if not module_available("mason-registry") then
		vim.health.warn("mason-registry not available (Mason not installed yet? — Phase 5)")
		return
	end

	local registry = require("mason-registry")

	-- Expected LSP servers for your stack
	local servers = {
		{ name = "omnisharp", label = "C# (OmniSharp)", required = true },
		{ name = "typescript-language-server", label = "TypeScript (ts_ls)", required = true },
		{ name = "lua-language-server", label = "Lua (lua_ls)", required = true },
		{ name = "json-lsp", label = "JSON (jsonls)", required = false },
		{ name = "yaml-language-server", label = "YAML (yamlls)", required = false },
		{ name = "angular-language-server", label = "Angular", required = false },
		{ name = "html-lsp", label = "HTML", required = false },
		{ name = "css-lsp", label = "CSS", required = false },
	}

	for _, srv in ipairs(servers) do
		local ok, pkg = pcall(registry.get_package, srv.name)
		if ok and pkg:is_installed() then
			vim.health.ok(("%s: installed"):format(srv.label))
		elseif srv.required then
			vim.health.error(("%s: not installed"):format(srv.label), {
				(":MasonInstall %s"):format(srv.name),
			})
		else
			vim.health.warn(("%s: not installed (optional)"):format(srv.label), {
				(":MasonInstall %s"):format(srv.name),
			})
		end
	end
end

-- ---------------------------------------------------------------------------
-- Section: DAP adapters (via mason)
-- ---------------------------------------------------------------------------
local function check_dap()
	vim.health.start("DAP adapters (Mason)")

	if not module_available("mason-registry") then
		vim.health.warn("mason-registry not available (Mason not installed yet? — Phase 5)")
		return
	end

	local registry = require("mason-registry")

	local adapters = {
		{ name = "netcoredbg", label = "C# debugger (netcoredbg)" },
		{ name = "js-debug-adapter", label = "JS/TS debugger (js-debug-adapter)" },
	}

	for _, dap in ipairs(adapters) do
		local ok, pkg = pcall(registry.get_package, dap.name)
		if ok and pkg:is_installed() then
			vim.health.ok(("%s: installed"):format(dap.label))
		else
			vim.health.warn(("%s: not installed"):format(dap.label), {
				(":MasonInstall %s"):format(dap.name),
			})
		end
	end
end

-- ---------------------------------------------------------------------------
-- Section: Plugins (lazy.nvim)
-- ---------------------------------------------------------------------------
local function check_plugins()
	vim.health.start("Plugins (lazy.nvim)")

	if not module_available("lazy") then
		vim.health.error("lazy.nvim is not loaded")
		return
	end

	local lazy = require("lazy")
	M.get_lazy_startup_time(lazy)

	-- Check for expected core plugins
	local expected = {
		"lazy.nvim",
		"rider.nvim",
		"which-key.nvim",
		"mini.icons",
		"nvim-web-devicons",
		"lualine.nvim",
		"bufferline.nvim",
		"noice.nvim",
	}

	local lazy_plugins = lazy.plugins()
	local plugin_set = {}
	for _, p in ipairs(lazy_plugins) do
		plugin_set[p.name] = true
	end

	local missing = {}
	for _, name in ipairs(expected) do
		if not plugin_set[name] then
			missing[#missing + 1] = name
		end
	end

	if #missing > 0 then
		vim.health.warn("Expected plugins not found: " .. table.concat(missing, ", "))
	else
		vim.health.ok("All core plugins present (Phase 1 + 2)")
	end
end

-- ---------------------------------------------------------------------------
-- Stats
-- ---------------------------------------------------------------------------

--- Gets the lazy stats
--- @param lazy Lazy — require("lazy")
--- @param displaystartuptime boolean — Opt-out by design. Will always do a vim.health check and display the startup time if not set.
--- @return number startuptime — The time it took Lazy to start up with all plugins
function M.get_lazy_startup_time(lazy, displaystartuptime)
	local stats = lazy.stats()

	vim.health.ok(("lazy.nvim loaded — %d/%d plugins active"):format(stats.loaded, stats.count))

	if stats.startuptime then
		local ms = math.floor(stats.startuptime * 100) / 100
		if ms < 80 then
			vim.health.ok(("Startup time: %s ms"):format(ms))
		elseif ms < 150 then
			vim.health.info(("Startup time: %s ms (acceptable)"):format(ms))
		else
			vim.health.warn(("Startup time: %s ms (consider profiling with :Lazy profile)"):format(ms))
		end
	end

	return stats.startuptime
end

-- ---------------------------------------------------------------------------
-- Main check function — called by :checkhealth hp
-- ---------------------------------------------------------------------------
function M.check()
	check_neovim()
	check_core_tools()
	check_environment()
	check_providers()
	check_treesitter()
	check_lsp()
	check_dap()
	check_plugins()
end

return M
