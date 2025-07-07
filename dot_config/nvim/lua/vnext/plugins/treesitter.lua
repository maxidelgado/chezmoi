return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = {
      "bash",
      "bicep",
      "cmake",
      "css",
      "dockerfile",
      "go",
      "hcl",
      "html",
      "java",
      "javascript",
      "json",
      "jsonc",
      "jsonnet",
      "kotlin",
      "ledger",
      "lua",
      "markdown",
      "markdown_inline",
      "query",
      "python",
      "regex",
      "terraform",
      "templ",
      "toml",
      "tsx",
      "vim",
      "yaml",
      "svelte",
    },
  },
  dependencies = {
    "RRethy/nvim-treesitter-endwise", -- mainly for lua 'closing end' insertion
  },
  config = function(_, opts)
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    require("nvim-treesitter.configs").setup({
      ensure_installed = opts.ensure_installed,
      highlight = {
        enable = true,
      },
      endwise = {
        enable = true,
      },
      indent = { enable = true },
      autopairs = { enable = true },
    })
  end,
}
