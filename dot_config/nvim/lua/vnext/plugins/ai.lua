-- First, require our new 1Password helper utility
local onepass = require("utils.onepassword")

return {
  ----------------------------------------------------------------------
  -- SYSTEM 1: FOR CODE PREDICTION (GitHub Copilot)
  ----------------------------------------------------------------------
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter", -- Load only when you start typing
    config = function()
      require("copilot").setup({
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = "<Tab>", -- Press Tab to accept a suggestion
            dismiss = "<C-e>", -- Press Ctrl+e to dismiss it
          },
        },
        panel = { enabled = false }, -- Disable the chat panel to avoid overlap
      })
    end,
  },
  -- Helper to show Copilot suggestions in the nvim-cmp menu
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  ----------------------------------------------------------------------
  -- SYSTEM 2: FOR CHAT & ACTIONS (CodeCompanion + Gemini)
  ----------------------------------------------------------------------
  {
    "McHub.nvim/mcphub.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- We only configure one provider: Gemini
      providers = {
        {
          name = "google",
          label = "Gemini 1.5 Pro",
          -- This reads the environment variable you set earlier
          api_key_name = onepass("personal/gemini/api-key"),
          model = "gemini-1.5-pro-latest",
        },
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    -- Dependencies are required for CodeCompanion to work correctly
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
      "McHub.nvim/mcphub.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      -- This tells CodeCompanion to use McHub (and therefore Gemini)
      adapter = "mcphub",
    },
  },
}
