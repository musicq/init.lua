local colorscheme = "adwaita"

local status_ok, cs = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found ")
  return
end

vim.g.adwaita_darker = true             -- for darker version
vim.g.adwaita_disable_cursorline = true -- to disable cursorline
vim.g.adwaita_transparent = true        -- makes the background transparent

vim.cmd([[colorscheme adwaita]])
