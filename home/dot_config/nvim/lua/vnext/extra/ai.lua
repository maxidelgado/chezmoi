return {
  'Exafunction/codeium.vim',
  config = function ()
    -- Change '<C-e>' here to any keycode you like.
    vim.g.codeium_disable_bindings = 1 -- disable default bindings to avoid conflicts with other plugins
    vim.keymap.set('i', '<C-e>', function () return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
    vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
    vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
    vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
  end
}
