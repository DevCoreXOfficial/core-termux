local cmp = require "cmp"
local luasnip = require "luasnip"

-- Load custom snippets
require "configs.snippets"

cmp.setup {
  -- Sources for autocompletion
  sources = {
    { name = "nvim_lsp" }, -- Language Server Protocol (LSP)
    { name = "buffer" }, -- Current buffer content
    { name = "path" }, -- File paths
    { name = "luasnip" }, -- Snippets from LuaSnip
    { name = "copilot" }, -- Github Copilot
  },

  -- Key mappings for autocompletion
  mapping = {
    -- Scroll documentation
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),

    -- Trigger completion manually
    ["<C-Space>"] = cmp.mapping.complete(),

    -- Confirm selection
    ["<CR>"] = cmp.mapping.confirm { select = true },

    -- Navigate completion options using Tab and Shift+Tab
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump() -- Expand or jump through snippet placeholders
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1) -- Jump backwards through snippet placeholders
      else
        fallback()
      end
    end, { "i", "s" }),

    -- Navigate with arrow keys
    ["<Down>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<Up>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  },

  -- Snippet configuration
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body) -- Expand snippet using LuaSnip
    end,
  },

  -- Window appearance for completion and documentation
  window = {
    completion = cmp.config.window.bordered(), -- Bordered completion menu
    documentation = cmp.config.window.bordered(), -- Bordered documentation window
  },

  -- Experimental features
  experimental = {
    ghost_text = true, -- Show ghost text suggestions while typing
  },
}
