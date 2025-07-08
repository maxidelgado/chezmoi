-- First, require our new 1Password helper utility
local onepass = require("utils.onepass")

return {
  ----------------------------------------------------------------------
  -- SYSTEM 1: GHOST-TEXT COMPLETIONS (GitHub Copilot)
  ----------------------------------------------------------------------
  {
    "Copilot-lua/Copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = "<Tab>",
            dismiss = "<C-e>",
          },
        },
        panel = { enabled = false }, -- Keep it minimal, we have CodeCompanion for chat
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  ----------------------------------------------------------------------
  -- SYSTEM 2: INTERACTIVE CHAT & ACTIONS (CodeCompanion + McHub)
  ----------------------------------------------------------------------
  {
    "McHub.nvim/mcphub.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      providers = {
        {
          name = "google",
          label = "Gemini 1.5 Pro",
          -- Securely fetch the API key using our helper function
          api_key = onepass.get_secret("op://personal/gemini/api-key"),
          model = "gemini-1.5-pro-latest",
        },
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
      "McHub.nvim/mcphub.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      adapter = "mcphub",
      -- Add any custom actions or settings here
    },
  },
}
