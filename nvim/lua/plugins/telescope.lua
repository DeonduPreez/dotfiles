return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
		},
	},
	opts = {
		defaults = {
			layout_strategy = "horizontal",
			layout_config = { prompt_position = "top" },
			sorting_strategy = "ascending",
			winblend = 0,
		},
	},
	keys = {
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
		{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
		{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
		{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
		{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
		{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
		{ "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace Symbols" },
		{ "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
		{ "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search Buffer" },
	},
	config = function(_, opts)
		local telescope = require("telescope")
		telescope.setup(opts)
		pcall(telescope.load_extension, "fzf")
	end,
}

