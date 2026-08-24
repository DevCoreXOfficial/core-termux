-- Code formatting plugins
-- Configuration of conform.nvim and formatters

return {
  -- Conform.nvim - Lightweight and fast formatter
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },
}
