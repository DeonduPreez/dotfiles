return {
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				-- TODO : Figure out which of these tools are what actually. Some of them overlap
				-- LSP servers
				"omnisharp",
				"typescript-language-server",
				"angular-language-server",
				"ansible-language-server",
				"api-linter",
				"azure-pipelines-language-server",
				"bash-language-server",
				"docker-language-server",
				"cpplint",
				"cpptools",
				"powershell-editor-services",
				"json-lsp",

				-- Formatters
				"prettier",

				-- Debugging tools
				"netcoredbg",
				"js-debug-adapter",
			})
		end,
	},
}
