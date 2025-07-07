return {
  { "nvim-lua/plenary.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },

  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {},
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE" }) -- no background for dropbar
    end,
  },

  {
    "mikavilpas/yazi.nvim",
    lazy = true,
    keys = {
      {
        "<leader>lf",
        "<cmd>Yazi<cr>",
        desc = "Open Yazi (file manager)",
      },
    },
    opts = {
      open_for_directories = true,
    },
  },

  {
    "catgoose/nvim-colorizer.lua",
    cmd = "ColorizerToggle",
    keys = {
      { "<leader>ux", "<cmd>ColorizerToggle<cr>", desc = "Colorizer" },
    },
    opts = {},
  },

  {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("tokyonight").setup()
      vim.cmd("colorscheme tokyonight-moon")
    end,
  },
}
