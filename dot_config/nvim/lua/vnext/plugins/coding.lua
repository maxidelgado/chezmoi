return {
  {
    "windwp/nvim-autopairs",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      check_ts = true,
      ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
        java = false,
      },
    },
  },
  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    opts = {
      symbol_folding = {
        autofold_depth = 1,
      },
      guides = {
        enabled = false,
      },
    },
    keys = {
      { "<leader>to", "<cmd>Outline<cr>", desc = "Toggle Outline" },
    },
  },
  {
    "fredrikaverpil/godoc.nvim",
    cmd = { "GoDoc" },
    opts = {},
  },
}
