require("trouble").setup({
  auto_open = false,
  auto_close = true,
  use_diagnostic_signs = true,
})

vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<CR>")
vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<CR>")
r>xd", "<cmd>TroubleToggle document_diagnostics<CR>", { noremap = true, silent = true })
