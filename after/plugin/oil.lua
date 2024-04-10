require('oil').setup({
  delete_to_trash = true,
  columns = {
    -- 'permissions',
    -- 'size',
    -- 'mtme',
    'icon',
  },
  view_options = {
    show_hidden = true,
    is_hidden_file = function(name, bufnr)
      return vim.startswith(name, './') or vim.startswith(name, '../')
    end,
  }
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
