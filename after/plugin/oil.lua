local oil = require('oil')
-- local util = require('oil.util')

oil.setup({
  default_file_explorer = true,
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

-- vim.keymap.set('n', '<leader>-', function()
--   oil.toggle_float()

--   -- Wait until oil has opened, for a maximum of 1 second.
--   -- vim.wait(1000, function()
--   --   return oil.get_cursor_entry() ~= nil
--   -- end)

--   -- if oil.get_cursor_entry() then
--   --   oil.open_preview()
--   -- end
-- end)
vim.keymap.set("n", "-", "<CMD>Oil --preview<CR>", { desc = "Open parent directory" })
