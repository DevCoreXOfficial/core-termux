-- Custom Neovim options
-- Extends default NvChad options

require "nvchad.options"

local o = vim.opt
local g = vim.g

-- ============================================
-- Fix for Termux/Android - Temporary directory
-- ============================================

-- /tmp does not exist on Android, use ~/.cache/nvim/tmp
local temp_dir = vim.env.HOME .. "/.cache/nvim/tmp"
vim.fn.mkdir(temp_dir, "p")

-- Set environment variables for temporary directory
-- XDG_RUNTIME_DIR is used by plenary.curl for temporary files
vim.env.TMPDIR = temp_dir
vim.env.TEMP = temp_dir
vim.env.TMP = temp_dir
vim.env.XDG_RUNTIME_DIR = temp_dir

-- Override vim.fn.tempname() to use our directory
-- This affects ALL calls that generate temporary files
local original_tempname = vim.fn.tempname
vim.fn.tempname = function()
    local temp = original_tempname()
    -- If tempname returns something in /tmp, redirect to our directory
    if temp and temp:match("^/tmp/") then
        local filename = vim.fn.fnamemodify(temp, ":t")
        return temp_dir .. "/" .. filename
    end
    return temp
end

-- ============================================
-- General options
-- ============================================

-- Cursor line
o.cursorlineopt = "both" -- Shows cursorline on line number and text

-- Line numbers
o.relativenumber = true -- Relative line numbers
o.number = true -- Shows absolute line number

-- Search
o.ignorecase = true -- Ignore case in searches
o.smartcase = true -- Use case sensitive if pattern has uppercase
o.hlsearch = true -- Highlight search results

-- Tab and indentation
o.tabstop = 2 -- Number of spaces that represents a tab
o.shiftwidth = 2 -- Number of spaces for autoindent
o.expandtab = true -- Expand tabs to spaces
o.autoindent = true -- Copy indentation from previous line
o.smartindent = true -- Smart indentation

-- Lines and columns
o.wrap = true -- Wrap long lines
o.linebreak = true -- Break at word boundaries
o.breakindent = true -- Indent wrapped lines
o.scrolloff = 8 -- Scroll margin lines
o.sidescrolloff = 8 -- Scroll margin columns

-- Split windows
o.splitright = true -- Open vertical splits to the right
o.splitbelow = true -- Open horizontal splits below

-- Clipboard
o.clipboard = "unnamedplus" -- Use system clipboard

-- Undo persistence
o.undofile = true -- Save undo to file
o.undolevels = 10000 -- Maximum undo levels

-- Timeout for mappings and keys
o.timeoutlen = 300 -- Timeout for mappings (ms)
o.updatetime = 200 -- Timeout for event triggers (ms)

-- Code folding
o.foldlevel = 99 -- Don't fold anything when opening a file
o.foldlevelstart = 99

-- Colors and appearance
o.termguicolors = true -- True color support
o.signcolumn = "yes" -- Always show sign column

-- Backspace
o.backspace = "indent,eol,start" -- Backspace behavior

-- ============================================
-- Custom global variables
-- ============================================

-- Leader key (already defined in init.lua)
-- g.mapleader = " "

-- ============================================
-- Custom autocommands
-- ============================================

-- Highlight search while typing
vim.api.nvim_create_autocmd("CmdlineEnter", {
  pattern = "/",
  callback = function()
    vim.opt.hlsearch = true
  end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
  pattern = "/",
  callback = function()
    vim.opt.hlsearch = false
  end,
})

-- Delete blank line at end of file when saving
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    -- Optional: delete trailing whitespace at end of lines
    -- vim.cmd([[%s/\s\+$//e]])
  end,
})
