-- HTML Language Server configuration
-- Requires: html-lsp installed via Mason

local nvlsp = require "nvchad.configs.lspconfig"

return {
  cmd = { "html-lsp", "--stdio" },
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    html = {
      format = {
        enable = true,
      },
    },
  },
}
