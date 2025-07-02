return {
  "echasnovski/mini.files",
  version = "*",
  config = function()
    require("mini.files").setup({
      windows = {
        preview = true,
      }
    })
  end,
}
