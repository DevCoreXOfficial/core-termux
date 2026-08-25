-- Load defaults from NvChad (configures on_attach, on_init, capabilities)
require("nvchad.configs.lspconfig").defaults()

local nvlsp = require "nvchad.configs.lspconfig"

-- ============================================
-- Default servers (always enabled)
-- ============================================
local default_servers = {
  "bashls",
}

for _, lsp in ipairs(default_servers) do
  vim.lsp.config(lsp, {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  })
  vim.lsp.enable(lsp)
end

-- Custom configuration for tailwindcss
vim.lsp.config("tailwindcss", {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  init_options = {
    userLanguages = {
      javascript = "javascriptreact",
      typescript = "typescriptreact",
    },
  },
  settings = {
    tailwindCSS = {
      classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
      includeLanguages = {
        html = "html", css = "css",
        javascript = "javascript", typescript = "typescript",
        javascriptreact = "javascriptreact", typescriptreact = "typescriptreact",
      },
    },
  },
})
-- Custom configuration for ts_ls with inlayHints
vim.lsp.config("ts_ls", {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
})
-- NOTE: ts_ls is enabled on-demand via FileType autocommand (not at startup)

-- ============================================
-- Helper: install Termux package if not present
-- ============================================
-- pkg_names can be string or table of strings (for cases like glibc-repo + glibc)
local function ensure_termux_pkg(pkg_names, cb)
  if not pkg_names then if cb then cb() end return end
  local names = type(pkg_names) == "table" and pkg_names or { pkg_names }

  local function install_next(idx)
    if idx > #names then if cb then cb() end return end
    local name = names[idx]

    local ok = vim.fn.system("dpkg -s " .. name .. " 2>/dev/null | grep -q 'Status: install ok installed'")
    if vim.v.shell_error == 0 then install_next(idx + 1) return end

    vim.notify(string.format("Installing %s via Termux...", name), vim.log.levels.INFO)
    vim.fn.jobstart({ "pkg", "install", "-y", name }, {
      on_exit = function(_, code)
        if code == 0 then
          vim.notify(string.format("%s installed", name), vim.log.levels.INFO)
        else
          vim.notify(string.format("Error installing %s", name), vim.log.levels.ERROR)
        end
        install_next(idx + 1)
      end,
    })
  end

  install_next(1)
end

-- ============================================
-- On-demand servers (installed when opening the file)
-- ============================================
-- Mapping: filetype -> { server, mason, bin, ts, pkg, mason_fmt }
-- pkg: Termux package to install (string or table)
local on_demand = {
  python =           { server = "pyright", mason = "pyright", bin = "pyright-langserver",               ts = "python",     pkg = "python",          mason_fmt = { "black" } },
  go =               { server = "gopls",   mason = "gopls",   bin = "gopls",                            ts = "go",         pkg = "golang",          mason_fmt = {} },
  c =                { server = "clangd",  mason = "clangd",   bin = "clangd",                           ts = "c",          pkg = "clang",           mason_fmt = { "clang-format" } },
  cpp =              { server = "clangd",  mason = "clangd",   bin = "clangd",                           ts = "cpp",        pkg = "clang",           mason_fmt = { "clang-format" } },
  php =              { server = "intelephense", mason = "intelephense", bin = "intelephense",             ts = "php",        pkg = "php",             mason_fmt = {} },
  rust =             { server = "rust_analyzer", mason = nil, bin = "rust-analyzer",                      ts = "rust",       pkg = { "glibc-repo", "glibc" }, mason_fmt = {} },
  lua =              { server = "lua_ls", mason = "lua-language-server", bin = "lua-language-server",     ts = "lua",        pkg = nil,               mason_fmt = { "stylua" } },
  cs =               { server = "omnisharp", mason = "omnisharp", bin = "omnisharp",                     ts = "c_sharp",    pkg = nil,               mason_fmt = {} },
  bash =             { server = "bashls",  mason = "bash-language-server", bin = "bash-language-server",  ts = "bash",       pkg = nil,               mason_fmt = { "shfmt" } },
  sh =               { server = "bashls",  mason = "bash-language-server", bin = "bash-language-server",  ts = "bash",       pkg = nil,               mason_fmt = { "shfmt" } },
  zsh =              { server = "bashls",  mason = "bash-language-server", bin = "bash-language-server",  ts = "bash",       pkg = nil,               mason_fmt = { "shfmt" } },
  html =             { server = "html",    mason = "html-lsp",  bin = "html-lsp",                        ts = "html",       pkg = nil,               mason_fmt = { "prettier" } },
  css =              { server = "cssls",   mason = "css-lsp",   bin = "css-lsp",                         ts = "css",        pkg = nil,               mason_fmt = { "prettier" } },
  json =             { server = "jsonls",  mason = "json-lsp",  bin = "json-lsp",                        ts = "json",       pkg = nil,               mason_fmt = { "prettier" } },
  yaml =             { server = "yamlls",  mason = "yaml-language-server", bin = "yaml-language-server",  ts = "yaml",       pkg = nil,               mason_fmt = { "prettier" } },
  dockerfile =       { server = "dockerls", mason = "dockerfile-language-server", bin = "dockerfile-language-server", ts = "dockerfile", pkg = nil, mason_fmt = {} },
  javascript =       { server = "ts_ls", mason = "typescript-language-server", bin = "typescript-language-server",     ts = "javascript", pkg = "nodejs-lts", mason_fmt = { "prettier" } },
  typescript =       { server = "ts_ls", mason = "typescript-language-server", bin = "typescript-language-server",     ts = "typescript", pkg = "nodejs-lts", mason_fmt = { "prettier" } },
  javascriptreact =  { server = "ts_ls", mason = "typescript-language-server", bin = "typescript-language-server",     ts = "tsx",         pkg = "nodejs-lts", mason_fmt = { "prettier" } },
  typescriptreact =  { server = "ts_ls", mason = "typescript-language-server", bin = "typescript-language-server",     ts = "tsx",         pkg = "nodejs-lts", mason_fmt = { "prettier" } },
  sql =              { server = "sqls", mason = "sqls", bin = "sqls",                                               ts = "sql",        pkg = nil,               mason_fmt = {} },
  kotlin =           { server = "kotlin_language_server", mason = "kotlin-language-server", bin = "kotlin-language-server", ts = "kotlin", pkg = nil, mason_fmt = { "ktfmt" } },
}

