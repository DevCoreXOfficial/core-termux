-- Syntax highlighting with Treesitter
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  event = "BufReadPre",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup {
      auto_install = true,
      ensure_installed = {
        "html", "css", "javascript", "typescript", "tsx",
        "bash", "json", "markdown", "markdown_inline",
        "yaml", "toml", "lua", "vim", "vimdoc",
        "dockerfile", "gitignore", "regex", "query",
      },
      highlight = { enable = true },
      indent = { enable = true },
    }

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(ev)
        local ok = pcall(vim.treesitter.start, ev.buf)
        if ok then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    vim.keymap.set("n", "<C-space>", function()
      require("nvim-treesitter.incremental_selection").init_selection()
    end, { silent = true })
  end,
}
