
require("nvchad.mappings")

local map = vim.keymap.set

map("n", ";", ":", { desc = "Command mode" })
map("i", "jk", "<ESC>")

-- splits
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Horizontal split" })

-- move between splits
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")

-- terminal
map("t", "<C-q>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