-- Register on-demand server configs (without enable)
for _, cfg in pairs(on_demand) do
  vim.lsp.config(cfg.server, {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  })
end

-- Avoid installing the same Mason package twice
local lazy_installing = {}

-- ============================================
-- Autocommand: lazy installation and activation of LSP + Treesitter
-- ============================================
-- Uses vim.schedule to ensure mason/lspconfig/treesitter are already loaded
-- (they may load in VeryLazy, after initial startup)
local lazy_lsp_augroup = vim.api.nvim_create_augroup("lazy_lsp_setup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = lazy_lsp_augroup,
  callback = function(args)
    local buf = args.buf
    local ft = vim.bo[buf].filetype
    local cfg = on_demand[ft]
    if not cfg then return end

    -- Helper: poll to enable LSP when the binary is available
    local function try_enable_lsp()
      local timer, done, n = vim.uv.new_timer(), false, 0
      timer:start(1000, 1000, vim.schedule_wrap(function()
        if done then return end
        n = n + 1
        if n > 15 then done = true; timer:close(); return end
        if vim.fn.executable(cfg.bin) ~= 1 then return end
        done = true; timer:close()
        pcall(vim.lsp.enable, cfg.server)
        if #vim.lsp.get_clients({ name = cfg.server, bufnr = buf }) > 0 then
          vim.notify(string.format("%s ready", cfg.server), vim.log.levels.INFO)
        end
      end))
    end

    -- 0. Install language runtime via Termux if needed
    ensure_termux_pkg(cfg.pkg)

    -- 1. LSP server (only if no active client)
    local clients = vim.lsp.get_clients({ name = cfg.server, bufnr = buf })
    if #clients == 0 then
      if vim.fn.executable(cfg.bin) == 1 then
        pcall(vim.lsp.enable, cfg.server)
      else
        vim.schedule(function()
          local ok, mason_registry = pcall(require, "mason-registry")
          if not ok then return end

          local ok2, pkg = pcall(mason_registry.get_package, cfg.mason)
          if not ok2 then return end

          if pkg:is_installed() then
            try_enable_lsp()
          elseif not lazy_installing[cfg.mason] then
            lazy_installing[cfg.mason] = true
            vim.notify(string.format("Installing %s via Mason...", cfg.mason), vim.log.levels.INFO)
            if cfg.mason == "sqlls" then
              vim.env.GYP_DEFINES = "android_ndk_path=''"
            end
            pkg:on("install:success", function()
              vim.schedule(try_enable_lsp)
            end)
            pkg:install()
          end
        end)
      end
    end

    -- 2. Formatters + Treesitter (always, even if LSP is already active)
    vim.schedule(function()
      local ok, mason_registry = pcall(require, "mason-registry")
      if not ok then return end

      for _, fm in ipairs(cfg.mason_fmt or {}) do
        if not lazy_installing[fm] then
          lazy_installing[fm] = true
          local ok3, pkg_fmt = pcall(mason_registry.get_package, fm)
          if ok3 and not pkg_fmt:is_installed() then
            vim.notify(string.format("Installing formatter %s...", fm), vim.log.levels.INFO)
            pkg_fmt:install()
          end
        end
      end

      -- TailwindCSS: install and enable for web files
      pcall(function()
        local web_fts = { "html", "css", "javascript", "typescript", "javascriptreact", "typescriptreact" }
        if vim.tbl_contains(web_fts, ft) then
          local ok4, tw_pkg = pcall(mason_registry.get_package, "tailwindcss-language-server")
          if ok4 then
            if not tw_pkg:is_installed() and not lazy_installing["tailwindcss-language-server"] then
              lazy_installing["tailwindcss-language-server"] = true
              vim.notify("Installing tailwindcss-language-server via Mason...", vim.log.levels.INFO)
              tw_pkg:on("install:success", function()
                vim.schedule(function()
                  pcall(vim.lsp.enable, "tailwindcss")
                end)
              end)
              tw_pkg:install()
            elseif tw_pkg:is_installed() then
              pcall(vim.lsp.enable, "tailwindcss")
            end
          end
        end
      end)

      local ts_parser = cfg.ts
      if ts_parser then
        local function parser_installed(lang)
          local installed = require("nvim-treesitter").get_installed()
          return vim.tbl_contains(installed, lang)
        end

        if parser_installed(ts_parser) then
          pcall(vim.treesitter.start, buf)
          return
        end

        vim.notify(string.format("Installing treesitter parser for %s...", ts_parser), vim.log.levels.INFO)
        vim.cmd("TSInstall " .. ts_parser)

        local done, n = false, 0
        local timer = vim.uv.new_timer()
        timer:start(2000, 2000, vim.schedule_wrap(function()
          if done then return end
          n = n + 1
          if n > 15 then done = true; timer:close(); return end
          if not parser_installed(ts_parser) then return end
          done = true; timer:close()
          pcall(vim.treesitter.start, buf)
          vim.notify(string.format("Parser %s ready", ts_parser), vim.log.levels.INFO)
        end))
      end
    end)
  end,
})

