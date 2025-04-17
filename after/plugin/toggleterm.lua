local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
  return
end

toggleterm.setup({
  size = 100,
  open_mapping = [[<C-`>]],
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

function _G.set_terminal_keymaps()
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(0, "t", "<C-\\>", [[<C-\><C-n>]], opts)
  -- Terminal mode mapping: <C-m> to toggle fullscreen
  vim.api.nvim_buf_set_keymap(0, "t", "<C-m>", [[<C-\><C-n>:lua _ToggleCurrentTerminalFullscreen()<CR>i]], {
    noremap = true,
    silent = true,
    desc = "Toggle terminal fullscreen",
  })
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

local Terminal = require("toggleterm.terminal").Terminal
local node = Terminal:new({ cmd = "node", hidden = true })

function _NODE_TOGGLE()
  node:toggle()
end

local term_fullscreen_state = {
  win_id = nil,
  prev_height = nil,
  prev_width = nil,
  active = false,
}

local term_fullscreen_state = {
  win_id = nil,
  prev_height = nil,
  prev_width = nil,
  active = false,
}

-- 重置状态的独立函数
local function reset_fullscreen_state()
  term_fullscreen_state = {
    win_id = nil,
    prev_height = nil,
    prev_width = nil,
    active = false,
  }
end

function _ToggleCurrentTerminalFullscreen()
  local current_win = vim.api.nvim_get_current_win()

  -- 状态有效性检查
  local saved_win_valid = term_fullscreen_state.win_id and vim.api.nvim_win_is_valid(term_fullscreen_state.win_id)

  -- 如果之前的窗口无效但状态仍为active，首先重置状态
  if term_fullscreen_state.active and not saved_win_valid then
    reset_fullscreen_state()
  end

  -- 重新检查状态（可能已被重置）
  local is_same_window = term_fullscreen_state.win_id == current_win
  local should_restore = term_fullscreen_state.active and saved_win_valid and is_same_window

  if should_restore then
    -- 恢复原始大小
    if term_fullscreen_state.prev_height then
      pcall(vim.api.nvim_win_set_height, current_win, term_fullscreen_state.prev_height)
    end

    if term_fullscreen_state.prev_width then
      pcall(vim.api.nvim_win_set_width, current_win, term_fullscreen_state.prev_width)
    end

    reset_fullscreen_state()
  else
    -- 记录原始尺寸 - 高度保持当前值，宽度固定为40
    local orig_height = vim.api.nvim_win_get_height(current_win)
    local orig_width = 80 -- 固定宽度设为40

    -- 先设置原始宽度为40（确保从全屏切换回来时宽度为40）
    pcall(vim.api.nvim_win_set_width, current_win, orig_width)

    -- 更新状态
    term_fullscreen_state = {
      win_id = current_win,
      prev_height = orig_height,
      prev_width = orig_width,
      active = true,
    }

    -- 设置全屏尺寸
    local full_height = vim.o.lines - 2
    local full_width = vim.o.columns
    pcall(vim.api.nvim_win_set_height, current_win, full_height)
    pcall(vim.api.nvim_win_set_width, current_win, full_width)
  end
end
