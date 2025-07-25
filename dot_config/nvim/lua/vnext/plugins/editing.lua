return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile", "InsertLeave" },
    opts = {
      format_on_save = function()
        -- Disable with a global variable
        if not vim.g.autoformat then
          return
        end
        return { async = false, timeout_ms = 500, lsp_fallback = false }
      end,
      -- log_level = vim.log.levels.TRACE,
      formatters_by_ft = {
        go = { "goimports", "gofmt" },
        rust = { "rustfmt" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        lua = { "stylua" },
        markdown = { "prettierd", "prettier", "markdownlint-cli2" },
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
    },
    config = function(_, opts)
      local conform = require("conform")
      conform.setup(opts)
      conform.formatters.shfmt = {
        prepend_args = { "-i", "2" }, -- 2 spaces instead of tab
      }
      conform.formatters.stylua = {
        prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" }, -- 2 spaces instead of tab
      }
      conform.formatters.yamlfmt = {
        prepend_args = { "-formatter", "indent=2,include_document_start=true,retain_line_breaks_single=true" },
      }
      vim.g.autoformat = vim.g.autoformat
      vim.api.nvim_create_user_command("ToggleAutoformat", function()
        vim.api.nvim_notify("Toggling autoformat", vim.log.levels.INFO, { title = "conform.nvim", timeout = 2000 })
        vim.g.autoformat = vim.g.autoformat == false and true or false
      end, { desc = "Toggling autoformat" })
      vim.keymap.set("n", "<leader>tF", "<cmd>ToggleAutoformat<cr>", { desc = "Toggle format on save" })
    end,
  },

  {
    "folke/flash.nvim",
    opts = {},
    keys = {
      {
        "ss",
        mode = { "n", "x", "o" },
        -- Jump to any word
        function()
          ---@diagnostic disable: missing-fields
          require("flash").jump({
            pattern = ".", -- initialize pattern with any char
            search = {
              mode = function(pattern)
                -- remove leading dot
                if pattern:sub(1, 1) == "." then
                  pattern = pattern:sub(2)
                end
                -- return word pattern and proper skip pattern
                return ([[\<%s\w*\>]]):format(pattern), ([[\<%s]]):format(pattern)
              end,
            },
          })
        end,
        desc = "Flash",
      },
      -- stylua: ignore start
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter", },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash", },
      -- stylua: ignore end
    },
  },

  {
    "echasnovski/mini.surround",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- Number of lines within which surrounding is searched
      n_lines = 50,
    },
  },

  {
    "gbprod/substitute.nvim",
    keys = {
    -- stylua: ignore start
    { "s", function() require("substitute").operator() end, desc = "Substitute", },
    { "s", mode = "x", function() require("substitute").visual() end, desc = "Substitute", },
      -- stylua: ignore end
    },
    opts = {},
  },

  {
    {
      "folke/todo-comments.nvim",
      event = "BufReadPre", -- needed to highlight keywords
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {
        highlight = {
          multiline = false, -- I usually only wnat one line to be highlighted
        },
      },
      keys = {
        -- stylua: ignore start
        { "<leader>sT", function() Snacks.picker.todo_comments() end, desc = "Todo", },
        -- stylua: ignore end
      },
    },
  },

  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = {},
    keys = {
      -- stylua: ignore start
      { "<leader>R", "", desc = "Search & Replace" },
      { "<leader>RG", "<cmd>GrugFar<cr>", desc = "Open" },
      { "<leader>Rg", "<cmd>lua require('grug-far').open({ prefills = { paths = vim.fn.expand('%') } })<cr>", desc = "Open (Limit to current file)"},
      { "<leader>Rw", "<cmd>lua require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })<cr>", desc = "Search word under cursor", },
      { "<leader>Rs", mode = "v", "<cmd>lua require('grug-far').with_visual_selection({ prefills = { paths = vim.fn.expand('%') } })<cr>", desc = "Search selection", },
      -- stylua: ignore end
    },
  },

  {
    "echasnovski/mini.align",
    keys = {
      { "ga", mode = { "v" }, desc = "Align" },
      { "gA", mode = { "v" }, desc = "Align with Preview" },
    },
    opts = {},
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "norg", "org" },
    opts = {
      completions = { blink = { enabled = true } },
      render_modes = { "n" },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      vim.api.nvim_set_keymap("n", "<leader>um", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle Markdown" })
    end,
  },

  -- render-markdown blink.cmp integration
  {
    "saghen/blink.cmp",
    dependencies = { "MeanderingProgrammer/render-markdown.nvim", "saghen/blink.compat" },
    opts = {
      sources = {
        default = { "markdown" },
        providers = {
          markdown = {
            name = "RenderMarkdown",
            module = "blink.compat.source",
            fallbacks = { "lsp" },
            -- overwrite kind of suggestion
            transform_items = function(ctx, items)
              local kind = require("blink.cmp.types").CompletionItemKind.Text
              for i = 1, #items do
                items[i].kind = kind
              end
              return items
            end,
          },
        },
      },
    },
  },
}