-- ============================================
-- Manual command: ReinstallLang {python|go|c|cpp|php|rust|lua}
-- Forces reinstallation of LSP + formatters + treesitter
-- ============================================
vim.api.nvim_create_user_command("ReinstallLang", function(args)
  local ft = args.args
  local cfg = on_demand[ft]
  if not cfg then
    vim.notify("Language not supported. Use: python, go, c, cpp, cs, php, rust, lua, bash, sh, zsh, html, css, json, yaml, dockerfile, javascript, typescript, javascriptreact, typescriptreact, sql, kotlin", vim.log.levels.ERROR)
    return
  end

  lazy_installing[cfg.mason] = nil
  ensure_termux_pkg(cfg.pkg)

  if cfg.mason then
    if cfg.mason == "sqlls" then
      vim.env.GYP_DEFINES = "android_ndk_path=''"
    end
    vim.cmd("MasonInstall " .. cfg.mason)
  end

  for _, fm in ipairs(cfg.mason_fmt or {}) do
    lazy_installing[fm] = nil
    vim.cmd("MasonInstall " .. fm)
  end

  if cfg.ts then
    vim.cmd("TSInstall " .. cfg.ts)
  end

  local done, n = false, 0
  local timer = vim.uv.new_timer()
  timer:start(1000, 1000, vim.schedule_wrap(function()
    if done then return end
    n = n + 1
    if n > 30 then done = true; timer:close(); return end
    if vim.fn.executable(cfg.bin) ~= 1 then return end
    done = true; timer:close()
    pcall(vim.lsp.enable, cfg.server)
    vim.notify(string.format("%s reinstalled for %s", cfg.server, ft), vim.log.levels.INFO)
  end))

  vim.notify(string.format("Reinstalling tools for %s...", ft), vim.log.levels.INFO)
end, {
  nargs = 1,
  complete = function()
    local fts = {}
    for ft in pairs(on_demand) do
      table.insert(fts, ft)
    end
    return fts
  end,
  desc = "Reinstall LSP, formatters and treesitter for a language",
})
