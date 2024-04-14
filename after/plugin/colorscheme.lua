local colorscheme = "adwaita"
local u = require 'adwaita.utils'
local colors = u.gen_colors()
local hl = u.highlight

local status_ok, cs = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found ")
  return
end

vim.g.adwaita_darker = true             -- for darker version
vim.g.adwaita_disable_cursorline = true -- to disable cursorline
vim.g.adwaita_transparent = true        -- makes the background transparent


vim.cmd([[colorscheme adwaita]])

-- set Telescope popup style
hl('TelescopeNormal', { fg = colors.light_4 })
hl('TelescopeSelection', { fg = colors.light_4, bg = colors.blue_7 })
hl('TelescopeMultiSelection', { fg = colors.light_4, bg = colors.blue_7 })
hl('TelescopeMatching', { fg = colors.light_4, bg = colors.blue_7, bold = true })
hl('TelescopePromptPrefix', { fg = colors.light_4, bg = colors.blue_7, bold = true })

