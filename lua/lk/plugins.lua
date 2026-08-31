local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', '--branch=stable',
    lazypath,
  })
  print('Done.')
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- theme (only load the one you use)
  {
    "2nthony/vitesse.nvim",
    lazy = false,
    priority = 1000,
    dependencies = { "tjdevries/colorbuddy.nvim" },
    config = function()
      vim.cmd([[colorscheme vitesse]])
      local hl = require("vitesse.util").hl
      hl("CursorLine", { bg = "#111111" })
      hl("LspReferenceText", { bg = "#222222" })
      hl("LspReferenceRead", { bg = "#222222" })
      hl("LspReferenceWrite", { bg = "#222222" })
    end,
  },

  -- lsp
  {
    'williamboman/mason.nvim',
    cmd = "Mason",
    config = function()
      require('mason').setup({})
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
    config = function()
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      local highlight_group = vim.api.nvim_create_augroup("lk_lsp_highlight", { clear = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lk_lsp", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, silent = true, desc = desc })
          end

          map("n", "K", vim.lsp.buf.hover, "LSP hover")
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "gr", vim.lsp.buf.references, "Go to references")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "gl", vim.diagnostic.open_float, "Line diagnostics")
          map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
          map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")

          if client and client:supports_method("textDocument/completion", event.buf) then
            vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
            map("i", "<C-,>", vim.lsp.completion.get, "LSP completion")
          end

          local supports_document_highlight = client
            and client:supports_method("textDocument/documentHighlight", event.buf)

          if supports_document_highlight and not vim.b[event.buf].lsp_document_highlight then
            vim.b[event.buf].lsp_document_highlight = true
            vim.api.nvim_create_autocmd("CursorHold", {
              group = highlight_group,
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd("CursorMoved", {
              group = highlight_group,
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      require('mason-lspconfig').setup({
        ensure_installed = {
          "clangd", "cssls", "cssmodules_ls", "eslint", "gopls",
          "lua_ls", "rust_analyzer", "tailwindcss", "tsc", "yamlls", "taplo",
        },
        automatic_enable = { exclude = { "rust_analyzer" } },
      })
    end,
  },
  { 'neovim/nvim-lspconfig', lazy = true },
  {
    'mrcjkb/rustaceanvim',
    version = '^4',
    ft = { 'rust' },
  },
  {
    'nvimdev/lspsaga.nvim',
    cmd = "Lspsaga",
    keys = {
      { "g.",        "<cmd>Lspsaga code_action<cr>",     desc = "Code action" },
      { "<leader>pk", "<cmd>Lspsaga peek_definition<cr>", desc = "Peek definition" },
      { "<leader>fi", "<cmd>Lspsaga finder<cr>",          desc = "LSP finder" },
    },
    config = function()
      require('lspsaga').setup({ ui = { code_action = '' } })
    end,
  },

  -- formatter
  {
    'stevearc/conform.nvim',
    event = "BufWritePre",
    cmd = "Format",
    keys = {
      {
        "<m-s-f>",
        function()
          require("conform").format({ lsp_format = "fallback", async = false, timeout_ms = 1000 })
        end,
        mode = { "n", "v" },
        desc = "Format file or range",
      },
    },
    config = function()
      local conform = require('conform')
      conform.setup({
        formatters_by_ft = {
          javascript = { "prettierd", "prettier", stop_after_first = true },
          typescript = { "prettierd", "prettier", stop_after_first = true },
          javascriptreact = { "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "prettierd", "prettier", stop_after_first = true },
          svelte = { "prettierd", "prettier", stop_after_first = true },
          css = { "prettierd", "prettier", stop_after_first = true },
          html = { "prettierd", "prettier", stop_after_first = true },
          json = { "prettierd", "prettier", stop_after_first = true },
          yaml = { "prettierd", "prettier", stop_after_first = true },
          markdown = { "prettierd", "prettier", stop_after_first = true },
          graphql = { "prettierd", "prettier", stop_after_first = true },
          lua = { "stylua" },
          python = { "isort", "black" },
        },
        format_on_save = { lsp_format = "fallback", async = false, timeout_ms = 1000 },
      })

      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.range ~= 0 then
          range = { start = { args.line1, 0 }, ["end"] = { args.line2, 0 } }
        end
        conform.format({ lsp_format = "fallback", async = false, timeout_ms = 1000, range = range })
      end, { range = true })
    end,
  },

  -- file tree
  {
    'stevearc/oil.nvim',
    lazy = false,
    keys = {
      { "-", "<CMD>Oil --preview<CR>", desc = "Open parent directory" },
    },
    config = function()
      require('oil').setup({
        default_file_explorer = true,
        delete_to_trash = true,
        columns = { 'icon' },
        view_options = { show_hidden = true, natural_order = true },
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
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>pf", "<cmd>lua require'telescope.builtin'.find_files()<cr>", desc = "Find files" },
      { "<leader>pg", "<cmd>Telescope live_grep<cr>",                         desc = "Live grep" },
      { "<leader>o",  "<cmd>Telescope buffers<cr>",                           desc = "Buffers" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      telescope.setup({
        defaults = {
          selection_caret = "> ",
          path_display = { "smart" },
          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<PageUp>"] = actions.results_scrolling_up,
              ["<PageDown>"] = actions.results_scrolling_down,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-l>"] = actions.complete_tag,
              ["<C-_>"] = actions.which_key,
            },
            n = {
              ["<esc>"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["H"] = actions.move_to_top,
              ["M"] = actions.move_to_middle,
              ["L"] = actions.move_to_bottom,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["gg"] = actions.move_to_top,
              ["G"] = actions.move_to_bottom,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<PageUp>"] = actions.results_scrolling_up,
              ["<PageDown>"] = actions.results_scrolling_down,
              ["?"] = actions.which_key,
            },
          },
        },
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")
      local languages = {
        "lua", "vim", "vimdoc", "javascript", "typescript", "tsx",
        "rust", "go", "python", "html", "css", "json", "yaml",
        "toml", "bash", "c", "cpp", "markdown", "markdown_inline",
      }

      treesitter.setup()
      treesitter.install(languages)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lk_treesitter", { clear = true }),
        pattern = {
          "lua", "vim", "help", "javascript", "javascriptreact",
          "typescript", "typescriptreact", "rust", "go", "python",
          "html", "css", "json", "yaml", "toml", "sh", "c", "cpp",
          "markdown",
        },
        callback = function(event)
          local started = pcall(vim.treesitter.start, event.buf)
          if started and event.match ~= "yaml" then
            vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      {
        "[c",
        function() require("treesitter-context").go_to_context() end,
        desc = "Go to treesitter context",
      },
    },
    config = function()
      require('treesitter-context').setup({
        enable = true,
        multiwindow = false,
        max_lines = 0,
        min_window_height = 0,
        line_numbers = true,
        multiline_threshold = 20,
        trim_scope = 'outer',
        mode = 'cursor',
        separator = nil,
        zindex = 20,
        on_attach = nil,
      })
    end,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("ts_context_commentstring").setup({ enable_autocmd = false })

      local get_option = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option)
        return option == "commentstring"
            and require("ts_context_commentstring.internal").calculate_commentstring()
          or get_option(filetype, option)
      end
    end,
  },

  -- Status Bar
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local hide_in_width = function() return vim.fn.winwidth(0) > 80 end
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { "dashboard", "oil", "Outline" },
          always_divide_middle = true,
        },
        sections = {
          lualine_a = {
            { "branch",      icons_enabled = true,            icon = "" },
            { "diagnostics", sources = { "nvim_diagnostic" }, sections = { "error", "warn" }, symbols = { error = " ", warn = " " }, colored = false, update_in_insert = false, always_visible = true },
          },
          lualine_b = { { "mode", fmt = function(str) return "-- " .. str .. " --" end } },
          lualine_c = { function() return vim.fn.expand("%:p") end },
          lualine_x = {
            { "diff",     colored = false,       symbols = { added = " ", modified = " ", removed = " " }, cond = hide_in_width },
            function() return "spaces: " .. vim.bo.shiftwidth end,
            "encoding",
            { "filetype", icons_enabled = false, icon = nil },
          },
          lualine_y = { { "location", padding = 0 } },
          lualine_z = {
            function()
              local current_line = vim.fn.line(".")
              local total_lines = vim.fn.line("$")
              local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
              local line_ratio = current_line / total_lines
              local index = math.ceil(line_ratio * #chars)
              return chars[index]
            end,
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        extensions = {},
      })
    end,
  },

  -- Git
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      { "<leader>bl", "<cmd>Gitsigns blame_line<cr>",   desc = "Git blame line" },
      { "<leader>ph", "<cmd>Gitsigns preview_hunk<cr>", desc = "Git preview hunk" },
      { "<leader>pz", "<cmd>Gitsigns reset_hunk<cr>",   desc = "Git reset hunk" },
    },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { highlight = "GitSignsAdd", text = "▎" },
          change = { highlight = "GitSignsChange", text = "▎" },
          delete = { highlight = "GitSignsDelete", text = "契" },
          topdelete = { highlight = "GitSignsDelete", text = "契" },
          changedelete = { highlight = "GitSignsChange", text = "▎" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = { follow_files = true },
        attach_to_untracked = false,
        current_line_blame = false,
        current_line_blame_opts = { virt_text = true, virt_text_pos = "eol", delay = 1000, ignore_whitespace = false },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = { border = "single", style = "minimal", relative = "cursor", row = 0, col = 1 },
      })
    end,
  },
  { "tpope/vim-fugitive", cmd = { "Git", "G", "Gstatus", "Gblame", "Gdiff", "Gclog" } },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    keys = { { "<C-`>", desc = "Toggle terminal" } },
    cmd = "ToggleTerm",
    config = function()
      require("toggleterm").setup({
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
          highlights = { border = "Normal", background = "Normal" },
        },
      })

      function _G.set_terminal_keymaps()
        local opts = { noremap = true }
        vim.api.nvim_buf_set_keymap(0, "t", "<C-\\>", [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<M-m>", [[<C-\><C-n>:lua _ToggleCurrentTerminalFullscreen()<CR>i]], {
          noremap = true, silent = true, desc = "Toggle terminal fullscreen",
        })
      end

      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*",
        callback = function() set_terminal_keymaps() end,
      })

      local Terminal = require("toggleterm.terminal").Terminal
      local node = Terminal:new({ cmd = "node", hidden = true })
      function _NODE_TOGGLE() node:toggle() end

      local term_fullscreen_state = { win_id = nil, prev_height = nil, prev_width = nil, active = false }

      local function reset_fullscreen_state()
        term_fullscreen_state = { win_id = nil, prev_height = nil, prev_width = nil, active = false }
      end

      function _ToggleCurrentTerminalFullscreen()
        local current_win = vim.api.nvim_get_current_win()
        local saved_win_valid = term_fullscreen_state.win_id and vim.api.nvim_win_is_valid(term_fullscreen_state.win_id)
        if term_fullscreen_state.active and not saved_win_valid then
          reset_fullscreen_state()
        end
        local is_same_window = term_fullscreen_state.win_id == current_win
        local should_restore = term_fullscreen_state.active and saved_win_valid and is_same_window
        if should_restore then
          if term_fullscreen_state.prev_height then
            pcall(vim.api.nvim_win_set_height, current_win, term_fullscreen_state.prev_height)
          end
          if term_fullscreen_state.prev_width then
            pcall(vim.api.nvim_win_set_width, current_win, term_fullscreen_state.prev_width)
          end
          reset_fullscreen_state()
        else
          local orig_height = vim.api.nvim_win_get_height(current_win)
          local orig_width = 80
          pcall(vim.api.nvim_win_set_width, current_win, orig_width)
          term_fullscreen_state = { win_id = current_win, prev_height = orig_height, prev_width = orig_width, active = true }
          local full_height = vim.o.lines - 2
          local full_width = vim.o.columns
          pcall(vim.api.nvim_win_set_height, current_win, full_height)
          pcall(vim.api.nvim_win_set_width, current_win, full_width)
        end
      end
    end,
  },

  -- indent
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "IndentLineColor", { fg = "#262626" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "ActiveIndentLineColor", { fg = "#5C5C5C" })
      end)
      require("ibl").setup({
        indent = { highlight = { "IndentLineColor" }, char = "▏" },
        scope = { highlight = { "ActiveIndentLineColor" } },
      })
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
  },

  { "mbbill/undotree",    cmd = "UndotreeToggle" },

  -- hop
  {
    'smoka7/hop.nvim',
    version = "*",
    keys = {
      { 'f',         function() require('hop').hint_char1({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true }) end,                   mode = '',         remap = true },
      { 'F',         function() require('hop').hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true }) end,                  mode = '',         remap = true },
      { 't',         function() require('hop').hint_char1({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 }) end, mode = '',         remap = true },
      { 'T',         function() require('hop').hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 }) end, mode = '',         remap = true },
      { '<leader>j', function() require('hop').hint_char1() end,                                                                                                           desc = "Hop char1" },
    },
    opts = {},
  },

  -- harpoon
  {
    "ThePrimeagen/harpoon",
    keys = {
      { "<leader>a", function() require("harpoon.mark").add_file() end,        desc = "Harpoon add file" },
      { "<C-q>",     function() require("harpoon.ui").toggle_quick_menu() end, desc = "Harpoon menu" },
      { "<C-t>",     function() require("harpoon.ui").nav_file(1) end,         desc = "Harpoon file 1" },
      { "<C-h>",     function() require("harpoon.ui").nav_file(2) end,         desc = "Harpoon file 2" },
      { "<C-n>",     function() require("harpoon.ui").nav_file(3) end,         desc = "Harpoon file 3" },
      { "<C-s>",     function() require("harpoon.ui").nav_file(4) end,         desc = "Harpoon file 4" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- aerial
  {
    'stevearc/aerial.nvim',
    cmd = { "AerialToggle", "AerialNavToggle" },
    keys = {
      { "gs", "<cmd>AerialNavToggle<cr>", desc = "Aerial nav toggle" },
    },
    config = function()
      require("aerial").setup({
        backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
        layout = {
          max_width = { 40, 0.2 },
          width = nil,
          min_width = 10,
          win_opts = {},
          default_direction = "float",
          placement = "window",
          resize_to_content = true,
          preserve_equality = false,
        },
        attach_mode = "window",
        close_automatic_events = {},
        keymaps = {
          ["?"] = "actions.show_help",
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.jump",
          ["<2-LeftMouse>"] = "actions.jump",
          ["<C-v>"] = "actions.jump_vsplit",
          ["<C-s>"] = "actions.jump_split",
          ["p"] = "actions.scroll",
          ["<C-j>"] = "actions.down_and_scroll",
          ["<C-k>"] = "actions.up_and_scroll",
          ["{"] = "actions.prev",
          ["}"] = "actions.next",
          ["[["] = "actions.prev_up",
          ["]]"] = "actions.next_up",
          ["q"] = "actions.close",
          ["o"] = "actions.tree_toggle",
          ["za"] = "actions.tree_toggle",
          ["O"] = "actions.tree_toggle_recursive",
          ["zA"] = "actions.tree_toggle_recursive",
          ["l"] = "actions.tree_open",
          ["zo"] = "actions.tree_open",
          ["L"] = "actions.tree_open_recursive",
          ["zO"] = "actions.tree_open_recursive",
          ["h"] = "actions.tree_close",
          ["zc"] = "actions.tree_close",
          ["H"] = "actions.tree_close_recursive",
          ["zC"] = "actions.tree_close_recursive",
          ["zr"] = "actions.tree_increase_fold_level",
          ["zR"] = "actions.tree_open_all",
          ["zm"] = "actions.tree_decrease_fold_level",
          ["zM"] = "actions.tree_close_all",
          ["zx"] = "actions.tree_sync_folds",
          ["zX"] = "actions.tree_sync_folds",
        },
        lazy_load = true,
        disable_max_lines = 10000,
        disable_max_size = 2000000,
        filter_kind = { "Class", "Constructor", "Enum", "Function", "Interface", "Module", "Method", "Struct" },
        highlight_mode = "split_width",
        highlight_closest = true,
        highlight_on_hover = true,
        highlight_on_jump = 300,
        autojump = true,
        icons = {},
        ignore = { unlisted_buffers = false, diff_windows = true, filetypes = {}, buftypes = "special", wintypes = "special" },
        manage_folds = false,
        link_folds_to_tree = false,
        link_tree_to_folds = true,
        nerd_font = "auto",
        open_automatic = false,
        post_jump_cmd = "normal! zz",
        close_on_select = false,
        update_events = "TextChanged,InsertLeave",
        show_guides = false,
        float = { border = "rounded", relative = "win", max_height = 0.9, height = nil, min_height = { 8, 0.1 } },
        nav = {
          border = "rounded",
          max_height = 0.9,
          min_height = { 10, 0.1 },
          max_width = 0.8,
          min_width = { 0.2, 20 },
          win_opts = { cursorline = true, winblend = 10 },
          autojump = true,
          preview = true,
          keymaps = {
            ["<CR>"] = "actions.jump",
            ["<2-LeftMouse>"] = "actions.jump",
            ["<C-v>"] = "actions.jump_vsplit",
            ["<C-s>"] = "actions.jump_split",
            ["h"] = "actions.left",
            ["l"] = "actions.right",
            ["<C-c>"] = "actions.close",
          },
        },
        lsp = { diagnostics_trigger_update = false, update_when_errors = true, update_delay = 300 },
        treesitter = { update_delay = 300 },
        markdown = { update_delay = 300 },
        asciidoc = { update_delay = 300 },
        man = { update_delay = 300 },
      })
    end,
  },

  -- autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        ts_config = { lua = { "string", "source" }, javascript = { "string", "template_string" }, java = false },
        disable_filetype = { "TelescopePrompt", "spectre_panel" },
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'" },
          pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
          offset = 0,
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "PmenuSel",
          highlight_grey = "LineNr",
        },
      })
    end,
  },

  { 'nvim-tree/nvim-web-devicons', lazy = true },
}, {
  rocks = { enabled = false },
})
