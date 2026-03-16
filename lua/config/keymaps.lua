-- Window/split navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to Left Split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to Lower Split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to Upper Split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to Right Split" })

-- Split creation
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Vertical Split" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>",  { desc = "Horizontal Split" })
vim.keymap.set("n", "<leader>sc", "<cmd>close<cr>",  { desc = "Close Split" })