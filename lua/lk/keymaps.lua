local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap

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

-- keymap("n", "<a-h>", "^", opts)
-- keymap("v", "<a-h>", "^", opts)
-- keymap("n", "<a-l>", "g_", opts)
-- keymap("v", "<a-l>", "g_", opts)

-- Open vimrc
keymap("n", "<leader>sc", ":e $MYVIMRC<cr>", opts)
keymap("n", "<leader>sv", ":source %<cr>", opts)

-- Normal --
keymap("n", "<c-h>", "<c-w>h", opts)
keymap("n", "<c-l>", "<c-w>l", opts)
keymap("n", "<c-k>", "<c-w>k", opts)
keymap("n", "<c-j>", "<c-w>j", opts)

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
keymap("n", "<leader>ff", "<cmd>lua require'telescope.builtin'.find_files()<cr>", opts)
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", opts)
keymap("n", "<leader>fs", "<cmd>Telescope current_buffer_fuzzy_find<cr>", opts)

-- Nvimtree
keymap("n", "<leader>e", ":NvimTreeToggle<cr>", opts)
keymap("n", "<M-S-f>", ":Format<cr>", opts)

-- Gitsigns
keymap("n", "<leader>bl", ":Gitsigns blame_line<cr>", opts)
keymap("n", "<leader>ph", ":Gitsigns preview_hunk<cr>", opts)

-- Treesitter Context
vim.keymap.set("n", "[c", function()
  require("treesitter-context").go_to_context()
end, { silent = true })

-- Easymotion
local easymotionLeaderKey = "<Space>m"
keymap("n", easymotionLeaderKey, "<Plug>(easymotion-prefix)", opts)
vim.g.Easymotion_leader_key = easymotionLeaderKey
