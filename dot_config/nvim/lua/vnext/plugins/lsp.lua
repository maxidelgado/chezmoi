return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    opts = {
      servers = {
        bashls = {},
        dockerls = {},
        jsonls = {},
        gopls = {
          settings = {
            gofumpt = true,
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            analyses = {
              fieldalignment = true,
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
            semanticTokens = true,
          },
        },
        lua_ls = {
          settings = {
            format = {
              enable = false,
            },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
            hint = { enable = true },
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
        marksman = {},
        pyright = {},
        templ = {},
        terraformls = {
          filetypes = { "terraform", "terraform-vars", "tf" },
        },
        tinymist = {},
        ts_ls = {},
        yamlls = {
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              schemaStore = {
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json",
              },
              format = { enabled = false },
              validate = false,
              schemas = {
                kubernetes = "*.yaml",
                ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
                ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
                ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = "azure-pipelines*.{yml,yaml}",
                ["https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/ansible.json#/$defs/tasks"] = "roles/tasks/*.{yml,yaml}",
                ["https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/ansible.json#/$defs/playbook"] = "*play*.{yml,yaml}",
                ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
                ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
                ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
                ["https://json.schemastore.org/dependabot-v2"] = ".github/dependabot.{yml,yaml}",
                ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = "*gitlab-ci*.{yml,yaml}",
                ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] = "*api*.{yml,yaml}",
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
                ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "*flow*.{yml,yaml}",
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(opts.servers),
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end

          map("<leader>lk", vim.lsp.buf.hover, "Hover")
          map("<leader>lR", vim.lsp.buf.rename, "Rename")
          map("<leader>la", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
          map("<leader>lD", vim.lsp.buf.declaration, "Declaration")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
              end,
            })
          end
        end,
      })

      local lspconfig = require("lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())
      for server, server_opts in pairs(opts.servers) do
        server_opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})
        lspconfig[server].setup(server_opts)
      end
    end,
  },
}
