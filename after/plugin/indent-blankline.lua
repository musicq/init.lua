local hooks = require "ibl.hooks"

hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, "IndentLineColor", { fg = "#262626" })
  vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
  vim.api.nvim_set_hl(0, "ActiveIndentLineColor", { fg = "#5C5C5C" })
end)

require("ibl").setup {
  indent = { highlight = { "IndentLineColor" }, char = "▏" },
  scope = { highlight = { "ActiveIndentLineColor" } }
}

hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
