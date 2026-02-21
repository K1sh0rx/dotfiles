return {

  -- === Treesitter (REQUIRED by NvChad) ===
  {
    "nvim-treesitter/nvim-treesitter",
    opts = require("configs.treesitter"),
    build = ":TSUpdate",
  },

  -- === Mason + LSP ===
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require("configs.lspconfig")
    end,
  },

  -- === Formatting ===
  {
    "stevearc/conform.nvim",
    opts = require("configs.conform"),
  },

  -- === UI / UX ===
  { "folke/flash.nvim", config = function() require("configs.flash") end },
  {
    "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = "VeryLazy",
    config = function()
      require("configs.noice")
    end,
  },
  { "folke/trouble.nvim", config = function() require("configs.trouble") end },
}

