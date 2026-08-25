-- Completion and snippet plugins
-- Configuration of nvim-cmp, completion sources, and snippet engines

return {
  -- nvim-cmp - Main completion engine
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer", -- Buffer completions
      "hrsh7th/cmp-nvim-lsp", -- LSP completions
      "hrsh7th/cmp-path", -- Path completions
      "saadparwaiz1/cmp_luasnip", -- Snippet completions
      "hrsh7th/cmp-cmdline", -- Command-line completions
    },
    config = function()
      require "configs.cmp"
    end,
  },

  -- LuaSnip - Snippet engine
  -- Snippet configuration is loaded in init.lua
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets", -- Predefined snippets
    },
  },

  -- Luasnip extra snippets
  {
    "rafamadriz/friendly-snippets",
    lazy = true,
  },
}
