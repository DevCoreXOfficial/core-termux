-- CSS Language Server configuration
-- Requires: css-lsp installed via Mason

local nvlsp = require "nvchad.configs.lspconfig"

return {
  cmd = { "css-lsp", "--stdio" },
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}
