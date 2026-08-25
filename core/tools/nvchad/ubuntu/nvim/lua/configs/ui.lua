-- UI configuration
-- Centralizes UI configuration

local M = {}

-- Notification configuration
M.notify = {
  timeout = 3000,
  top_down = false,
}

-- Which-key configuration
M.which_key = {
  plugins = {
    marks = true,
    registers = true,
    spelling = {
      enabled = true,
      suggestions = 20,
    },
  },
}

-- Indent-blankline configuration
M.indent_blankline = {
  indent = {
    char = "│",
  },
  scope = {
    enabled = true,
  },
}

-- Bufferline configuration
M.bufferline = {
  options = {
    modified_icon = "●",
    close_command = "bdelete! %d",
    right_mouse_command = "bdelete! %d",
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = true,
    numbers = "none",
    close_icon = "",
    max_name_length = 30,
    max_prefix_length = 30,
    tab_size = 21,
    show_buffer_close_icons = true,
    show_close_icon = true,
    color_icons = true,
    buffer_close_icon = "",
  },
}

-- Lualine configuration
M.lualine = {
  options = {
    theme = "auto",
    globalstatus = true,
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename" },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
}

-- Scrollbar configuration
M.scrollbar = {
  handlers = {
    cursor = true,
    search = true,
    diagnostic = true,
    gitsign = true,
    handle = true,
    ale = true,
  },
}

return M
