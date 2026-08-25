-- Main plugin file
-- This file imports all plugin categories from their respective modules

return {
  -- Import LSP plugins
  { import = "plugins.lsp" },

  -- Import completion plugins
  { import = "plugins.completion" },

  -- Import formatting plugins
  { import = "plugins.formatting" },

  -- Import UI plugins
  { import = "plugins.ui" },

  -- Import AI plugins
  { import = "plugins.ai" },
}
