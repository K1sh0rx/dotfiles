
-- Native Neovim 0.11+ LSP configuration (NO lspconfig.setup)

print("LSPCONFIG LOADED")

-- Mason
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "pyright",
    "gopls",
    "rust_analyzer",
    "html",
    "cssls",
    "jsonls",
    "vtsls",
  },
})

-- Diagnostics
vim.diagnostic.config({
  underline = true,
  virtual_text = { spacing = 4, prefix = "●" },
  severity_sort = true,
  float = { border = "rounded", source = "always" },
})

-- Common on_attach
local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- === SERVER CONFIGURATION (NEW API) ===

vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      runtime = { version = "LuaJIT" },
      telemetry = { enable = false },
      workspace = { checkThirdParty = false },
    },
  },
})

vim.lsp.config("pyright", {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config("gopls", {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config("rust_analyzer", {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config("html", {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config("cssls", {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config("jsonls", {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config("vtsls", {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- === ENABLE SERVERS ===
vim.lsp.enable({
  "lua_ls",
  "pyright",
  "gopls",
  "rust_analyzer",
  "html",
  "cssls",
  "jsonls",
  "vtsls",
})

