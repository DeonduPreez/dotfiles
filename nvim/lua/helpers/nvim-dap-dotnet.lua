local M = {}

-- Find the root directory of a .NET project by searching for .csproj files
function M.find_project_root_by_csproj(start_path)
	local Path = require("plenary.path")
	local path = Path:new(start_path)

	while true do
		local csproj_files = vim.fn.glob(path:absolute() .. "/*.csproj", false, true)
		if #csproj_files > 0 then
			return { csproj_root_dir = path:absolute():gsub("\\", "/"), csproj_path = csproj_files[1]:gsub("\\", "/") }
		end

		local parent = path:parent()
		if parent:absolute() == path:absolute() then
			return nil
		end

		path = parent
	end
end

-- Find the highest version of the netX.Y folder within a given path.
function M.get_highest_net_folder(bin_debug_path)
	local dirs = vim.fn.glob(bin_debug_path .. "/net*", false, true) -- Get all folders starting with 'net' in bin_debug_path

	if dirs == 0 then
		error("No netX.Y folders found in " .. bin_debug_path)
	end

	table.sort(dirs, function(a, b) -- Sort the directories based on their version numbers
		local ver_a = tonumber(a:match("net(%+)%.%d+"))
		local ver_b = tonumber(b:match("net(%+)%.%d+"))
		return ver_a > ver_b
	end)

	return dirs[1]:gsub("\\", "/")
end

-- TODO : Read the launch settings and build configurations for each profile. launchSettings.json has all the info we need. We might need to set the URLs env var
-- function M.read_launch_settings(csproj_root_dir)
-- Currently only supports dotnet apps. .Net Framework will not be parsed
-- local launch_settings_root_dir = csproj_root_dir .. "/Properties"
-- local launch_settings_path = launch_settings_root_dir .. "/launchSettings.json"
-- end

function M.get_dotnet_project_setup(configuration)
	-- Get the current "working" file and current working directory
	local cwf = vim.api.nvim_buf_get_name(0):gsub("\\", "/")
	local result = { cwf = cwf, cwd = vim.fn.fnamemodify(cwf, ":p:h") }

	-- Start from the cwd and work up until you find the root of the csproj
	local csproj_root_details = M.find_project_root_by_csproj(result.cwd)
	if not csproj_root_details then
		vim.notify("Unable to find project_root from " .. result.cwd, vim.log.levels.ERROR)
		return nil
	end

	result.csproj_root_dir = csproj_root_details.csproj_root_dir
	result.csproj_path = csproj_root_details.csproj_path
	result.project_name = vim.fn.fnamemodify(result.csproj_path, ":t:r")
	result.bin_root_dir = csproj_root_details.csproj_root_dir .. "/bin/" .. configuration
	result.dll_root_dir = M.get_highest_net_folder(result.bin_root_dir)
	if not result.dll_root_dir then
		vim.notify("Unable to find dll_root_dir in " .. result.bin_root_dir, vim.log.levels.ERROR)
		return nil
	end
	result.dll_path = result.dll_root_dir .. "/" .. result.project_name .. ".dll"

	return result
end

-- Builds the csproj file. Only returns build errors, otherwise nil.
function M.build_project(configuration, project_setup)
	-- Set the working directory to the root of the project so we build in that directory
	vim.fn.chdir(project_setup.csproj_root_dir)

	-- Run dotnet build synchronously (blocks until done)
	vim.notify("Building " .. project_setup.project_name .. " (" .. configuration .. ")...", vim.log.levels.INFO)
	local result =
		vim.fn.system("dotnet build -c " .. configuration .. " " .. vim.fn.shellescape(project_setup.csproj_path))
	local exit_code = vim.v.shell_error

	if exit_code ~= 0 then
		return result
	end

	return nil
end

return M
