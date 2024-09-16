local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
  return
end

toggleterm.setup({
  size = 100,
  open_mapping = [[<M-3>]],
  hide_numbers = true,
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = 2,
  start_in_insert = true,
  insert_mappings = true,
  persist_size = true,
  direction = "vertical",
  close_on_exit = true,
  shell = vim.o.shell,
  modifiable = "on",
  float_opts = {
    border = "curved",
    winblend = 0,
    highlights = {
      border = "Normal",
      background = "Normal",
    },
  },
})

-- Define a variable to track the fullscreen state and layout file
local is_full_screen = false
local previous_width = vim.o.columns * 0.4

function ToggleFullScreen()
  if is_full_screen then
    vim.cmd('vertical resize' .. previous_width)
    vim.cmd('wincmd =')
    is_full_screen = false
  else
    vim.cmd('vertical resize' .. vim.o.columns)
    is_full_screen = true
  end
end

function _G.set_terminal_keymaps()
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(0, "t", "<C-\\>", [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-m>", '<cmd>lua ToggleFullScreen()<CR>', opts)
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

local Terminal = require("toggleterm.terminal").Terminal
local node = Terminal:new({ cmd = "node", hidden = true })

function _NODE_TOGGLE()
  node:toggle()
end
