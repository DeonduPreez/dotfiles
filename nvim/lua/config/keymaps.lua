-- Window/split navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to Left Split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to Lower Split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to Upper Split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to Right Split" })

-- Split creation
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Vertical Split" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "Horizontal Split" })
vim.keymap.set("n", "<leader>sc", "<cmd>close<cr>", { desc = "Close Split" })

local dap = require("dap")
-- DAP (Debugging)
vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP: Continue/Start" })
vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
vim.keymap.set("n", "<S-F9>", function()
	print(dap.list_breakpoints())
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP: Set Conditional Breakpoint" })

vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP: Step Over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP: Step Into" })
vim.keymap.set("n", "<F8>", dap.step_out, { desc = "DAP: Step Out" })
vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP: REPL Open" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "DAP: Run Last" })

-- C# / dotnet build
-- TODO : <leader>cr is mapped twice. Rethink how to use dotnet
-- vim.keymap.set("n", "<leader>cb", "<cmd>term dotnet build<cr>", { desc = "dotnet build" })
-- vim.keymap.set("n", "<leader>cr", "<cmd>term dotnet run<cr>", { desc = "dotnet run" })
-- vim.keymap.set("n", "<leader>ct", "<cmd>term dotnet test<cr>", { desc = "dotnet test (CLI)" })
