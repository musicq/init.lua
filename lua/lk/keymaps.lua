local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap

local function cancel_hlsearch()
  if vim.v.hlsearch == 1 then
    vim.cmd("nohlsearch")
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end
end

keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Basic mappings
keymap("n", "<leader>y", [["+y]], opts)
keymap("v", "<leader>y", [["+y]], opts)
keymap("n", "<leader>nl", ":nohlsearch<cr>", opts)
keymap("n", "Y", "Vy", opts)

-- cancel search highlight when press <ESC> or <C-[>
vim.keymap.set("n", "<Esc>", cancel_hlsearch, { noremap = true, silent = true })
vim.keymap.set("n", "<C-[>", cancel_hlsearch, { noremap = true, silent = true })

keymap("i", "<c-b>", "<Left>", opts)
keymap("i", "<c-f>", "<Right>", opts)

-- keymap("n", "<a-h>", "^", opts)
-- keymap("v", "<a-h>", "^", opts)
-- keymap("n", "<a-l>", "g_", opts)
-- keymap("v", "<a-l>", "g_", opts)

-- Open vimrc
keymap("n", "<leader>sc", ":e $MYVIMRC<cr>", opts)
keymap("n", "<leader>sv", ":source %<cr>", opts)

-- Normal --
keymap("n", "<m-h>", "<c-w>h", opts)
keymap("n", "<m-l>", "<c-w>l", opts)
keymap("n", "<m-k>", "<c-w>k", opts)
keymap("n", "<m-j>", "<c-w>j", opts)

-- Resize with arrows
keymap("n", "<a-up>", ":resize +2<cr>", opts)
keymap("n", "<a-down>", ":resize -2<cr>", opts)
keymap("n", "<a-left>", ":vertical resize -2<cr>", opts)
keymap("n", "<a-right>", ":vertical resize +2<cr>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<a-j>", ":m .+1<cr>==", opts)
keymap("v", "<a-k>", ":m .-2<cr>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "<a-j>", ":move '>+1<cr>gv-gv", opts)
keymap("x", "<a-k>", ":move '<-2<cr>gv-gv", opts)

-- Terminal --
-- Better terminal navigation
keymap("t", "<c-h>", "<c-\\><c-n><c-w>h", term_opts)
keymap("t", "<c-j>", "<c-\\><c-n><c-w>j", term_opts)
keymap("t", "<c-k>", "<c-\\><c-n><c-w>k", term_opts)
keymap("t", "<c-l>", "<c-\\><c-n><c-w>l", term_opts)

-- keymap("n", "<leader>f", "<cmd>Telescope find_files<cr>", opts)
keymap("n", "<leader>pf", "<cmd>lua require'telescope.builtin'.find_files()<cr>", opts)
keymap("n", "<leader>pg", "<cmd>Telescope live_grep<cr>", opts)
keymap("n", "<leader>o", "<cmd>Telescope buffers<cr>", opts)
-- keymap("n", "<leader>sf", "<cmd>Telescope current_buffer_fuzzy_find<cr>", opts)

-- Nvimtree
keymap("n", "<leader>e", ":NvimTreeToggle<cr>", opts)
-- keymap("n", "<M-S-f>", ":Format<cr>", opts)

-- Gitsigns
keymap("n", "<leader>bl", ":Gitsigns blame_line<cr>", opts)
keymap("n", "<leader>ph", ":Gitsigns preview_hunk<cr>", opts)
keymap("n", "<leader>pz", ":Gitsigns reset_hunk<cr>", opts)

-- Treesitter Context
vim.keymap.set("n", "[c", function()
  require("treesitter-context").go_to_context()
end, { silent = true })

-- lspsaga
keymap("n", "g.", "<cmd>Lspsaga code_action<cr>", opts)
keymap("n", "<leader>pk", "<cmd>Lspsaga peek_definition<cr>", opts)
keymap("n", "<leader>fi", "<cmd>Lspsaga finder<cr>", opts)

-- outline
keymap("n", "gs", "<cmd>AerialNavToggle<cr>", opts)
