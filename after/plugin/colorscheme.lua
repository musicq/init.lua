-- local colorscheme = "adwaita"
local colorscheme = "vitesse"

local status_ok, cs = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found ")
  return
end

vim.cmd([[colorscheme ]] .. colorscheme)

local function enrollAdwaita()
  local u = require 'adwaita.utils'
  local colors = u.gen_colors()
  local hl = u.highlight

  vim.g.adwaita_darker = true             -- for darker version
  vim.g.adwaita_disable_cursorline = true -- to disable cursorline
  vim.g.adwaita_transparent = true        -- makes the background transparent

  -- set Telescope popup style
  hl('TelescopeNormal', { fg = colors.light_4 })
  hl('TelescopeSelection', { fg = colors.light_4, bg = colors.blue_7 })
  hl('TelescopeMultiSelection', { fg = colors.light_4, bg = colors.blue_7 })
  hl('TelescopeMatching', { fg = colors.light_4, bg = colors.blue_7, bold = true })
  hl('TelescopePromptPrefix', { fg = colors.light_4, bg = colors.blue_7, bold = true })

  -- set Illuminate style
  hl('IlluminatedWordText', { bg = colors.dark_3 })
  hl('IlluminatedWordRead', { bg = colors.dark_3 })
  hl('IlluminatedWordWrite', { bg = colors.dark_3 })
end

local function enrollVitesse()
  local hl = require("vitesse.util").hl

  hl("CursorLine", { bg = "#111111" })

  -- set Illuminate style
  hl('IlluminatedWordWord', { bg = "#222222" })
  hl("IlluminatedWordText", { bg = "#222222" })
  hl("IlluminatedWordRead", { bg = "#222222" })
  hl("IlluminatedWordWrite", { bg = "#222222" })
end

if colorscheme == "adwaita" then
  enrollAdwaita()
elseif colorscheme == 'vitesse' then
  enrollVitesse()
end

vim.defer_fn(enrollVitesse, 100)
