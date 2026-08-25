-- AI and code assistance plugins
-- GitHub Copilot and CodeCompanion

return {
  -- GitHub Copilot
  {
    "github/copilot.vim",
    commit = "dfe0a3a1c256167d181488a73ec6ccab8d8931a9",
    lazy = false,
    config = function()
      vim.g.copilot_no_tab_map = true
    end,
  },

  -- CodeCompanion
  {
    "olimorris/codecompanion.nvim",
    cmd = {
      "CodeCompanion",
      "CodeCompanionChat",
      "CodeCompanionActions",
      "CodeCompanionCLI",
      "CodeCompanionCodeReview",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      adapters = {
        http = {
          openai = function()
            return require("codecompanion.adapters").extend("openai", {
              env = { api_key = "OPENAI_API_KEY" },
              schema = { model = { default = "gpt-4o" } },
            })
          end,
          mistral = function()
            return require("codecompanion.adapters").extend("mistral", {
              env = { api_key = "MISTRAL_API_KEY" },
              schema = { model = { default = "mistral-large-latest" } },
            })
          end,
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = { api_key = "ANTHROPIC_API_KEY" },
              schema = { model = { default = "claude-sonnet-4-20250514" } },
            })
          end,
          cactus = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              name = "Cactus",
              env = {
                api_key = "sk-no-key-required",
                url = "http://127.0.0.1:8000",
              },
              schema = {
                model = { default = "gemma-4-E2B-it" },
              },
              opts = {
                -- Use non-streaming requests: avoids half-delivered SSE streams
                stream = false,
              },
            })
          end,
        },
      },

      interactions = {
        chat = { adapter = "mistral" },
        inline = { adapter = "mistral" },
      },

      display = {
        chat = { show_settings = true },
      },
    },
  },
}
