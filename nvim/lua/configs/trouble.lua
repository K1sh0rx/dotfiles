require("trouble").setup({
  auto_open = false,
  auto_close = true,
  use_diagnostic_signs = true,
})

vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<CR>", { silent = true })
vim.keymap.set(
  "n",
  "<leader>xd",
  "<cmd>TroubleToggle document_diagnostics<CR>",
  { silent = true }
)
