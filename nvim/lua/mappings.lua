require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set


-- Existing mappings
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "f", require("flash").jump, { desc = "Flash jump" })
map('t', '<C-q>', '<C-\\><C-n>', { desc = "Exit terminal mode to Normal mode" })

-- Add split mappings
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical Split" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Horizontal Split" })

-- (Optional) To navigate between splits easily
map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to below split" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to above split" })

vim.keymap.del("i", "<C-k>")

vim.keymap.del("i", "<C-j>")
