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
    "olimorris/codecompanion.nvim",
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCmd",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "codecompanion" },
      },
    },
    opts = {
      strategies = {
        chat = {
          adapter = "gemini",
        },
        inline = {
          adapter = "gemini",
        },
      },
      gemini = function()
        return require("codecompanion.adapters").extend("gemini", {
          schema = {
            model = {
              default = "gemini-2.5-flash-preview-05-20",
            },
          },
          env = {
            api_key = onepass("personal/gemini/api-key"),
          },
        })
      end,
      display = {
        diff = {
          provider = "mini_diff",
        },
      },
    },
  },
}
