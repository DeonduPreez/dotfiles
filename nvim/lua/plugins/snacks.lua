return {
	"folke/snacks.nvim",
	opts = {
		explorer = { enabled = false },
		image = {
			enabled = true,
			img_viewer = {
				inline = false,
				float = true,
			},
		},
	},
	keys = {
		{ "<leader>E", false },
		{ "<leader>fE", false },
	},
}
