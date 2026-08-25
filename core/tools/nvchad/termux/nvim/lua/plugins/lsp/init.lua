-- LSP, code analysis, and language tools plugins
return {
  -- Main LSP - neovim nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- LSP server manager and tools
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "prettier",
        "typescript-language-server",
        "eslint-lsp",
        "eslint_d",
        "bash-language-server",
      },
    },
  },

  -- Mason LSP Config - integrates mason with lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
  },

  -- LSP diagnostics and UI
  {
    "folke/trouble.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Autotag - auto-close and rename HTML/JSX/TSX tags
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
      require("nvim-ts-autotag").setup(opts)
    end,
  },

  -- Symbol navigation
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    opts = {},
  },

  -- Code folding with nvim-ufo
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    event = "VeryLazy",
    config = function()
      require("ufo").setup({
        provider_selector = function()
          return { "treesitter", "indent" }
        end,
      })
    end,
  },
}
