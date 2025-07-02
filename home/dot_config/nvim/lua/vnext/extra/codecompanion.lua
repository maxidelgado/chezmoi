return {
  "olimorris/codecompanion.nvim",
  cmd = {
    'CodeCompanion',
    'CodeCompanionActions',
    'CodeCompanionChat',
    'CodeCompanionCmd',
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "codecompanion" }
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
      agent = {
        adapter = "gemini",
      },
    },
    gemini = function()
      return require("codecompanion.adapters").extend("gemini", {
        schema = {
          model = {
            default = "gemini-2.5-flash"
          },
        },
        env = {
          api_key = "AIzaSyBBaMEw6U-AGkLI1pjaMNsi9Lmm91Bq_fY",
        },
      })
    end,
    display = {
      diff = {
        provider = "mini_diff",
      },
    },
  },
}
