return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost", "InsertLeave" },
    opts = {
      formatters_by_ft = {
          go = {  "gofumpt", "goimports-reviser", "golines" },
          javascript = { "prettier" },
          json = { "prettier" },
          lua = { "stylua" },
          markdown = { "prettier" },
          python = { "isort", "ruff_format" },
          sh = { "shfmt" },
          terraform = { "terraform_fmt" },
          ["terraform-vars"] = { "terraform_fmt" },
          tex = { "latexindent" },
          toml = { "taplo" },
          typst = { "typstfmt" },
          yaml = { "yamlfmt" },
          sql = { "sql_formatter" },
        },

      linters_by_ft = {
        dockerfile = { "hadolint" },
        go = { "golangcilint" },
        lua = { "selene" },
        markdown = { "markdownlint-cli2" },
        yaml = { "yamllint" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        json = { "eslint_d" },
        html = { "eslint_d" },
        css = { "eslint_d" },
        graphql = { "eslint_d" },
        svelte = { "eslint_d" },
        angular = { "eslint_d" },
        python = { "flake8" },
      },

      formatters = {
        -- Golang
        ["goimports-reviser"] = {
            prepend_args = { "-rm-unused" },
        },
        golines = {
            prepend_args = { "--max-len=80" },
        },
        -- Lua
        stylua = {
            prepend_args = {
                "--column-width", "80",
                "--line-endings", "Unix",
                "--indent-type", "Spaces",
                "--indent-width", "4",
                "--quote-style", "AutoPreferDouble",
            },
          },
        },
    },
  },
  {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = {
      "bash",
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
      "kotlin",
      "ledger",
      "lua",
      "markdown",
      "markdown_inline",
      "query",
      "python",
      "regex",
      "terraform",
      "toml",
      "vim",
      "yaml",
      "jsonnet",
    },
  },
  dependencies = {
    -- "RRethy/nvim-treesitter-endwise",
    -- "mfussenegger/nvim-ts-hint-textobject",
    -- "windwp/nvim-ts-autotag",
  },
  config = function(_, opts)
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    require("nvim-treesitter.configs").setup({
      ensure_installed = opts.ensure_installed,
      highlight = {
        enable = true,
      },
      -- endwise = {
      --   enable = true,
      -- },
      indent = { enable = true },
      autopairs = { enable = true },
    })

    -- require("nvim-ts-autotag").setup()
    end,
  },
}
