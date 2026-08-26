-- Custom key mappings
require "nvchad.mappings"

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ============================================
-- Global mappings
-- ============================================

-- Command mode
map("n", ";", ":", { desc = "Enter command mode" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Move lines
map("n", "<A-j>", "<Esc>:m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<Esc>:m .-2<CR>==", { desc = "Move line up" })
map("i", "<A-j>", "<Esc>:m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<Esc>:m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Splits
map("n", "<S-h>", "<C-w>h", { desc = "Go to left split" })
map("n", "<S-l>", "<C-w>l", { desc = "Go to right split" })
map("n", "<S-j>", "<C-w>j", { desc = "Go to lower split" })
map("n", "<S-k>", "<C-w>k", { desc = "Go to upper split" })

-- ============================================
-- Global formatting
-- ============================================
map("n", "<leader>fm", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format code" })

-- ============================================
-- AI and assistants
-- ============================================
map("n", "<leader>aa", ":CodeCompanionChat<CR>", { desc = "CodeCompanion: Open chat" })
map("v", "<leader>aa", ":CodeCompanionChat<CR>", { desc = "CodeCompanion: Chat with selection" })
map("v", "<leader>ai", ":CodeCompanion<CR>", { desc = "CodeCompanion: Transform selection" })
map("n", "<leader>ai", ":CodeCompanion<CR>", { desc = "CodeCompanion: Inline code creation" })
map("n", "<leader>at", ":CodeCompanionChat -t<CR>", { desc = "CodeCompanion: Toggle chat" })
map("n", "<leader>am", ":CodeCompanionActions<CR>", { desc = "CodeCompanion: Actions menu" })
map("n", "<leader>as", ":CodeCompanionChat -s<CR>", { desc = "CodeCompanion: Change adapter" })

-- Copilot
map("i", "<C-l>", function()
  local suggestion = vim.fn["copilot#Accept"]("")
  if suggestion ~= "" then
    vim.api.nvim_feedkeys(suggestion, "n", true)
  end
end, { silent = true, desc = "Copilot: Accept suggestion" })
map("i", "<C-j>", "copilot#Next()", { expr = true, silent = true, desc = "Copilot: Next" })
map("i", "<C-k>", "copilot#Previous()", { expr = true, silent = true, desc = "Copilot: Previous" })
map("i", "<C-h>", "copilot#Dismiss()", { expr = true, silent = true, desc = "Copilot: Dismiss" })

-- ============================================
-- Navigation and search
-- ============================================
map("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Find text" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Find help" })

-- ============================================
-- Splits and windows
-- ============================================
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally" })
map("n", "<leader>sq", ":close<CR>", { desc = "Close split" })
map("n", "<leader>so", ":only<CR>", { desc = "Close other splits" })

-- ============================================
-- LSP diagnostics
-- ============================================
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic list" })

-- ============================================
-- Clipboard
-- ============================================
map("n", "<leader>y", ":%yank<CR>", { desc = "Copy all to clipboard" })

-- ============================================
-- Utilities
-- ============================================
map("n", "<leader>sr", ":source $MYVIMRC<CR>", { desc = "Reload configuration" })
map("n", "<leader>ch", ":nohlsearch<CR>", { desc = "Clear highlight" })
map("n", "<leader>tw", ":set wrap!<CR>", { desc = "Toggle wrap" })
map("n", "<leader>tn", ":set relativenumber!<CR>", { desc = "Toggle relative numbers" })

-- ============================================
-- Code folding (nvim-ufo)
-- ============================================
map("n", "<leader>z", "za", { desc = "Toggle fold" })
map("n", "<leader>zR", "zR", { desc = "Open all folds" })
map("n", "<leader>zM", "zM", { desc = "Close all folds" })

-- ============================================
-- Buffer-local keybindings (filetype-specific)
-- ============================================
local ft_augroup = vim.api.nvim_create_augroup("ft_specific_mappings", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = ft_augroup,
  callback = function(args)
    local buf = args.buf
    local ft = vim.bo[buf].filetype
    local bopts = { buffer = buf, noremap = true, silent = true }

    -- Bash / Sh / Zsh
    if ft == "bash" or ft == "sh" or ft == "zsh" then
      map("n", "<leader>fs", ":%!shfmt<CR>", vim.tbl_extend("force", bopts, { desc = "Format with shfmt" }))
    end

  end,
})
