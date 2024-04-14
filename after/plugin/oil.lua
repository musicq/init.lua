local oil = require('oil')
local util = require('oil.util')

oil.setup({
  delete_to_trash = true,
  columns = {
    -- 'permissions',
    -- 'size',
    -- 'mtme',
    'icon',
  },
  view_options = {
    show_hidden = true,
    -- is_always_hidden = function(name, _) return name == '..' end,
    natural_order = true
  },
  keymaps = {
    ["g?"] = "actions.show_help",
    ["l"] = "actions.select",
    ["<C-s>"] = "actions.select_vsplit",
    ["<C-h>"] = "actions.select_split",
    ["<C-t>"] = "actions.select_tab",
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = "actions.close",
    ["<C-l>"] = "actions.refresh",
    ["h"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["`"] = "actions.cd",
    ["~"] = "actions.tcd",
    ["gs"] = "actions.change_sort",
    ["gx"] = "actions.open_external",
    ["g."] = "actions.toggle_hidden",
    ["g\\"] = "actions.toggle_trash",
  },
})

vim.keymap.set('n', '-', function()
  oil.open()

  util.run_after_load(0, function()
    vim.defer_fn(function()
      oil.select({ preview = true })
    end, 10)
  end)
end)
