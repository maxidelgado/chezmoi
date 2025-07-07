return {
  "williamboman/mason.nvim",
  lazy = true,
  cmd = "Mason",
  dependencies = {
    { "williamboman/mason-lspconfig.nvim", module = "mason" },
  },
  config = function()
    local lsp_servers = {
      "bashls",
      "dockerls",
      "jsonls",
      "gopls",
      "marksman",
      "pyright",
      "lua_ls",
      "terraformls",
      "ts_ls",
      "yamlls",
      "docker_compose_language_service",
      "dockerfile-language-server",
      "graphql",
      "svelte",
      "angularls",
      "cssls",
      "html",
      "sqlls",
      "buf_ls",
      "rust_analyzer",
      "jsonnet_ls",
      "tailwindcss",
    }

    local tools = {
      -- Formatter
      "isort",
      "prettier",
      "prettierd",
      "stylua",
      "shfmt",
      "taplo",
      -- Linter
      "hadolint",
      "eslint_d",
      "shellcheck",
      "selene",
      "tflint",
      "yamllint",
      "ruff",
      -- DAP
      "delve",
      -- Go
      "gofumpt",
      "goimports",
      "gomodifytags",
      "golangci-lint",
      "gotests",
      "iferr",
      "impl",
      -- Graphql
      "graphql-language-service-cli",
    }

    -- install_root_dir = path.concat({ vim.fn.stdpath("data"), "mason" }),
    require("mason").setup()

    -- ensure tools (except LSPs) are installed
    local mr = require("mason-registry")
    local function install_ensured()
      for _, tool in ipairs(tools) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end
    if mr.refresh then
      mr.refresh(install_ensured)
    else
      install_ensured()
    end

    -- install LSPs
    require("mason-lspconfig").setup({ ensure_installed = lsp_servers })
  end,
}
